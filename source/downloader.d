/*
*		SPDX-License-Identifier: GPL-2.0-or-later
*		Copyright 2025 Kavinu Nethsara
*/

module downloader;

import std.stdio, std.format, std.array, std.algorithm;
import parserino;
import requests;

import bookinfo;

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
	return page_template.format(title, html);
}
