{Range, Point} = require 'atom'
XmlBase = require './xml-base'
Violation = require '../violation'

module.exports =
class CoffeeLint extends XmlBase
  @canonicalName = 'CoffeeLint'

  buildCommand: ->
    command = []

    userCoffeeLintPath = atom.config.get('atom-lint.coffeelint.path')

    if userCoffeeLintPath?
      command.push(userCoffeeLintPath)
    else
      command.push('coffeelint')

    command.push('--checkstyle')
    command.push(@filePath)
    command

  isValidExitCode: (exitCode) ->
    # CoffeeLint returns an exit code of 2 when everything worked, but the check failed.
    # And code 1 for parse errors.
    0 <= exitCode <= 2

  createViolationFromElement: (element) ->
    column = element.$.column
    column ?= 1
    bufferPoint = new Point(element.$.line - 1, column - 1)
    bufferRange = new Range(bufferPoint, bufferPoint)

    # https://github.com/clutchski/coffeelint/blob/v1.1.0/src/commandline.coffee#L236
    message = element.$.message.replace(/; context: .*?$/, '')

    new Violation(element.$.severity, bufferRange, message)
