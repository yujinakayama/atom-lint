{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'
LinterError = require '../linter-error'

# /Users/ssimon/code/eu4parser/source/structs/war.d(119:8)[warn]: Public declaration 'active' is undocumented.
DIAGNOSTIC_PATTERN = ///
^(.+)\((\d+):(\d+)\)  # file / line / column
\s*\[([^:]+)\]\s*: # severity
\s*([^]+) # message
///

module.exports =
class Dscanner
  @canonicalName = 'dscanner'

  constructor: (@filePath) ->

  run: (callback) ->
    @runDscanner (error, violations) ->
      if error?
        callback(error)
      else
        callback(null, violations)

  runDscanner: (callback) ->
    runner = new CommandRunner(@buildCommand())

    runner.run (error, result) =>
      return callback(error) if error?

      if result.exitCode == 0
        violations = @parseDiagnostics(result.stdout)
        callback(null, violations)
      else
        callback(new LinterError("dscanner exited with code #{result.exitCode}", result))

  parseDiagnostics: (log) ->
    lines = log.split('\n')

    for line in lines
      matches = line.match(DIAGNOSTIC_PATTERN)
      continue unless matches

      [_, _, lineNumber, columnNumber, severity, message] = matches
      severity = 'warning' if severity == 'warn'

      bufferPoint = new Point(parseInt(lineNumber) - 1, parseInt(columnNumber) - 1)
      bufferRange = new Range(bufferPoint, bufferPoint)
      new Violation(severity, bufferRange, message)

  buildCommand: ->
    command = []

    userDscannerPath = atom.config.get('atom-lint.dscanner.path')

    if userClangPath?
      command.push(userClangPath)
    else
      command.push('dscanner')

    command.push('--styleCheck')

    command.push(@filePath)
    command
