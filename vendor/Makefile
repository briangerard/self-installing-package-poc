# The value for __DESTROOT__ should be filled in prior to running
# gmake.  Typically, this will be done by the installation script.
# It will be set to the installation root /blah for a
# "live" install, or likely /blah for a test
# installation.  This allows us to test the installation without
# destroying the live instance.
VENDOR_DIR = ___DESTROOT__/vendor
VENDOR_LIB = $(VENDOR_DIR)/lib/perl5
export PERL5LIB = $(VENDOR_LIB)

JSON               = JSON-2.94
ExtUtils_MakeMaker = ExtUtils-MakeMaker-7.30
Test_Harness       = Test-Harness-3.39
Test_Simple        = Test-Simple-1.302106

define install_pm
	gzip -dc $(1).tar.gz | tar xf -
	cd $(1); \
		perl Makefile.PL INSTALL_BASE=$(VENDOR_DIR) && \
		gmake && \
		gmake test && \
		gmake install
endef

define install_without_tests
	gzip -dc $(1).tar.gz | tar xf -
	cd $(1); \
		perl Makefile.PL INSTALL_BASE=$(VENDOR_DIR) && \
		gmake && \
		gmake install
endef

define retest
	cd $(1); \
		gmake test
endef


all: $(JSON) cleanup

$(JSON): $(Test_Harness) $(JSON).tar.gz
	$(call retest,$(Test_Simple))
	$(call retest,$(ExtUtils_MakeMaker))
	$(call install_pm,$(JSON))

$(Test_Harness): $(Test_Simple) $(Test_Harness).tar.gz
	$(call install_pm,$(Test_Harness))

$(Test_Simple): $(ExtUtils_MakeMaker) $(Test_Simple).tar.gz
	$(call install_without_test,$(Test_Simple))

$(ExtUtils_MakeMaker): $(extUtils_MakeMaker).tar.gz
	$(call install_without_tests,$(ExtUtils_MakeMaker))

cleanup:
	/bin/rm -rf $(JSON) $(Test_Harness) $(Test_Simple) $(ExtUtils_MakeMaker)
