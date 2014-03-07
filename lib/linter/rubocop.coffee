{Range, Point} = require 'atom'
child_process = require 'child_process'
fs = require 'fs'
CommandRunner = require '../command-runner'

module.exports =
class Rubocop
  constructor: (@filePath) ->

  run: (callback) ->
    @runRubocop (result, error) =>
      if error
        callback(null, error)
      else
        file = result.files[0]
        offenses = file.violations || file.offences
        violations = offenses.map(@createViolationFromOffense)
        callback(violations, null)

  createViolationFromOffense: (offense) ->
    bufferPoint = new Point(offense.location.line - 1, offense.location.column - 1)
    bufferRange = new Range(bufferPoint, bufferPoint)
    severity = switch offense.severity
               when 'error', 'fatal'
                 'error'
               else
                 'warning'

    severity: severity
    message: offense.message
    bufferRange: bufferRange

  runRubocop: (callback) ->
    runner = new CommandRunner(@constructCommand())

    runner.run (result) ->
      return callback(null, result.error) if result.error?

      if result.exitCode == 0 || result.exitCode == 1
        try
          callback(JSON.parse(result.stdout), null)
        catch error
          callback(null, error)
      else
        callback(null, "Process exited with code #{result.exitCode}")

  constructCommand: ->
    command = []

    userRubocopPath = atom.config.get('atom-lint.rubocop.path')

    if userRubocopPath?
      command.push(userRubocopPath)
    else
      command.push('rubocop')

    command.push('--format', 'json', @filePath)
    command
