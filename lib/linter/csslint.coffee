{Range, Point} = require 'atom'
CheckstyleBase = require './checkstyle-base'
Violation = require '../violation'

module.exports =
class CSSLint extends CheckstyleBase
  @canonicalName = 'CSSLint'

  buildCommand: ->
    command = []

    userCSSLintPath = atom.config.get('atom-lint.csslint.path')

    if userCSSLintPath?
      command.push(userCSSLintPath)
    else
      command.push('csslint')

    command.push('--format=checkstyle-xml')
    command.push(@filePath)
    command

  isValidExitCode: (exitCode) ->
    exitCode == 0

  createViolationFromErrorElement: (element) ->
    bufferPoint = new Point(element.$.line - 1, element.$.column - 1)
    bufferRange = new Range(bufferPoint, bufferPoint)
    new Violation(element.$.severity, bufferRange, element.$.message)
