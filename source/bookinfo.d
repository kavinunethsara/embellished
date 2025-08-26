/*
*		SPDX-License-Identifier: GPL-2.0-or-later
*		SPDX-FileCopyrightText: 2025 Kavinu Nethsara <kavinunethsarakoswattage@gmail.com>
*/

module bookinfo;

import std.json, std.typecons, std.format;
import epub2;

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
	Attachment[] images = [];
}

/**
*	Return string values from JSONValue objects.
*	If the value is not present or is not a string, a `null` nullable is returned
*Params:
* `object` A JSONValue from which to extract the value
* `field` The filed to extract
*Returns:
* A Nullable!string with the return value or null (if a strnig value is not present in the field)
*/
Nullable!string value(const JSONValue object, string field) @safe {
	Nullable!string val;
	try {
		val = object[field].str();
	} catch (Exception e) {
		val.nullify();
	}
	return val;
}

const page_template = `<?xml version="1.0" encoding="UTF-8"?>
					<!DOCTYPE html>
					<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
						<head>
						<meta charset="UTF-8" />
						<title>%s</title>
						<link rel="stylesheet" type="text/css" href="style.css" />
						</head>
					<body>%s</body></html>`;

string generate_cover(const string img) {
	return page_template.format("Cover Page", "<img src='"~img~"' style='height: 100%;' />");
}
