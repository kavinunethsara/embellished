/*
*		SPDX-License-Identifier: GPL-2.0-or-later
*		Copyright 2025 Kavinu Nethsara
*/

import std.stdio, std.algorithm, std.array, std.process;
import std.json, std.file;
import epub2;
import requests;

import attachments;
import bookinfo;
import downloader;

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

	return 0;
}
