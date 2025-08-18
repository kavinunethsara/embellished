module about;

const help = `
USAGE:
  embellished json_file.json

ARGUMENTS:
  json_file.json    :   Name of the JSON file describing the book to generate.
  --help, -h        :   This help dialog

FORMAT {json_file.json}:
  {
    "title": "Book Title",
    "url": "Link to the first chapter",
    "filename": "File name to save the file to",
    "author": "Author's name (optional)",
    "cover": "Url for cover image (optional)",
    "stylesheet": "Path to a local stylesheet (*.css) to include (optional)"
  }
`;
