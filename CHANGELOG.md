# Changelog

## Development

## v0.8.1

* [#30](https://github.com/yujinakayama/atom-lint/issues/30): Merge `PATH` and `GEM_PATH` of the login shell and the shell where Atom was launched when running command so that shell-instance-specific `PATH` (e.g. RVM's gemset) can be used. ([@yujinakayama])

## v0.8.0

* [#21](https://github.com/yujinakayama/atom-lint/issues/21): Add Puppet support via puppet-lint. ([@yujinakayama])
* [#27](https://github.com/yujinakayama/atom-lint/pull/27): Add CSS support via CSSLint. ([@jonrohan][])
* [#28](https://github.com/yujinakayama/atom-lint/pull/28): Add SCSS support via SCSS-Lint. ([@jonrohan][])
* [#25](https://github.com/yujinakayama/atom-lint/issues/25): Allow to disable linting on specific files with configuration. ([@yujinakayama])
* Rerun lint when the file was reloaded with modification by another process. ([@yujinakayama])
* Improve tooltip style. ([@yujinakayama])
* Tweak position of the icons in the status bar. ([@yujinakayama])
* Display a message in the status bar when the current active linter is not installed. ([@yujinakayama])

## v0.7.0

* [#8](https://github.com/yujinakayama/atom-lint/issues/8): Display current active linter name and violation summary in the status bar. ([@yujinakayama])

## v0.6.0

* [#23](https://github.com/yujinakayama/atom-lint/pull/23): Add Go support via gc. ([@moshee][])

## v0.5.2

* [#19](https://github.com/yujinakayama/atom-lint/issues/19), [#20](https://github.com/yujinakayama/atom-lint/issues/20): Fix `Uncaught TypeError: Cannot call method 'sort' of undefined` on failure of linting. ([@yujinakayama][])

## v0.5.1

* Fix a bug where sometimes style of HLint results in tooltip were not applied. ([@yujinakayama][])

## v0.5.0

* [#16](https://github.com/yujinakayama/atom-lint/pull/16): Support multiline in tooltips. ([@x0l][])
* [#18](https://github.com/yujinakayama/atom-lint/pull/18): Add CoffeeLint support. ([@x0l][])
* Markup HLint results in tooltip. ([@yujinakayama][])

## v0.4.1

* Minimize additional startup time of Atom caused by atom-lint. ([@yujinakayama][])

## v0.4.0

* [#10](https://github.com/yujinakayama/atom-lint/pull/10): Add Haskell support via HLint. ([@x0l][])
* [#11](https://github.com/yujinakayama/atom-lint/pull/11): Add JavaScript support via JSHint. ([@benjohnson][])
* Add “Move to Next/Previous Violation”. ([@yujinakayama][])
* Fix a bug where linters were possibly run multiple times on a save. ([@yujinakayama][])
* Fix an odd animation on red violation arrows when the editor was clicked. ([@yujinakayama][])

## v0.3.0

* [#9](https://github.com/yujinakayama/atom-lint/pull/9): Add Python support via flake8. ([@danielgtaylor][])

## v0.2.0

* Display violation marks for each line on gutter. ([@yujinakayama])
* Fix wrong use of key for offenses in RuboCop's JSON result. ([@yujinakayama])

## v0.1.2

* [#1](https://github.com/yujinakayama/atom-lint/issues/1): Use `PATH` of the login shell even if Atom is launched from Finder or Dock so that executable `rubocop` can be found properly. ([@yujinakayama])
* [#1](https://github.com/yujinakayama/atom-lint/issues/1): Use config `atom-lint.rubocop.path` as an executable path for `rubocop` if it's set. ([@yujinakayama])

## v0.1.1

* Fix broken image in README. ([@yujinakayama])

## v0.1.0

* Initial release. ([@yujinakayama])

[@yujinakayama]: https://github.com/yujinakayama
[@danielgtaylor]: https://github.com/danielgtaylor
[@x0l]: https://github.com/x0l
[@benjohnson]: https://github.com/benjohnson
[@moshee]: https://github.com/moshee
[@jonrohan]: https://github.com/jonrohan
