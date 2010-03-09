PLUGIN=check_ssl_cert
VERSION=`cat VERSION`
DIST_DIR=$(PLUGIN)-$(VERSION)
DIST_FILES=AUTHORS COPYING ChangeLog INSTALL Makefile NEWS README TODO VERSION $(PLUGIN) $(PLUGIN).spec

dist: version_check
	rm -rf $(DIST_DIR) $(DIST_DIR).tar.gz
	mkdir $(DIST_DIR)
	cp $(DIST_FILES) $(DIST_DIR)
	tar cfz $(DIST_DIR).tar.gz  $(DIST_DIR)
	tar cfj $(DIST_DIR).tar.bz2 $(DIST_DIR)

install:
	mkdir -p $(DESTDIR)
	install -m 755 $(PLUGIN) $(DESTDIR)

version_check:
	VERSION=`cat VERSION`
	grep -q "VERSION\ *=\ *[\'\"]*$(VERSION)" $(PLUGIN)
	grep -q "^%define\ version\ $(VERSION)" $(PLUGIN).spec

clean:
	rm -f *~

# File version information:
# $Id: AUTHORS 1103 2009-12-07 07:49:19Z corti $
# $Revision: 1103 $
# $HeadURL: https://svn.id.ethz.ch/nagios_plugins/check_updates/AUTHORS $
# $Date: 2009-12-07 08:49:19 +0100 (Mon, 07 Dec 2009) $
