[![Build Status](https://travis-ci.org/yujinakayama/atom-lint.svg?branch=master)](https://travis-ci.org/yujinakayama/atom-lint)

# Atom-Lint

Generic code linting support for [Atom](https://atom.io).

![Screenshot](https://cloud.githubusercontent.com/assets/83656/2719884/196c7e02-c568-11e3-8455-4ee4ba095752.png)

## Supported Linters

More linters will be supported in the future.
* [RuboCop](https://github.com/bbatsov/rubocop) for Ruby
* [flake8](https://flake8.readthedocs.org/) for Python
* [HLint](http://community.haskell.org/~ndm/hlint/) for Haskell
  (Installation of [language-haskell](https://atom.io/packages/language-haskell) package is required)
* [JSHint](http://www.jshint.com/docs/) for JavaScript
* [CoffeeLint](http://www.coffeelint.org/) for CoffeeScript
* [gc](http://golang.org/cmd/gc/) for Go
* [CSSLint](https://github.com/stubbornella/csslint) for CSS
* [SCSS-Lint](https://github.com/causes/scss-lint) for SCSS
* [puppet-lint](http://puppet-lint.com) for Puppet
  (Installation of [language-puppet](https://atom.io/packages/language-puppet) package is required)
* [ShellCheck](https://github.com/koalaman/shellcheck) for shell script
* [Clang](http://clang.llvm.org) for C/C++/Objective-C
* [rustc](http://www.rust-lang.org/) for Rust
  (Installation of [language-rust](https://atom.io/packages/language-rust) package is required)
* [erlc](http://erlang.org/doc/man/erlc.html) for Erlang
  (Installation of [language-erlang](https://atom.io/packages/language-erlang) package is required)

## Features

* Seamless integration with Atom as if it's a built-in package.
* Code highlighting – you don't need to move your eyes from the code to see the violations.
* Clean UI – it honors the colors of your favorite Atom theme.

## Installation

```bash
$ apm install atom-lint
```

If the current Atom has been launched via GUI (e.g. Dock/Finder on OS X),
once quit and re-launch it from your shell with the `atom` command.
This is required only once and important to handle the `PATH` environment variable properly.
See [Linter Executable Paths](#linter-executable-paths) for more details.

## Usage

Your source will be linted on open and on save automatically.
The detected violations will be displayed as arrows in the editor.
You can see the detail of the violation by moving the cursor to it.

## Keymaps

* `Ctrl-Alt-L`: Global toggle
* `Ctrl-Alt-[`: Move to Previous Violation
* `Ctrl-Alt-]`: Move to Next Violation
* `Ctrl-Alt-M`: Toggle Violation Metadata (toggle configuration `atom-lint.showViolationMetadata`)

Also you can customize keymaps by editing `~/.atom/keymap.cson` (choose **Open Your Keymap** in **Atom** menu):

```coffeescript
'.workspace':
  'ctrl-alt-l': 'lint:toggle'
  'ctrl-alt-m': 'lint:toggle-violation-metadata'
'.editor':
  'ctrl-alt-[': 'lint:move-to-previous-violation'
  'ctrl-alt-]': 'lint:move-to-next-violation'
```

See [Customizing Atom](https://atom.io/docs/latest/customizing-atom#customizing-key-bindings) for more details.

## Configuration

You can configure Atom-Lint by editing `~/.atom/config.cson` (choose **Open Your Config** in **Atom** menu):

```coffeescript
# Some other settings...
'atom-lint':
  'ignoredNames': [
    'tmp/**'
  ]
  'showViolationMetadata': true
  'clang':
    'path': '/path/to/bin/clang'
    'headerSearchPaths': ['/path/to/include','/path2/to/include']
    'mergeAtomLintConfigIntoAutoDiscoveredFlags': true # If you want to add defaults to discovered project-specific clang flags
  'coffeelint':
    'path': '/path/to/bin/coffeelint'
  'csslint':
    'path': '/path/to/bin/csslint'
    'rules': # See http://csslint.net/about.html for rules
      'ignore': [
        'adjoining-classes'
      ]
      'errors': []
      'warnings': []
  'erlc':
    'path': '/path/to/bin/erlc'
  'flake8':
    'path': '/path/to/bin/flake8'
    'configPath': '/path/to/your/config' # Passed to flake 8 via --config option
  'gc':
    'path': '/path/to/bin/go'
  'hlint':
    'path': '/path/to/bin/hlint'
  'jshint':
    'path': '/path/to/bin/jshint'
  'puppet-lint':
    'path': '/path/to/bin/puppet-lint'
  'rubocop':
    'path': '/path/to/bin/rubocop'
  'rustc':
    'path': '/path/to/bin/rustc'
  'scss-lint':
    'path': '/path/to/bin/scss-lint'
  'shellcheck':
    'path': '/path/to/bin/shellcheck'
```

### Linter Executable Paths

* `atom-lint.LINTER.path`

Normally you can omit this setting.

There's an issue that
environment variables in Atom varies depending on whether it's launched via shell or GUI.
If it's launched via GUI, it cannot get the environment variables set in your shell rc files like `PATH`.
To handle this issue,
when Atom is launched via shell, Atom-Lint automatically saves the environment variables,
and from then on it will use the saved variables on linter invocation even if Atom is launched via GUI.

If you're using a language version manager such as [rbenv](https://github.com/sstephenson/rbenv),
linters need be installed in the default/global environment of the version manager
(i.e. the environment where you opened a new terminal).
If you need to use a non-default executable, use this setting.

### File Patterns to Ignore

* `atom-lint.ignoredNames` (Global)
* `atom-lint.LINTER.ignoredNames` (Per Linter)

You can specify lists of file patterns to disable linting.
The global patterns and the per linter patterns will be merged on evaluation
so that you can make these lists DRY.

```coffeescript
'atom-lint':
  'ignoredNames': [
    'tmp/**'
  ]
  'rubocop':
    'ignoredNames': [
      'vendor/**'
      'db/schema.rb'
    ]
```

With the above example, all of `tmp/**`, `vendor/**` and `db/schema.db` are ignored when RuboCop is active.

The pattern must be relative to the project root directory.
The pattern format is basically the same as the shell expansion and `.gitignore`.
See [`minimatch`](https://github.com/isaacs/minimatch) for more details.

### Clang Specific Configuration

#### Header Search Paths

* `atom-lint.clang.headerSearchPaths`

Specify additional header search paths. These paths are passed to `clang` with `-I` option.

#### Project-Specific Flags and Atom-Lint's configuration

**This feature is temporarily disabled now.**

* `atom-lint.clang.mergeAtomLintConfigIntoAutoDiscoveredFlags`

Atom-Lint automatically picks up your project-specific compiler flags
(currenly [`.clang-complete` format](https://github.com/Rip-Rip/clang_complete/blob/master/doc/clang_complete.txt) is supported)
via [`clang-flags`](https://github.com/Kev/clang-flags) module.
By default, if a custom flag file is found, Atom-Lint uses only the flags specified in the file
and ignores other configuration (e.g. the `headerSearchPaths` above).
If you want to use both the project-specific flags and Atom-Lint's configuration,
set this `mergeAtomLintConfigIntoAutoDiscoveredFlags` to `true`.

### CSSLint Specific Configuration

#### Custom Rules

* `atom-lint.csslint.rules.errors`
* `atom-lint.csslint.rules.warnings`
* `atom-lint.csslint.rules.ignore`

These are passed to `csslint` with [`--errors`, `--warnings` or `--ignore` option](https://github.com/CSSLint/csslint/wiki/Command-line-interface#options).

## Contributors

Here's a [list](https://github.com/yujinakayama/atom-lint/graphs/contributors) of all contributors to Atom-Lint.

## Changelog

Atom-Lint's changelog is available [here](https://github.com/yujinakayama/atom-lint/blob/master/CHANGELOG.md).

## License

Copyright (c) 2014 Yuji Nakayama

See the [LICENSE.txt](https://github.com/yujinakayama/atom-lint/blob/master/LICENSE.txt) for details.
