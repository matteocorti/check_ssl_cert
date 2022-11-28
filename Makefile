GNUMAKE?= gmake

all:
	${GNUMAKE} $@

.DEFAULT:
	${GNUMAKE} $@

.PHONY: all test install
