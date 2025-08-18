module bookinfo;

import std.json, std.typecons;

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
