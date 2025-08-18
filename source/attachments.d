/*
*		SPDX-License-Identifier: GPL-2.0-or-later
*		Copyright 2025 Kavinu Nethsara
*/

module attachments;

import std.json, std.file, std.typecons, std.stdio, std.array;
import epub2;
import requests;

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
