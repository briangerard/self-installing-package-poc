# Demonstration of a Self-Installing Package

## Self-Installer Sections

Sections
----------
Preamble; set extraction paths and filenames; begin decoding of...
A big blob of text in a heredoc, which is really the base64-encoded script that actually installs the "real" package
Check that the extraction succeeded; if so, begin decoding of...
A second (bigger) blob of text in another heredoc, which is actually the base64-encoded gzipped tarball that contains the code to install
Check that the extraction succeeded; if so, run the decoded installation script

# Sketch of Build Steps

Steps
----------
Create a temp directory whose subdirectories mirror the final directory structure , perform any build steps and place the installable scripts, etc. where they belong under it.
Create a gzipped tarball of the temp directory in the packaging directory.
Copy the installation script into the packaging directory, making any necessary build time modifications.
Create the installer out of the pieces of the extraction script (head, middle, tail), with the base64-encoded installation script and tarball sandwiched between the sections.

