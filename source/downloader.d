/*
*		SPDX-License-Identifier: GPL-2.0-or-later
*		SPDX-FileCopyrightText: 2025 Kavinu Nethsara <kavinunethsarakoswattage@gmail.com>
*/

module downloader;

import std.stdio, std.format, std.array, std.algorithm;
import parserino;
import requests;

import bookinfo;

/**
*	Recursive function to process chapters into a Data[] array.
* It follows each `.next_story a` link until:
*		1. It arrives at a page without a `.next_stroy a` or `.+next` link or
* 	2. It finds a page with title 'Epilogue'
*Params:
* `link` URL of the starting point
* `info` BookInfo object to save the chapters to. Passed by reference.
* `req` Request object to make network requests with
*/
void assign_chapters(string link, ref BookInfo info, ref Request req) @trusted {
	writeln("Getting page ", link, " ...");
	auto results =req.get(link).responseBody();
	const html = cast(string)results;

	Document doc = html;
	Data chapter;
	chapter.title = doc.bySelector("title, .chapter__title").frontOrThrow.innerText;
	const content =  doc.bySelector(".text_story, #chapter-content div").frontOrThrow.innerHTML;
	chapter.content = wrap_page(chapter.title, content);

	auto next_story = doc.bySelector(".next_story_btn a, ._next").array;

	info.data ~= chapter;

	// TODO: Add an option to specify a different terminating title.
	if (chapter.title == "Epilogue" || next_story.count() == 0) {
		writeln("Last chapter reached. Finishing ...");
		return;
	}

	// Follow the `.next_story a` link recursively
	assign_chapters(next_story[0].getAttribute("href"), info, req);
}

/// Wraps the page with the page layout
string wrap_page(const string title, const string html) {
	return page_template.format(title, html);
}
