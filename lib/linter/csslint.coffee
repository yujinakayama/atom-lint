{Range, Point} = require 'atom'
XmlBase = require './xml-base'
Violation = require '../violation'

module.exports =
class CSSLint extends XmlBase
  @canonicalName = 'CSSLint'

  buildCommand: ->
    command = []

    userCSSLintPath = atom.config.get('atom-lint.csslint.path')
    userCSSLintRules = atom.config.get('atom-lint.csslint.rules')

    if userCSSLintPath?
      command.push(userCSSLintPath)
    else
      command.push('csslint')

    # add rule flags
    if userCSSLintRules?
      for flag, rules of userCSSLintRules
        if /errors|ignore|warnings/.test(flag) and Array.isArray(rules)
          command.push("--#{flag.toLowerCase()}=#{rules.join(',')}")

    command.push('--format=checkstyle-xml')
    command.push(@filePath)
    command

  isValidExitCode: (exitCode) ->
    exitCode == 0 || exitCode == 1

  createViolationFromElement: (element) ->
    bufferPoint = new Point(element.$.line - 1, element.$.column - 1)
    bufferRange = new Range(bufferPoint, bufferPoint)
    new Violation(element.$.severity, bufferRange, element.$.message)
