/*
*		SPDX-License-Identifier: GPL-2.0-or-later
*		SPDX-FileCopyrightText: 2025 Kavinu Nethsara <kavinunethsarakoswattage@gmail.com>
*/

module attachments;

import std.json, std.file, std.typecons, std.stdio, std.array;
import epub2;
import requests;

/**
* Downloads and sets the cover image for the ebook.
*Params:
* `content` A JSONValue containing a ["cover"] field pointing to image URL
* `req` Request object to download the image
*Returns:
* A Nullable!Attachment of the cover image (id: cover)
* or Null incase of error downloading the image.
* Also returns Null if `content` does not contain a ["cover"] field
*/
Nullable!Attachment get_cover(const JSONValue content, ref Request req) @trusted {
	Nullable!Attachment image;
	try {
		const image_url = content["cover"].str();
		writeln("Getting cover image ",image_url," ...");
		auto response = req.get(image_url);
		string type = response.responseHeaders["content-type"];
		// HACK: Most image formats have a mime of form image/{extension}.
		// Trimming the 'image/' part out will give the extension most of the time.
		auto extension = type[6..$];
		writeln("Cover image is of type ",type,". Therefore using extension .", extension);
		image = Attachment("cover", "cover."~extension, type, response.responseBody().array);
	} catch (Exception e) {
		destroy(e);
	}
	return image;
}

/**
* Downloads and return an image for the ebook.
*Params:
*	`id`	Image Id
* `image_url` Image url
* `req` Request object to download the image
*Returns:
* A Nullable!Attachment of the image
* or Null incase of error downloading the image.
*/
Nullable!Attachment get_image(const string id, const string image_url, ref Request req) @trusted {
	Nullable!Attachment image;
	try {
		writeln("Getting image ",image_url," ...");
		auto response = req.get(image_url);
		string type = response.responseHeaders["content-type"];
		// HACK: Most image formats have a mime of form image/{extension}.
		// Trimming the 'image/' part out will give the extension most of the time.
		auto extension = type[6..$];
		writeln("Image "~id~" is of type ",type,". Therefore using extension .", extension);
		image = Attachment(id, id~"."~extension, type, response.responseBody().array);
	} catch (Exception e) {
		destroy(e);
	}
	return image;
}

/**
* Sets the style sheet for the ebook.
*Params:
* `content` A JSONValue containing a ["stylesheet"] field with path to a local file
*Returns:
* A Nullable!Attachment of the style sheet (id: style, file: style.css)
* or Null incase of the file not existing / being unreadable.
* Also returns Null if `content` does not contain a ["stylesheet"] field
*/
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
