PLUGIN=check_ssl_cert
VERSION=`cat VERSION`
DIST_DIR=$(PLUGIN)-$(VERSION)
DIST_FILES=AUTHORS COPYING ChangeLog INSTALL Makefile NEWS README.md TODO VERSION $(PLUGIN) $(PLUGIN).spec COPYRIGHT ${PLUGIN}.1 test

dist: version_check
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
	VERSION=`cat VERSION`
	grep -q "VERSION\ *=\ *[\'\"]*$(VERSION)" $(PLUGIN)
	grep -q "^%define\ version\ *$(VERSION)" $(PLUGIN).spec
	grep -q -- "- $(VERSION)-" $(PLUGIN).spec
	grep -q "\"$(VERSION)\"" $(PLUGIN).1
	grep -q "${VERSION}" NEWS
	echo "Version check: OK"

clean:
	rm -f *~
	rm -rf rpmroot

test:
	( export SHUNIT2="$$(pwd)/shunit2/shunit2" && cd test && ./unit_tests.sh )

rpm: dist
	mkdir -p rpmroot/SOURCES rpmroot/BUILD
	cp $(DIST_DIR).tar.gz rpmroot/SOURCES
	rpmbuild --define "_topdir `pwd`/rpmroot" -ba check_ssl_cert.spec

.PHONY: install clean test rpm
