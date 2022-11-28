# Wrapper for make which do not support ifdef
#
# See: https://stackoverflow.com/questions/45342191/the-make-on-freebsd-doesnt-support-ifdef-directives
#

GNUMAKE?= gmake

all:
	${GNUMAKE} $@

.DEFAULT:
	${GNUMAKE} $@

.PHONY: all test install
