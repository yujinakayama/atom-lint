{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'
LinterError = require '../linter-error'
util = require '../util'

DIAGNOSTIC_PATTERN = ///
^(.+):(\d+):(\d+):\s*(\d+):(\d+) # file / line1 / column1 / line2 / column2
\s*([^:]+)\s*: # severity
\s*([^]+) # message
///

module.exports =
class Rustc
  @canonicalName = 'rustc'

  constructor: (@filePath) ->

  run: (callback) ->
    @runRustc (error, violations) ->
      if error?
        callback(error)
      else
        callback(null, violations)

  runRustc: (callback) ->
    runner = new CommandRunner(@buildCommand())

    runner.run (error, result) =>
      return callback(error) if error?

      if result.exitCode == 0 || result.exitCode == 101
        violations = @parseDiagnostics(result.stderr)
        callback(null, violations)
      else
        callback(new LinterError("rustc exited with code #{result.exitCode}", result))

  parseDiagnostics: (log) ->
    lines = log.split('\n')

    for line in lines
      continue unless matches = line.match(DIAGNOSTIC_PATTERN)
      [_, _, lineNumber, columnNumber, lineNumber2, columnNumber2, severity, message] = matches
      continue if severity == 'note'

      startPoint = new Point(parseInt(lineNumber - 1), parseInt(columnNumber - 1))
      endPoint = new Point(parseInt(lineNumber2 - 1), parseInt(columnNumber2 - 1))
      bufferRange = new Range(startPoint, endPoint)

      new Violation(severity, bufferRange, message)

  buildCommand: ->
    command = []

    userRustcPath = atom.config.get('atom-lint.rustc.path')

    if userRustcPath?
      command.push(userRustcPath)
    else
      command.push('rustc')

    command.push('--parse-only')
    command.push(@filePath)
    command
