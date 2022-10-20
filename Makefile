PLUGIN=check_ssl_cert
VERSION=`cat VERSION`
DIST_DIR=$(PLUGIN)-$(VERSION)

# files to be included in the distribution
DIST_FILES=AUTHORS.md COPYING.md ChangeLog INSTALL.md Makefile NEWS.md README.md VERSION $(PLUGIN) $(PLUGIN).spec COPYRIGHT.md ${PLUGIN}.1 CITATION.cff check_ssl_cert.completion

# this year
YEAR=`date +"%Y"`

# file to be checked for formatting
FORMATTED_FILES=test/unit_tests.sh ChangeLog INSTALL.md Makefile VERSION $(PLUGIN) $(PLUGIN).spec COPYRIGHT.md ${PLUGIN}.1 .github/workflows/* utils/*.sh check_ssl_cert.completion

# shell scripts (to be checked with ShellCheck)
SCRIPTS=check_ssl_cert test/*.sh utils/*.sh

XATTRS_OPTION := $(shell if tar --help 2>&1 | grep -q bsdtar ; then echo '--no-xattrs' ; fi )

.PHONY: install clean test rpm distclean check version_check codespell

# checks if the version is updated in all the files
version_check: CITATION.cff
	echo "Checking version $(VERSION)"
	grep -q "VERSION *= *[\'\"]*$(VERSION)" $(PLUGIN)
	grep -q "^%global version *$(VERSION)" $(PLUGIN).spec
	grep -q -F -- "- $(VERSION)-" $(PLUGIN).spec
	grep -q "\"$(VERSION)\"" $(PLUGIN).1
	grep -q -F "${VERSION}" NEWS.md
	grep -q  "^version: ${VERSION}" CITATION.cff
	echo "Version check: OK"

# builds the release files
dist: version_check CITATION.cff
	rm -rf $(DIST_DIR) $(DIST_DIR).tar.gz
	mkdir $(DIST_DIR)
	cp -r $(DIST_FILES) $(DIST_DIR)
# avoid to include extended attribute data files
# see https://superuser.com/questions/259703/get-mac-tar-to-stop-putting-filenames-in-tar-archives
	export COPY_EXTENDED_ATTRIBUTES_DISABLE=true; \
	export COPYFILE_DISABLE=true; \
	tar $(XATTRS_OPTION) -c -z -f $(DIST_DIR).tar.gz  $(DIST_DIR) && \
	tar $(XATTRS_OPTION) -c -j -f $(DIST_DIR).tar.bz2 $(DIST_DIR)

install:
ifndef DESTDIR
	echo "Please define DESTDIR and MANDIR variables with the installation targets"
	echo "e.g, make DESTDIR=/nagios/plugins/dir MANDIR=/nagios/plugins/man/dir install"
else
	mkdir -p $(DESTDIR)
	install -m 755 $(PLUGIN) $(DESTDIR)
	mkdir -p ${MANDIR}/man1
	install -m 644 ${PLUGIN}.1 ${MANDIR}/man1/
endif
ifdef COMPLETIONDIR
	mkdir -p $(COMPLETIONDIR)
	install -m 644 check_ssl_cert.completion $(COMPLETIONDIR)/check_ssl_cert
endif

COMPLETIONS_DIR := $(shell pkg-config --variable=completionsdir bash-completion)
install_bash_completion:
ifdef COMPLETIONS_DIR
	cp check_ssl_cert.completion $(COMPLETIONS_DIR)/check_ssl_cert
endif

CITATION.cff: AUTHORS.md VERSION NEWS.md
	./utils/update_citation.sh

# we check for tabs
# and remove trailing blanks
formatting_check:
	! grep -q '[[:blank:]]$$' $(FORMATTED_FILES)

CODESPELL := $(shell command -v codespell 2> /dev/null )
# spell check
codespell:
ifndef CODESPELL
	echo "no codespell installed"
else
	codespell \
	.
endif

SHFMT := $(shell command -v shfmt 2> /dev/null)
format:
ifndef SHFMT
	echo "No shfmt installed"
else
# -p POSIX
# -w write to file
# -s simplify
# -i 4 indent with 4 spaces
	shfmt -p -w -s -i 4 $(SCRIPTS)
	shfmt -ln bash -w -s -i 4 check_ssl_cert.completion
endif

clean:
	find . -name "*~" -delete
	find . -name "*.bak" -delete
	rm -rf rpmroot

distclean: clean
	rm -rf check_ssl_cert-[0-9]*
	rm -f *.crt
	rm -f *.error
	rm -f headers.txt

check: test

SHELLCHECK := $(shell command -v shellcheck 2> /dev/null)
SHUNIT := $(shell if [ -z "${SHUNIT2}" ] ; then command -v shunit2 2> /dev/null || if [ -x /usr/share/shunit2/shunit2 ] ; then echo /usr/share/shunit2/shunit2 ; fi; else echo "${SHUNIT2}"; fi )

distcheck: disttest
disttest: dist formatting_check shellcheck codespell
	./utils/check_documentation.sh
	man ./check_ssl_cert.1 > /dev/null

test: formatting_check shellcheck
ifndef SHUNIT
	echo "No shUnit2 installed: see README.md"
	exit 1
else
	( export SHUNIT2=$(SHUNIT) && export LC_ALL=C && cd test && ./unit_tests.sh )
endif


shellcheck:
ifndef SHELLCHECK
	echo "No shellcheck installed: skipping check"
else
	if shellcheck --help 2>&1 | grep -q -- '-o ' ; then shellcheck -o all $(SCRIPTS) ; else shellcheck $(SCRIPTS) ; fi
endif

rpm: dist
	mkdir -p rpmroot/SOURCES rpmroot/BUILD
	cp $(DIST_DIR).tar.gz rpmroot/SOURCES
	rpmbuild --define "_topdir `pwd`/rpmroot" -ba check_ssl_cert.spec
