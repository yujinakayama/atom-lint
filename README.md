[![Build Status](https://travis-ci.org/yujinakayama/atom-lint.png?branch=master)](https://travis-ci.org/yujinakayama/atom-lint)

# Atom-Lint

Generic code linting support for [Atom](https://atom.io).

![Screenshot](https://raw.github.com/yujinakayama/atom-lint/master/doc/screenshot.png)

Atom-Lint is currently in alpha development.

## Supported Linters

More linters will be supported in the future.

* [RuboCop](https://github.com/bbatsov/rubocop) for Ruby
* [flake8](https://flake8.readthedocs.org/) for Python
* [HLint](http://community.haskell.org/~ndm/hlint/) for Haskell
(Installation of [language-haskell](https://atom.io/packages/language-haskell) package is required)
* [JSHint](http://www.jshint.com/docs/) for JavaScript
* [CoffeeLint](http://www.coffeelint.org/) for CoffeeScript
* [gc](http://golang.org/cmd/gc/) for Go

## Installation

```bash
$ apm install atom-lint
```

## Usage

Your source will be linted on open and on save automatically,
and the detected violations will be displayed as arrows in the editor.
You can see the detail of the violation by moving the cursor to it.

## Keymaps

* `Ctrl-Alt-L`: Global toggle
* `Ctrl-Alt-[`: Move to Previous Violation
* `Ctrl-Alt-]`: Move to Next Violation

Also you can customize keymaps by editing `~/.atom/keymap.cson` (choose **Open Your Keymap** in **Atom** menu):

```cson
'.workspace':
  'ctrl-alt-l': 'lint:toggle'
'.editor':
  'ctrl-alt-[': 'lint:move-to-previous-violation'
  'ctrl-alt-]': 'lint:move-to-next-violation'
```

See **Customizing Key Bindings** in [Customizing Atom](https://atom.io/docs/latest/customizing-atom) for more details.

## Configuration

You can configure Atom-Lint by editing `~/.atom/config.cson` (choose **Open Your Config** in **Atom** menu):

```cson
# Some other settings...
'atom-lint':
  'coffeelint':
    'path': '/path/to/bin/coffeelint'
  'flake8':
    'path': '/path/to/bin/flake8'
  'gc':
    'path': '/path/to/bin/go'
  'hlint':
    'path': '/path/to/bin/hlint'
  'jshint':
    'path': '/path/to/bin/jshint'
  'rubocop':
    'path': '/path/to/bin/rubocop'
```

By default Atom-Lint automatically refers the environement variable `PATH` of your login shell
if it's `bash` or `zsh`, and then invokes the command.
If you got a problem with `PATH`, use this setting.

## Contributors

Here's a [list](https://github.com/yujinakayama/atom-lint/graphs/contributors) of all contributors to Atom-Lint.

## License

Copyright (c) 2014 Yuji Nakayama

See the [LICENSE.txt](LICENSE.txt) for details.
