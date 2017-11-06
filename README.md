# Demonstration of a Self-Installing Package

## Self-Installer Sections

1. Preamble; set extraction paths and filenames; begin decoding of...
1. A big blob of text in a heredoc, which is really the base64-encoded script that actually installs the "real" package
1. Check that the extraction succeeded; if so, begin decoding of...
1. A second (bigger) blob of text in another heredoc, which is actually the base64-encoded gzipped tarball that contains the code to install
1. Check that the extraction succeeded; if so, run the decoded installation script

## Sketch of Build Steps

1. Create a temp directory whose subdirectories mirror the final directory structure , perform any build steps and place the installable scripts, etc. where they belong under it.
1. Create a gzipped tarball of the temp directory in the packaging directory.
1. Copy the installation script into the packaging directory, making any necessary build time modifications.
1. Create the installer out of the pieces of the extraction script (head, middle, tail), with the base64-encoded installation script and tarball sandwiched between the sections.

