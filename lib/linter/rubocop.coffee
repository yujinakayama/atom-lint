{Range, Point} = require 'atom'
child_process = require 'child_process'
fs = require 'fs'

module.exports =
class RubocopLinter
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
    command = @getCommand()
    rubocop = child_process.spawn(command[0], command.splice(1))

    stdout = ''

    rubocop.stdout.on 'data', (data) ->
      stdout += data

    rubocop.on 'close', (exitCode) ->
      if exitCode == 0 || exitCode == 1
        try
          result = JSON.parse(stdout)
          callback(result, null)
        catch error
          callback(null, error)
      else
        callback(null, "Process exited with code #{exitCode}")

    rubocop.on 'error', (error) ->
      callback(stdout, error)

  getCommand: (filePath) ->
    command = []

    # TODO: Make configurable
    rbenvPath = "#{process.env.HOME}/.rbenv/bin/rbenv"
    if fs.existsSync(rbenvPath)
      command.push(rbenvPath, 'exec', 'rubocop')
    else
      command.push('rubocop')

    command.push('--format', 'json')
    command.push(@filePath)

    command
