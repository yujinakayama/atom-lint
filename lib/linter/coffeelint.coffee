{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'

module.exports =
class CoffeeLint
  constructor: (@filePath) ->

  run: (callback) ->
    @runCoffeeLint (error, violations) ->
      if error?
        callback(error)
      else
        callback(null, violations)

  runCoffeeLint: (callback) ->
    runner = new CommandRunner(@constructCommand())

    runner.run (error, result) ->
      return callback(error) if error?

      pattern = ///
        ^(.+),(\d+),(\d*),(error|warn),(.+)$
      ///

      if result.exitCode == 0 || result.exitCode == 1
        violations = []
        items = result.stdout.split '\n'
        for item in items[1...]
          if not item then continue

          [file, line, col, severity, msg] = item.match(pattern)[1..5]

          col = '1' if col == ''
          severity = 'warning' if severity == 'warn'
          bufferPoint = new Point(parseInt(line) - 1, parseInt(col) - 1)
          bufferRange = new Range(bufferPoint, bufferPoint)
          violations.push(new Violation(severity, bufferRange, msg))

        callback(null, violations)
      else
        callback(new Error "Process exited with code #{result.exitCode}")

  constructCommand: ->
    command = []

    userCoffeeLintPath = atom.config.get('atom-lint.coffeelint.path')

    if userCoffeeLintPath?
      command.push(userCoffeeLintPath)
    else
      command.push('coffeelint')

    command.push('--csv')
    command.push(@filePath)
    command
