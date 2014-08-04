{Range, Point} = require 'atom'
XmlBase = require './xml-base'
Violation = require '../violation'

# https://github.com/causes/scss-lint/blob/v0.26.2/lib/scss_lint/cli.rb#L13-L21
# https://github.com/causes/scss-lint/commit/a5f69c1a1b39bb00aacfdba75fb06f77097fc6a8
VALID_EXIT_CODES = [0, 1, 2, 65]

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
    VALID_EXIT_CODES.indexOf(exitCode) >= 0

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
