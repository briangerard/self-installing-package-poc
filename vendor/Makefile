# The value for __DESTROOT__ should be filled in prior to running
# gmake.  Typically, this will be done by the installation script.
# It will likely be set to the installation root /usr/local/our_stuff
# for a "live" install, or likely /var/tmp/test-our_stuff for a test
# installation.  This allows us to test the installation without
# destroying the live instance.
VENDOR_DIR = __DESTROOT__/vendor
VENDOR_LIB = $(VENDOR_DIR)/lib/perl5
export PERL5LIB = $(VENDOR_LIB)

JSON = JSON-2.94

define install_pm
	gzip -dc $(1).tar.gz | tar xf -
	cd $(1); \
		perl Makefile.PL INSTALL_BASE=$(VENDOR_DIR) && \
		make && \
		make test && \
		make install
endef

all: $(JSON) cleanup

$(JSON): $(JSON).tar.gz
	$(call install_pm,$(JSON))

cleanup:
	/bin/rm -rf $(JSON)
