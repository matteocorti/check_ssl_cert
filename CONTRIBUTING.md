# How to contribute

## Submitting bugs

When reporting a bug please include as much information as possible. Include the output of the plugin with the `-verbose` and `-debug` options.

If possible give a real-life example that can be tested (e.g., a public host).

If you do not want that the host name is published a bug report, but the host is reachable from the internet, please send me the host name per email ([matteo@corti.li](mailto:matteo@corti.li)) so that I can test. I will keep the host name confidential.

## Submitting changes

* Always write clear log messages for your commits
* Check the code with [ShellCheck](https://www.shellcheck.net) (```make shellckeck```)
* Always format the code with [shfmt](https://github.com/mvdan/sh)
* Check the spelling with [codespell](https://github.com/codespell-project/codespell) (```make codespell```)
* Always log your changes in the ChangeLog file
* Always test the changes `make test` and be sure that all the tests are passed
* If possible write some tests to validate the changes you did to the plugin
