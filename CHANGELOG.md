# Changelog

## Development

## v0.20.1

* [#114](https://github.com/yujinakayama/atom-lint/issues/114): Fix error `Uncaught TypeError: Cannot read property 'previous' of undefined` with Atom 0.165.0. ([@yujinakayama])
* [#113](https://github.com/yujinakayama/atom-lint/issues/113): Fix possible error on parsing Checkstyle format XML. ([@yujinakayama])

## v0.20.0

* [#96](https://github.com/yujinakayama/atom-lint/pull/96): Allow specifying a config file for `flake8` via config `atom-lint.flake8.configPath`. ([@anaconda])

## v0.19.2

* Fix an issue where no information is displayed on the status bar when a new editor tab is opened on Atom 0.125.0. ([@yujinakayama])

## v0.19.1

* Fix an error when environment variable `PATH` is not set. ([@yujinakayama])

## v0.19.0

* [#52](https://github.com/yujinakayama/atom-lint/issues/52): Redesign handling of environment variables to handle 100% CPU usage issue. ([@yujinakayama])

## v0.18.0

* Add basic support for Windows. ([@guillaume86])
* Use Decoration API for gutter markers instead of the deprecated `EditorView::removeClassFromAllLines`. This drops the support for non-React editors. ([@yujinakayama])
* Improve violation message mark-up. ([@yujinakayama])

## v0.17.0

* Always run linters in the current project root directory. ([@richrace])
* Run RuboCop on RSpec syntax sources. ([@richrace])
* Fix crash when line numbers and indent guide are hidden. ([@raviraa])
* Disable automatic `.clang-complete` discovery feature temporarily. ([@yujinakayama])

## v0.16.1

* Fix an inconsistent view layout when `lint:toggle-violation-metadata` is run. ([@yujinakayama])

## v0.16.0

* Add support for displaying violation metadata in the tooltip. ([@yujinakayama])
* Add new configuration `atom-lint.showViolationMetadata` for switching metadata display in tooltip. ([@yujinakayama])
* Add new keymap `lint:toggle-violation-metadata` (Ctrl-Alt-M) for toggling configuration `atom-lint.showViolationMetadata`. ([@yujinakayama])
* [#82](https://github.com/yujinakayama/atom-lint/pull/82): Display RuboCop's cop names as metadata. ([@yujinakayama])
* Fix a bug where global toggling was executed twice for a `lint:toggle` command invocation after `atom-lint` is deactivated and then re-activated. ([@yujinakayama])
* Handle deprecation warning “The option `invalidation` is deprecated, use `invalidate` instead”. ([@yujinakayama])

## v0.15.1

* [#83](https://github.com/yujinakayama/atom-lint/issues/83): Specify `pathwatcher` package dependency tentatively to solve incompatibility issue with Atom 0.121.0 on installation of `atom-lint`. ([@yujinakayama])

## v0.15.0

* [#81](https://github.com/yujinakayama/atom-lint/issues/81): Update `clang-flags` npm module dependency to `^0.1.2` and required Atom version to `>=0.121.0` due to an breaking change in Atom 0.121.0. ([@yujinakayama])

## v0.14.5

* Conform to the change of exit code in SCSSLint 0.26. ([@yujinakayama])

## v0.14.4

* [#80](https://github.com/yujinakayama/atom-lint/pull/80): Fix a bug where fetching login shell's environment variables fails when zsh option `CLOBBER` is unset and a linter is run twice at the same time on launch of Atom. ([@yujinakayama])
* [#80](https://github.com/yujinakayama/atom-lint/pull/80): Fallback to Atom's environment variables rather than empty ones when failed fetching login shell's ones. ([@yujinakayama])
* [#80](https://github.com/yujinakayama/atom-lint/pull/80): Avoid wasteful double linting on launch. ([@yujinakayama])

## v0.14.3

* [#80](https://github.com/yujinakayama/atom-lint/pull/80): Fix a bug that couldn't find `HOME` environment using RuboCop. ([@rochefort])

## v0.14.2

* Fix a bug where linters could not be run when the login shell is zsh and zsh option `CLOBBER` is unset. ([@yujinakayama])

## v0.14.1

* Fix regression of RuboCop execution in 0.14.0. ([@yujinakayama])

## v0.14.0

* Dump detailed debug outputs on linter errors. ([@yujinakayama])

## v0.13.0

* [#70](https://github.com/yujinakayama/atom-lint/pull/70): Detect project-specific Clang flags automatically. ([@Kev])
* Fix bug in handling of project root directory in `erlc`. ([@yujinakayama])

## v0.12.0

* [#59](https://github.com/yujinakayama/atom-lint/pull/59): Add Erlang support via `erlc`. ([@bryanhunter])
* [#55](https://github.com/yujinakayama/atom-lint/pull/55): Add configuration `atom-lint.csslint.rules` which allows you to customize CSSLint rules. ([@elrolito])

## v0.11.4

* [#58](https://github.com/yujinakayama/atom-lint/pull/58): Address deprecation warning “parameter --checkstyle is deprecated. Use --reporter checkstyle instead” in CoffeeLint. ([@skevy])

## v0.11.3

* Fix a bug where singlequotes used as apostrophe in violation messages were marked up as code snippets. ([@yujinakayama])

## v0.11.2

* [#45](https://github.com/yujinakayama/atom-lint/issues/45): Fix a bug where the tooltip was cut off by the top of the editor when the file has only a few lines. ([@yujinakayama])

## v0.11.1

* Fix a bug where violation highlights weren't placed properly when the editor (tab) is not active and the file is reloaded by a modification by another process. ([@yujinakayama])

## v0.11.0

* [#44](https://github.com/yujinakayama/atom-lint/pull/44): Add Rust support via rustc. ([@shtirlic])
* Beautify and mark up violation messages. ([@yujinakayama])

## v0.10.1

* [#42](https://github.com/yujinakayama/atom-lint/issues/42): Fix error `Uncaught ReferenceError: _ is not defined` when some violations that are currently out of sight in the editor scroll view are moved by a modification (e.g. insertion of a line at beginning of the file). ([@yujinakayama])

## v0.10.0

* [#34](https://github.com/yujinakayama/atom-lint/issues/34): Support column range highlight for RuboCop offenses. ([@yujinakayama])
* [#40](https://github.com/yujinakayama/atom-lint/pull/40): Add C/C++/Objective-C support via Clang. ([@wesbland])
* Violation highlight now follows source modification. ([@yujinakayama])
* Fix strange appearance of non-related tooltips on modification. ([@yujinakayama])

## v0.9.0

* Add shell script support via ShellCheck. ([@yujinakayama])
* Allow to show tooltips with mouseover on a violation character. ([@yujinakayama])
* Place tooltip smartly according to the violation position in the editor. ([@yujinakayama])
* Show tooltip if the cursor is at a violation on open and on modification by another process. ([@yujinakayama])
* Fix a bug causing useless beep on **Move to Previous/Next Violation** after once atom-lint enabled again by toggling. ([@yujinakayama])
* [#33](https://github.com/yujinakayama/atom-lint/issues/33): Fix strange shadow of tooltip with Atom themes that don't have the Less variable `@syntax-background-color`. ([@yujinakayama])

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
[@wesbland]: https://github.com/wesbland
[@shtirlic]: https://github.com/shtirlic
[@skevy]: https://github.com/skevy
[@bryanhunter]: https://github.com/bryanhunter
[@elrolito]: https://github.com/elrolito
[@Kev]: https://github.com/Kev
[@rochefort]: https://github.com/rochefort
[@richrace]: https://github.com/richrace
[@raviraa]: https://github.com/raviraa
[@guillaume86]: https://github.com/guillaume86
[@anaconda]: https://github.com/anaconda
