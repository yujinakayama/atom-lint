{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'
LinterError = require '../linter-error'

module.exports =
class Rubocop
  @canonicalName = 'RuboCop'

  constructor: (@filePath) ->

  run: (callback) ->
    @runRubocop (error, result) =>
      if error?
        callback(error)
      else
        file = result.files[0]
        offenses = file.offenses || file.offences
        violations = offenses.map(@createViolationFromOffense)
        callback(null, violations)

  createViolationFromOffense: (offense) ->
    location = offense.location
    startPoint = new Point(location.line - 1, location.column - 1)
    bufferRange =
      if location.length?
        Range.fromPointWithDelta(startPoint, 0, location.length)
      else
        new Range(startPoint, startPoint)

    severity = switch offense.severity
      when 'error', 'fatal'
        'error'
      else
        'warning'

    new Violation(severity, bufferRange, offense.message)

  runRubocop: (callback) ->
    runner = new CommandRunner(@buildCommand())

    runner.run (error, result) ->
      return callback(error) if error?

      if result.exitCode == 0 || result.exitCode == 1
        try
          callback(null, JSON.parse(result.stdout))
        catch error
          escapedStdout = JSON.stringify(result.stdout)
          callback(new LinterError("Failed parsing RuboCop's JSON output #{escapedStdout}", result))
      else
        callback(new LinterError("rubocop exited with code #{result.exitCode}", result))

  buildCommand: ->
    command = []

    userRubocopPath = atom.config.get('atom-lint.rubocop.path')
    showDisplayCopNames = atom.config.get('atom-lint.rubocop.showDisplayCopNames')
    showDisplayCopNames ?= true

    if userRubocopPath?
      command.push(userRubocopPath)
    else
      command.push('rubocop')

    command.push('--format', 'json')
    command.push '--display-cop-names' if showDisplayCopNames
    command.push @filePath
    command
