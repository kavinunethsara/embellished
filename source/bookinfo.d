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
