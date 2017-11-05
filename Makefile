##############
#
# The basic idea of this build is to create a stand-alone installation
# script for the packaged version of the repository.  By "stand-alone"
# that means that the script itself contains the tarball it needs, as
# well as a separate script to extract and install from that tarball.
# The end product will be a script named install-PACKAGE_NAME-PACKAGE_VERSION,
# in the 'pkg' directory.  Such as: pkg/install-our_package-1.2.0
#
# So that's what gmake will create.  It does so by:
# 	1. catting extractor.head into the new stand-alone script (creating it)
# 	2. base64-encoding the script which will actually install the package
# 	   tarball and appending it to the stand-alone script
# 	3. appending extractor.middle to the stand-alone script
# 	4. base64-encoding the package tarball and appending it to the
# 	   stand-alone script
# 	5. appending extractor.tail to the stand-alone script
#
# The extractor.* script pieces contain the logic for extracting the payload
# and running the installer.
#
# The installer is virtually the same as it is in git, except for a couple
# of file paths which are filled in by this Makefile at build time.  Look
# for the 'perl' lines, where it's replacing values with double-underscored
# values ("__FOO_BAR__") to see this, below.
#
# The package tarball is created by copying the bin, lib, sbin, and vendor
# directories into a temporary directory, creating an etc directory alongside
# them and putting a MANIFEST in there, and then tarring the whole temp
# directory up (compressed).  There are some other path substitutions at
# this stage as well.
#
##############

PKGDIR           = pkg

# This should be the one place the package name is defined, throughout the
# package.  Literally everything else should depend on this for the package
# name.
PACKAGE_NAME     = our_awesome_utilities
PACKAGE_VERSION := $(shell /bin/awk '/^Version/ {print $$2; exit}' ChangeLog)

# This is the name of the tarball that contains the actual code being
# installed.  I.e. - it should not contain any installation logic beyond
# what's entailed in a tarball anyway (paths and such, that is).
NOZIP_PAYLOAD    = $(PACKAGE_NAME)-$(PACKAGE_VERSION).package.tar
PAYLOAD          = $(NOZIP_PAYLOAD).gz

# The payload's location in the packaging directory, used in creating the
# installer.  This will be removed after the self-installer is built.
NOZIP_PKGPAYLOAD = $(PKGDIR)/$(NOZIP_PAYLOAD)
PKGPAYLOAD       = $(PKGDIR)/$(PAYLOAD)

# Temporary scratch space used on the way to building the payload.
BUILDROOT = /tmp
BUILDDIR  = $(BUILDROOT)/build-$(PACKAGE_NAME)
BUILDSRC  = $(BUILDDIR)/$(PACKAGE_NAME)

# A manifest file to make it easier to figure out exactly what went into
# the package at build time.
BUILDETC   = $(BUILDSRC)/etc
MANIFEST   = $(BUILDETC)/MANIFEST_$(PACKAGE_NAME)
REPOSITORY = $(shell git remote -v | grep fetch | awk '{print $$2}')
REVISION   = $(shell git log -n 1 --format='%H')

# The contents of the MANIFEST.
define MANIFEST_TEXT
# Our Awesome Utilities Version: $(PACKAGE_VERSION)
# Repository: $(REPOSITORY)
# Revision:   $(REVISION)
endef
export MANIFEST_TEXT

# The contents of the payload.
SRCDIRS         = bin lib sbin vendor
ALL_FILES       = $(shell find $(SRCDIRS) -type f)

# The pieces needed when creating the self-installer.
EXTRACTOR_PARTS = extractor.head extractor.middle extractor.tail
EXTRACTOR       = install-$(PACKAGE_NAME)

# The final name of the self-installer (in the package directory).
# This is the object which gmake creates.
PKGEXTRACTOR    = $(PKGDIR)/$(EXTRACTOR)-$(PACKAGE_VERSION)

# The script which will be extracted and used to install the payload.
INSTALLER       = install

# The installation script as it will be staged while creating the
# self-installer.  This will be removed after the self-installer is
# built.
PKGINSTALLER    = $(PKGDIR)/$(INSTALLER)


# Everything kicks off starting here.
all: $(PKGEXTRACTOR) cleanup

# The self-extracting script, described above.
$(PKGEXTRACTOR): $(PKGDIR) $(EXTRACTOR_PARTS) $(PKGINSTALLER) $(PKGPAYLOAD)
	cat extractor.head            > $(PKGEXTRACTOR)
	perl -pi -e 's|__PACKAGE_NAME__|$(PACKAGE_NAME)|g' $(PKGEXTRACTOR)
	perl -pi -e 's|__PAYLOAD__|$(PAYLOAD)|g' $(PKGEXTRACTOR)
	cat $(PKGINSTALLER) | base64 >> $(PKGEXTRACTOR)
	cat extractor.middle         >> $(PKGEXTRACTOR)
	cat $(PKGPAYLOAD)   | base64 >> $(PKGEXTRACTOR)
	cat extractor.tail           >> $(PKGEXTRACTOR)
	chmod 755 $(PKGEXTRACTOR)

# This is the installation script which will be extracted from the
# self-extracting script at installation time.
$(PKGINSTALLER): $(INSTALLER)
	/bin/cp $(INSTALLER) $(PKGINSTALLER)
	perl -pi -e 's|__PACKAGE_NAME__|$(PACKAGE_NAME)|g' $(PKGINSTALLER)
	perl -pi -e 's|__PAYLOAD__|$(PAYLOAD)|g' $(PKGINSTALLER)

# This is the tarball containing the actual source of this package,
# which the installation script will untar and install from.
$(PKGPAYLOAD): $(BUILDSRC) $(MANIFEST) $(ALL_FILES)
	cp -R $(SRCDIRS) $(BUILDSRC)
	tar cvf $(NOZIP_PKGPAYLOAD) -C $(BUILDDIR) $(PACKAGE_NAME)
	gzip -9 $(NOZIP_PKGPAYLOAD)

$(MANIFEST): $(BUILDETC)
	@echo "$$MANIFEST_TEXT" > $(MANIFEST)

# Permissions on the etc directory are a little more restrictive.
$(BUILDETC): $(BUILDSRC)
	mkdir -p $(BUILDETC)
	chmod 750 $(BUILDETC)

$(PKGDIR):
	mkdir -p $(PKGDIR)

$(BUILDSRC): $(BUILDDIR)
	mkdir -p $(BUILDSRC)

$(BUILDDIR): $(BUILDROOT)
	mkdir -p $(BUILDDIR)

# This is just to clean up after the build process is done so all
# we're left with is the final product.  Intended to be run *after*
# a build.
cleanup:
	rm -rf $(BUILDDIR)
	rm -f $(PKGINSTALLER) $(PKGPAYLOAD)

# This is to clean the slate; make sure gmake isn't picking up on
# some old version, in other words.  Intended to be run *before*
# a build.
clean:
	rm -rf pkg/*
	rm -rf $(BUILDDIR)

