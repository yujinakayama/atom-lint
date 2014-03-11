{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'

module.exports =
class HLint
  constructor: (@filePath) ->

  run: (callback) ->
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

          bufferPoint = new Point parseInt(line) - 1, parseInt(col) - 1

          violations.push
            severity: severity.toLowerCase()
            message: msg
            bufferRange: new Range bufferPoint, bufferPoint

        callback(null, violations)
      else
        callback(new Error "Process exited with code #{result.exitCode}")

  constructCommand: ->
    command = []

    userHLintPath = atom.config.get('atom-lint.hlint.path')

    if userHLintPath?
      command.push(userHLintPath)
    else
      command.push('hlint')

    command.push(@filePath)
    command
