PLUGIN=check_ssl_cert
VERSION=`cat VERSION`
DIST_DIR=$(PLUGIN)-$(VERSION)
DIST_FILES=AUTHORS COPYING ChangeLog INSTALL Makefile NEWS README.md VERSION $(PLUGIN) $(PLUGIN).spec COPYRIGHT ${PLUGIN}.1 test
YEAR=`date +"%Y"`
MONTH_YEAR=`date +"%B, %Y"`
FORMATTED_FILES=test/unit_tests.sh AUTHORS COPYING ChangeLog INSTALL Makefile NEWS README.md VERSION $(PLUGIN) $(PLUGIN).spec COPYRIGHT ${PLUGIN}.1 .github/workflows/* doc_check.sh

dist: version_check formatting_check copyright_check shellcheck
	rm -rf $(DIST_DIR) $(DIST_DIR).tar.gz
	mkdir $(DIST_DIR)
	cp -r $(DIST_FILES) $(DIST_DIR)
	tar cfz $(DIST_DIR).tar.gz  $(DIST_DIR)
	tar cfj $(DIST_DIR).tar.bz2 $(DIST_DIR)

install:
	mkdir -p $(DESTDIR)
	install -m 755 $(PLUGIN) $(DESTDIR)
	mkdir -p ${MANDIR}/man1
	install -m 644 ${PLUGIN}.1 ${MANDIR}/man1/

version_check:
	grep -q "VERSION\ *=\ *[\'\"]*$(VERSION)" $(PLUGIN)
	grep -q "^%define\ version\ *$(VERSION)" $(PLUGIN).spec
	grep -q -- "- $(VERSION)-" $(PLUGIN).spec
	grep -q "\"$(VERSION)\"" $(PLUGIN).1
	grep -q "${VERSION}" NEWS
	grep -q "$(MONTH_YEAR)" $(PLUGIN).1
	echo "Version check: OK"

# we check for tabs
# and remove trailing blanks
formatting_check:
	! grep -q '\\t' check_ssl_cert test/unit_tests.sh
	! grep -q '[[:blank:]]$$' $(FORMATTED_FILES)

doc_check:
	./doc_check.sh

remove_blanks:
	sed -i '' 's/[[:blank:]]*$$//' $(FORMATTED_FILES)

clean:
	rm -f *~
	rm -rf rpmroot

distclean: clean
	rm -rf check_ssl_cert-[0-9]*
	rm -f *.crt
	rm -f *.error

test: dist
	( export SHUNIT2="$$(pwd)/shunit2/shunit2" && cd test && ./unit_tests.sh )

SHELLCHECK := $(shell command -v shellcheck 2> /dev/null)

shellcheck:
ifndef SHELLCHECK
	echo "No shellcheck installed: skipping test"
else
	if shellcheck --help 2>&1 | grep -q -- '-o\ ' ; then shellcheck -o all check_ssl_cert test/unit_tests.sh prepare_rpm.sh publish_release.sh ; else shellcheck check_ssl_cert test/unit_tests.sh prepare_rpm.sh publish_release.sh doc_check.sh ; fi
endif

copyright_check:
	grep -q "(c) Matteo Corti, 2007-$(YEAR)" README.md
	grep -q "Copyright (c) 2007-$(YEAR) Matteo Corti" COPYRIGHT
	grep -q "Copyright (c) 2007-$(YEAR) Matteo Corti <matteo@corti.li>" $(PLUGIN)
	echo "Copyright year check: OK"

rpm: dist
	mkdir -p rpmroot/SOURCES rpmroot/BUILD
	cp $(DIST_DIR).tar.gz rpmroot/SOURCES
	rpmbuild --define "_topdir `pwd`/rpmroot" -ba check_ssl_cert.spec



.PHONY: install clean test rpm distclean
