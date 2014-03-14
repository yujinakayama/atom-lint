{Range, Point} = require 'atom'
_ = require 'lodash'
CommandRunner = require '../command-runner'
Violation = require '../violation'

module.exports =
class HLint
  constructor: (@filePath, @textContents=null) ->

  run: (callback) ->
    if @textContents?
      # No idea how to feed HLint stdin, so we'll just ignore those
      # requests
      return
    @runHLint (error, violations) ->
      if error?
        callback(error)
      else
        callback(null, violations)

  runHLint: (callback) ->
    runner = new CommandRunner(@constructCommand())

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
        callback(new Error("Process exited with code #{result.exitCode}"))

  constructCommand: ->
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

  getHTML: ->
    matches = @message.match(HLintViolation.MESSAGE_PATTTERN)
    return null unless matches?
    [match, message, foundCode, alternativeCode] = matches
    HTML = _.escape(@punctuate(message))
    HTML += '<div class="attachment">'
    HTML += '<p class="code-label">Found:</p>'
    HTML += @formatSnippet(foundCode)
    HTML += '<p class="code-label">Why not:</p>'
    HTML += @formatSnippet(alternativeCode)
    HTML += '</div>'
    HTML

  punctuate: (string) ->
    if string.match(/[\.,:;]$/)
      string
    else
      string + '.'

  formatSnippet: (snippet) ->
    lines = snippet.split('\n')
    unindentedLines = for line in lines
      line.slice(2)
    unindentedSnippet = unindentedLines.join('\n')
    "<pre>#{_.escape(unindentedSnippet)}</pre>"
