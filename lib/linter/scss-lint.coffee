xml2js = require 'xml2js'
{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'

module.exports =
class SCSSLint
  @canonicalName = 'SCSS-Lint'

  constructor: (@filePath) ->

  run: (callback) ->
    runner = new CommandRunner(@buildCommand())
    runner.run (commandError, result) =>
      return callback(commandError) if commandError?

      if result.exitCode == 65
        xml2js.parseString result.stdout, (xmlError, xml) =>
          return callback(xmlError) if xmlError?
          callback(null, @createViolationsFromXml(xml))

  createViolationsFromXml: (xml) ->
    return [] unless xml.lint.file?
    for element in xml.lint.file[0].issue
      @createViolationFromErrorElement(element)

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

  createViolationFromErrorElement: (element) ->
    column = element.$.column
    column ?= 1

    bufferPoint = new Point(element.$.line - 1, column - 1)
    bufferRange = new Range(bufferPoint, bufferPoint)
    new Violation(element.$.severity, bufferRange, element.$.reason)
