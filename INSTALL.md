# check\_ssl\_check

## Requirements

* [OpenSSL](https://www.openssl.org)
* [curl](https://curl.se)
* ```date```
* ```file```

## Optional dependencies

* check\_ssl\_cert requires [```expect```](http://en.wikipedia.org/wiki/Expect) or [```timeout```](https://man7.org/linux/man-pages/man1/timeout.1.html) to enable timeouts. If ```expect``` or ```timeout``` are not present on your system timeouts will be disabled.
* ```dig``` for DANE checks
* [nmap](https://nmap.org) for the disallowed protocols and cyphers checks
* ```expand`` for ```--info```
* ```tar``` and ```bzip2``` to build release packages
* ```ip``` or ```ifconfig``` to be able to use the ```-4``` and ```-6``` options

## Development

Following tools are required for development:

* [shUnit2](https://github.com/kward/shunit2) for the tests
* [shfmt](https://github.com/mvdan/sh) to format the source files
* [ShellCheck](https://www.shellcheck.net) for the code quality checks

## Installation

* Simply copy the plugin to your Nagios/Icinga plugin directory
* Use ```make install``` by  defining the ```DESTDIR``` and ```MANDIR``` variables with the installation targets. E.g, ```make DESTDIR=/nagios/plugins/dir MANDIR=/nagios/plugins/man/dir install```
