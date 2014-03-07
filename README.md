# Atom-Lint

Generic code linting support for [Atom](https://atom.io).

![Screenshot](https://raw.github.com/yujinakayama/atom-lint/master/doc/screenshot.png)

Atom-Lint is currently in alpha development.

## Supported Linters

More linters will be supported in the future.

* [RuboCop](https://github.com/bbatsov/rubocop) for Ruby

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
```

### `atom-lint.rubocop.path`

Specify an executable path for `rubocop` command.

By default Atom-Lint automatically refers the environement variable `PATH` of your login shell
if it's `bash` or `zsh`, and invokes `rubocop` command.
If you got a problem with `PATH`, use this setting.

## License

Copyright (c) 2014 Yuji Nakayama

See the [LICENSE.txt](LICENSE.txt) for details.
