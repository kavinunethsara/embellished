import std.stdio, std.typecons, std.algorithm, std.array, std.process, std.format;
import epub2;
import requests;
import std.json, std.file;
import parserino;

int main(string[] args)
{
	if (args.count != 2) {
		writeln("JSON file for book info required.");
		return 1;
	}

	const filename = args[1];
	auto req  = Request();

	if (environment.toAA().keys().canFind("HTTP_PROXY")) {
		req.proxy = environment["HTTP_PROXY"];
	}

	if (!exists(filename) || !isFile(filename)) {
		writeln("Given json file doesn't exist.");
		return 1;
	}

	const content = parseJSON(readText(filename));

	auto info = BookInfo();
	info.title = content["title"].str();
	info.filename = content["filename"].str();
	info.url = content["url"].str();
	info.author = content.value("author");
	info.style = content.value("style");

	assign_chapters(info.url, info, req);

	auto book = new Book;
	book.title = info.title;
	if (!info.author.isNull())
		book.author = info.author.get();

	auto chps = info.data.map!((chap) {
		return Chapter(
			chap.title,
			true,
			chap.content
		);
	});
	book.chapters = chps.array;

	const image = get_image(content, req);

	if (!image.isNull()) {
		book.coverImage = image.get();
		book.attachments ~= book.coverImage;
	}

	const stylesheet = get_style(content);

	if (!stylesheet.isNull()) {
		book.attachments ~= stylesheet.get();
	}

	book.toEpub(info.filename ~ ".epub");

	writeln("Edit source/app.d to start your project.");
	return 0;
}

Nullable!string value(const JSONValue object, string field) @safe {
	Nullable!string val;
	try {
		val = object[field].str();
	} catch (Exception e) {
		val.nullify();
	}
	return val;
}

void assign_chapters(string link, ref BookInfo info, ref Request req) @trusted {
	writeln("Getting page ", link, " ...");
	auto results =req.get(link).responseBody();
	const html = cast(string)results;

	Document doc = html;
	Data chapter;
	chapter.title = doc.bySelector("title").frontOrThrow.innerText;
	const content =  doc.bySelector(".text_story").frontOrThrow.innerHTML;
	chapter.content = wrap_page(chapter.title, content);

	auto next_story = doc.bySelector(".next_story_btn a").array;


	info.data ~= chapter;
	if (chapter.title == "Epilogue" || next_story.count() == 0) {
		writeln("Last chapter reached. Finishing ...");
		return;
	}

	assign_chapters(next_story[0].getAttribute("href"), info, req);
}

string wrap_page(const string title, const string html) {
	return `<?xml version="1.0" encoding="UTF-8"?>
					<!DOCTYPE html>
					<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
						<head>
						<meta charset="UTF-8" />
						<title>%s</title>
						<link rel="stylesheet" type="text/css" href="style.css" />
						</head>
					<body>%s</body></html>`.format(title, html);
}

Nullable!Attachment get_image(const JSONValue content, ref Request req) @trusted {
	Nullable!Attachment image;
	try {
		const image_url = content["cover"].str();
		writeln("Getting cover image ",image_url," ...");
		auto response = req.get(image_url);
		string type = response.responseHeaders["content-type"];
		auto extension = type[6..$];
		writeln("Cover image is of type ",type,". Therefore using extension .", extension);
		image = Attachment("cover", "cover."~extension, type, response.responseBody().array);
	} catch (Exception e) {
		destroy(e);
	}
	return image;
}

Nullable!Attachment get_style(const JSONValue content) @trusted {
	Nullable!Attachment stylesheet;
	try {
		const file_name = content["stylesheet"].str();
		if (!exists(file_name) || !isFile(file_name)) {
			writeln("File ", file_name, " not found. Skipping stylesheet generation ...");
			return stylesheet;
		}
		stylesheet = Attachment("css", "style.css", "text/css", cast(ubyte[])file_name.read());
	} catch (Exception e) {
		destroy(e);
	}
	return stylesheet;
}

struct BookInfo {
	string title;
	string url;
	Data[] data = [];
	string filename;
	Nullable!string author;
	Nullable!string cover;
	Nullable!string style;
}

struct Data {
	string title;
	string content;
}
