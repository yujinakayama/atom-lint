{Range, Point} = require 'atom'
_ = require 'lodash'
CommandRunner = require '../command-runner'
Violation = require '../violation'
LinterError = require '../linter-error'
util = require '../util'

module.exports =
class HLint
  @canonicalName = 'HLint'

  constructor: (@filePath) ->

  run: (callback) ->
    @runHLint (error, violations) ->
      if error?
        callback(error)
      else
        callback(null, violations)

  runHLint: (callback) ->
    runner = new CommandRunner(@buildCommand())

    runner.run (error, result) ->
      return callback(error) if error?

      if result.exitCode == 0 || result.exitCode == 1

        pattern = ///
          ^(.+):(\d+):(\d+):\s*  # file / line / col
          (Warning|Error):\s*
          ([^]+)
        ///

        violations = []
        items = result.stdout.split '\n\n'
        for item in items[...-1]
          [file, line, col, severity, msg] = item.match(pattern)[1..5]
          bufferPoint = new Point(parseInt(line) - 1, parseInt(col) - 1)
          bufferRange = new Range(bufferPoint, bufferPoint)
          violation = new HLintViolation(severity.toLowerCase(), bufferRange, msg)
          violations.push(violation)

        callback(null, violations)
      else
        callback(new LinterError("hlint exited with code #{result.exitCode}", result))

  buildCommand: ->
    command = []

    userHLintPath = atom.config.get('atom-lint.hlint.path')

    if userHLintPath?
      command.push(userHLintPath)
    else
      command.push('hlint')

    command.push(@filePath)
    command

class HLintViolation extends Violation
  # Error: Use unwords
  # Found:
  #   intercalate " "
  # Why not:
  #   unwords
  @MESSAGE_PATTTERN = ///
    ^(.+)\n
    Found:\n
    (\x20{2}[\S\s]+)
    Why\x20not:\n
    (\x20{2}[\S\s]+)
  ///

  constructor: (severity, bufferRange, message) ->
    matches = message.match(HLintViolation.MESSAGE_PATTTERN)
    [_match, message, @foundCode, @alternativeCode] = matches if matches?
    super(severity, bufferRange, message)

  getAttachmentHTML: ->
    return null unless @foundCode?
    '<figure>' +
      '<figcaption>Found:</figcaption>' +
      @formatSnippet(@foundCode) +
    '</figure>' +
    '<figure>' +
      '<figcaption>Why not:</figcaption>' +
      @formatSnippet(@alternativeCode) +
    '</figure>'

  formatSnippet: (snippet) ->
    lines = snippet.split('\n')
    unindentedLines = for line in lines
      line.slice(2)
    unindentedSnippet = unindentedLines.join('\n')
    "<pre>#{_.escape(unindentedSnippet)}</pre>"
