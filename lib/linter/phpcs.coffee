{Range, Point} = require 'atom'
XmlBase = require './xml-base'
Violation = require '../violation'

module.exports =
class Phpcs extends XmlBase
  @canonicalName = 'phpcs'

  buildCommand: ->
    command = []

    userPhpcsPath = atom.config.get('atom-lint.phpcs.path')

    if userPhpcsPath?
      command.push(userPhpcsPath)
    else
      command.push('phpcs')

    userPhpcsStandard = atom.config.get('atom-lint.phpcs.standard')

    if userPhpcsStandard?
      command.push(userPhpcsStandard)
    else
      command.push('--standard=PSR2')

    command.push('--report=checkstyle')
    command.push(@filePath)
    command

  isValidExitCode: (exitCode) ->
    exitCode == 0 || exitCode == 1

  createViolationFromElement: (element) ->
    bufferPoint = new Point(element.$.line - 1, element.$.column - 1)
    bufferRange = new Range(bufferPoint, bufferPoint)
    new Violation(element.$.severity, bufferRange, element.$.message)
