{Range} = require 'atom'
CommandRunner = require '../command-runner'
parseString = require('xml2js').parseString

module.exports =
class JsHint
  constructor: (@filePath) ->

  run: (callback) ->
    @runJsHint (error, violations) =>
      callback(error) if error?
      callback(null, violations)

  runJsHint: (callback) ->
    runner = new CommandRunner(@constructCommand())
    runner.run (error, result) =>
      return callback(error) if error?
      # JSHint returns an exit code of 2 when everything worked, but the check failed.
      if result.exitCode == 0 || result.exitCode == 2
        callback(null, @parseErrorsIntoViolations(result.stdout))
      else
        callback(new Error("Process exited with code #{result.exitCode}"))

  parseErrorsIntoViolations: (errorXml) ->
    violations = []
    parseString errorXml, (err, result) ->
      for err in result.checkstyle.file[0].error
        # JSHint only returns one point instead of a range, so we're going to set
        # both sides of the range to the same thing.
        point = [err.$.line, err.$.column]
        violations.push
          severity: err.$.severity
          message: err.$.message
          bufferRange: new Range(point, point)
    violations

  constructCommand: ->
    command = []
    userJsHintPath = atom.config.get('atom-lint.jshint.path')
    if userJsHintPath?
      command.push(userJsHintPath)
    else
      command.push('jshint')
    command.push('--reporter=checkstyle')
    command.push(@filePath)
    command
