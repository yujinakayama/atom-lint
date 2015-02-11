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
      callback(error) if error?

      file = result.files[0]
      return callback(null, []) unless file

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

    metadata = [offense.cop_name]

    new Violation(severity, bufferRange, offense.message, metadata)

  runRubocop: (callback) ->
    runner = new CommandRunner(@buildCommand())

    runner.run (error, result) ->
      return callback(error) if error?

      if result.exitCode == 0 || result.exitCode == 1
        try
          rubocopResult = JSON.parse(result.stdout)
        catch error
          escapedStdout = JSON.stringify(result.stdout)
          error = new LinterError("Failed parsing RuboCop's JSON output #{escapedStdout}", result)

        callback(error, rubocopResult)
      else
        callback(new LinterError("rubocop exited with code #{result.exitCode}", result))

  buildCommand: ->
    command = []

    userRubocopPath = atom.config.get('atom-lint.rubocop.path')
    userRubocopConfig = atom.config.get('atom-lint.rubocop.configPath')

    if userRubocopPath?
      command.push(userRubocopPath)
    else
      command.push('rubocop')

    if userRubocopConfig?
      command.push("--config=#{userRubocopConfig}")

    command.push('--force-exclusion', '--format', 'json', @filePath)
    command
