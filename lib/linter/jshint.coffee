{Range, Point} = require 'atom'
XmlBase = require './xml-base'
Violation = require '../violation'

module.exports =
class JsHint extends XmlBase
  @canonicalName = 'JSHint'

  buildCommand: ->
    command = []

    userJsHintPath = atom.config.get('atom-lint.jshint.path')

    if userJsHintPath?
      command.push(userJsHintPath)
    else
      command.push('jshint')

    command.push('--reporter', 'checkstyle')
    command.push(@filePath)
    command

  isValidExitCode: (exitCode) ->
    # JSHint returns an exit code of 2 when everything worked, but the check failed.
    # https://github.com/jshint/jshint/issues/916
    exitCode == 0 || exitCode == 2

  createViolationFromElement: (element) ->
    # JSHint only returns one point instead of a range, so we're going to set
    # both sides of the range to the same thing.
    bufferPoint = new Point(element.$.line - 1, element.$.column - 1)
    bufferRange = new Range(bufferPoint, bufferPoint)
    new Violation(element.$.severity, bufferRange, element.$.message)
