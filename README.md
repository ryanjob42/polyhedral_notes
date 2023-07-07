# Polyhedral Notes
Notes and tutorials about various polyhedral tools, such as Alpha/AlphaZ and ISL.

- [Making Changes](#making-changes)
- [Directory Structure](#directory-structure)
- [Writing Style](#writing-style)

## Making Changes
This repo is in an early development stage, so let's avoid too much organization for now. 
Once we have more notes to work with, we can restructure the repo so it makes more sense.
When adding new information, put it in the place that makes the most sense.
Feel free to add new files if that's what makes sense.
Try to avoid major restructuring of existing files for now.

Feel free to commit directly to the `main` branch.
To avoid conflicts, it's recommended to make frequent, smaller commits and to push/pull often.

## Directory Structure
Each polyhedral tool should have its own directory,
that way we can have several files per tool.
Closely related tools can be in the same directory.
For example, the Integer Set Library (ISL) is all written in C,
but the Python bindings (ISLPy) and the Java bindings should be in the same directory,
as they're very closely related.

Each directory should have a "README.md" file,
as that's what GitHub will display when you navigate to the folder.
Since GitHub shows you a list of all the files in a directory,
it's not necessary to have links to all the pages in the directory.
However, if there are quite a few documents in a directory,
having the "README.md" file list them with descriptions may be a good idea.

## Writing Style
The first line of each file should be the document's title as a "Heading 1"
(put a single `#` character and a space before the title).
The title of the file should be basically the same as the name of the file.
The only exception is the "README.md" file in each directory,
where the document's title should be the name of the directory.

Since the document's title is a "Heading 1",
all top-level sections should be a "Heading 2" (two `#` characters).
Subsections should be a "Heading 3".
Let's try to avoid going to a "Heading 4" or beyond, as those headings tend not to render well.

For most documents, we should include a table of contents.
The easiest way to do this is by writing the documents in VS Code
and using the "Markdown All in One" extension by "Yu Zhang".
VS Code should automatically recommend this extension for you
via the `extensions.json` file in the `.vscode` directory.
This extension adds some conveniences when writing the document,
including commands to insert a table of contents and to automatically keep it up to date.
Since all top-level sections should be a "Heading 2",
the "ToC: Levels" setting shoudl be set to start with "Heading 2".
This should already be configured in the `settings.json` file in the `.vscode` directory.

Since these documents are primarily to help others get started with these tools,
they don't need to be perfectly formal or detail every single nuance.
However, if you're describing something which has nuance to it
which you don't want to describe right there,
please indicate this (and provide a link to more detailed documentation if it exists).
