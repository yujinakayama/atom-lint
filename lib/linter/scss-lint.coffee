{Range, Point} = require 'atom'
XmlBase = require './xml-base'
Violation = require '../violation'

module.exports =
class SCSSLint extends XmlBase
  @canonicalName = 'SCSS-Lint'

  buildCommand: ->
    command = []

    userSCSSLintPath = atom.config.get('atom-lint.scss-lint.path')

    if userSCSSLintPath?
      command.push(userSCSSLintPath)
    else
      command.push('scss-lint')

    command.push('--format', 'XML')
    command.push(@filePath)
    command

  isValidExitCode: (exitCode) ->
    # https://github.com/causes/scss-lint/blob/v0.20.0/lib/scss_lint/cli.rb#L12-L17
    exitCode == 0 || exitCode == 65

  createViolationsFromXml: (xml) ->
    return [] unless xml.lint.file?
    for element in xml.lint.file[0].issue
      @createViolationFromElement(element)

  createViolationFromElement: (element) ->
    column = element.$.column
    column ?= 1

    bufferPoint = new Point(element.$.line - 1, column - 1)
    bufferRange = new Range(bufferPoint, bufferPoint)
    new Violation(element.$.severity, bufferRange, element.$.reason)
