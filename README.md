# Embellished

A tiny programme to create EPub files from [lightnovelstranslations.com](https://lightnovelstranslations.com/).
This is a recreation of a tool I originally wrote in Node/JS named `embellish` created to learn Dlang.

## Usage

```sh
embellished book.json
```

where `book.json` is a json file of the following format:

```json
{
  "title": "Book Title",
  "url": "Link to the first chapter",
  "filename": "File name to save the file to",
  "author": "Author's name (optional)",
  "cover": "Url for cover image (optional)",
  "stylesheet": "Path to a local stylesheet (*.css) to include (optional)"
}
```

The app will extract each chapter until it reach a chapter with name `Epilogue` or no further next page links.

## Building

```sh
dub build
```
