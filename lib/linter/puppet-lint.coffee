{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'
util = require '../util'

module.exports =
class PuppetLint
  @canonicalName = 'puppet-lint'

  constructor: (@filePath) ->

  run: (callback) ->
    runner = new CommandRunner(@buildCommand())

    runner.run (error, result) =>
      return callback(error) if error?

      # puppet-lint returns 0 even if there are violations unless --fail-on-warnings is specified.
      unless result.exitCode == 0
        return callback(new Error("Process exited with code #{result.exitCode}"))

      violations = @parseLog(result.stdout)
      callback(null, violations)

  parseLog: (log) ->
    lines = log.split('\n')

    for line in lines
      continue unless line

      [line, column, severity, message] = line.split(':')
      bufferPoint = new Point(parseInt(line) - 1, parseInt(column) - 1)
      bufferRange = new Range(bufferPoint, bufferPoint)

      message = util.punctuate(util.capitalize(message))

      new Violation(severity, bufferRange, message)

  buildCommand: ->
    command = []

    userPuppetLintPath = atom.config.get('atom-lint.puppet-lint.path')

    if userPuppetLintPath?
      command.push(userPuppetLintPath)
    else
      command.push('puppet-lint')

    command.push('--log-format', '%{linenumber}:%{column}:%{kind}:%{message}')

    command.push(@filePath)
    command
