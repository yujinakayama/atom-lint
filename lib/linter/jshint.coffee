{Range, Point} = require 'atom'
xml2js = require 'xml2js'
CommandRunner = require '../command-runner'
Violation = require '../violation'

module.exports =
class JsHint
  constructor: (@filePath, @textContents=null) ->
    if @textContents?
      @filePath = '-'

  run: (callback) ->
    runner = new CommandRunner(@constructCommand())
    if @textContents?
      runner.stdin = @textContents
    runner.run (error, result) =>
      return callback(error) if error?
      # JSHint returns an exit code of 2 when everything worked, but the check failed.
      if result.exitCode == 0 || result.exitCode == 2
        xml2js.parseString result.stdout, (xmlError, result) =>
          return callback(xmlError) if xmlError?
          callback(null, @parseJsHintResultToViolations(result))
      else
        callback(new Error("Process exited with code #{result.exitCode}"))

  parseJsHintResultToViolations: (jsHintResults) ->
    violations = []
    return violations if not jsHintResults.checkstyle.file?
    for element in jsHintResults.checkstyle.file[0].error
      # JSHint only returns one point instead of a range, so we're going to set
      # both sides of the range to the same thing.
      bufferPoint = new Point(element.$.line - 1, element.$.column - 1)
      bufferRange = new Range(bufferPoint, bufferPoint)
      violation = new Violation(element.$.severity, bufferRange, element.$.message)
      violations.push(violation)
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
