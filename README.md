# Atom-Lint

Generic code linting support for [Atom](https://atom.io).

![Screenshot](https://raw.github.com/yujinakayama/atom-lint/master/doc/screenshot.png)

Atom-Lint is currently in alpha development.

## Supported Linters

More linters will be supported in the future.

* [RuboCop](https://github.com/bbatsov/rubocop) for Ruby
* [flake8](https://flake8.readthedocs.org/) for Python
* [JSHint](http://www.jshint.com/docs/) for JavaScript

## Installation

```bash
$ apm install atom-lint
```

## Usage

Your source will be linted on open and on save automatically,
and the detected violations will be displayed as arrows in the editor.
You can see the detail of the violation by moving the cursor to it.

### Keymaps

* `Ctrl-Alt-L` for global toggle

## Configuration

You can configure Atom-Lint by editing `config.cson` file (choose **Open Your Config** in **Atom** menu):

```cson
# Some other settings...
'atom-lint':
  'rubocop':
    'path': '/path/to/bin/rubocop'
  'flake8':
    'path': '/path/to/bin/flake8'
  'jshint':
    'path': '/path/to/bin/jshint'
```

### `atom-lint.rubocop.path`

Specify an executable path for `rubocop` command.

By default Atom-Lint automatically refers the environement variable `PATH` of your login shell
if it's `bash` or `zsh`, and invokes `rubocop` command.
If you got a problem with `PATH`, use this setting.

### `atom-lint.flake8.path`

Specify an executable path for `flake8` command. Similar to the `rubocop` path argument described above.

### `atom-lint.jshint.path`

Specify an executable path for `jshint` command. Similar to the `rubocop` path argument described above.

## Contributors

Here's a [list](https://github.com/yujinakayama/atom-lint/graphs/contributors) of all contributors to Atom-Lint.

## License

Copyright (c) 2014 Yuji Nakayama

See the [LICENSE.txt](LICENSE.txt) for details.
