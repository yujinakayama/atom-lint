{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'

module.exports =
class Rubocop
  constructor: (@filePath, @textContents=null) ->

  run: (callback) ->
    if @textContents?
      # No idea how to feed HLint stdin, so we'll just ignore those
      # requests
      return
    @runRubocop (error, result) =>
      if error?
        callback(error)
      else
        file = result.files[0]
        offenses = file.offenses || file.offences
        violations = offenses.map(@createViolationFromOffense)
        callback(null, violations)

  createViolationFromOffense: (offense) ->
    bufferPoint = new Point(offense.location.line - 1, offense.location.column - 1)
    bufferRange = new Range(bufferPoint, bufferPoint)
    severity = switch offense.severity
      when 'error', 'fatal'
        'error'
      else
        'warning'
    new Violation(severity, bufferRange, offense.message)

  runRubocop: (callback) ->
    runner = new CommandRunner(@constructCommand())

    runner.run (error, result) ->
      return callback(error) if error?

      if result.exitCode == 0 || result.exitCode == 1
        try
          callback(null, JSON.parse(result.stdout))
        catch error
          callback(error)
      else
        callback(new Error("Process exited with code #{result.exitCode}"))

  constructCommand: ->
    command = []

    userRubocopPath = atom.config.get('atom-lint.rubocop.path')

    if userRubocopPath?
      command.push(userRubocopPath)
    else
      command.push('rubocop')

    command.push('--format', 'json', @filePath)
    command
