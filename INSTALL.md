# check\_ssl\_check

## Requirements

* ```bc```
* [curl](https://curl.se)
* ```date```
* ```file```
* ```host```
* [nmap](https://nmap.org)
* [OpenSSL](https://www.openssl.org)

## Optional dependencies

* check\_ssl\_cert requires [```expect```](http://en.wikipedia.org/wiki/Expect) or [```timeout```](https://man7.org/linux/man-pages/man1/timeout.1.html) to enable timeouts. If ```expect``` or ```timeout``` are not present on your system timeouts will be disabled.
* ```dig``` for
  * DANE checks
  * DNSSEC checks
* [gmake](https://www.gnu.org/software/make/) on [FreeBSD](https://www.freebsd.org)
* ```expand``` for ```--info```
* ```tar``` and ```bzip2``` to build release packages
* ```ip``` or ```ifconfig``` to be able to use the ```-4``` and ```-6``` options
* [nectcat](https://nc110.sourceforge.io) for ```--ignore-connection-state```
* Python 3.0 for the TDS (Tabular Data Stream) protocol check
* Java for KeyStore checks

## Development

Following tools are required for development:

* [shUnit2](https://github.com/kward/shunit2) for the tests
* [shfmt](https://github.com/mvdan/sh) to format the source files
* [ShellCheck](https://www.shellcheck.net) for the code quality checks
* [codespell](https://github.com/codespell-project/codespell) for the spelling checks
* ```dig``` for IPv6 tests

You can check the installed dependencies with the ```utils/check_deps.sh``` script.

## Installation

* You can run the plugin from the shell.
* If you want to install it systemwide, copy the plugin to a directory in the path, and ```check_ssl_cert.1``` in an appropriate directory in the ```$MANPATH```
* Simply copy the plugin to your Nagios/Icinga plugin directory (e.g., ```/usr/lib64/nagios/plugins/```)
* Use ```make install``` by  defining the ```DESTDIR``` and ```MANDIR``` variables with the installation targets. E.g, ```make DESTDIR=/nagios/plugins/dir MANDIR=/nagios/plugins/man/dir install``` or ```sudo make -E DESTDIR=/usr/local/bin MANDIR=/usr/local/man```
* To install the bash completion script run ```sudo make install_bash_completion``` (it will install the completion script in the directory defined by ```pkg-config --variable=completionsdir bash-completion```)
