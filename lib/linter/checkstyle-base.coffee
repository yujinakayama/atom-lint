{Range, Point} = require 'atom'
xml2js = require 'xml2js'
CommandRunner = require '../command-runner'
Violation = require '../violation'

module.exports =
class CheckstyleBase
  constructor: (@filePath) ->

  run: (callback) ->
    runner = new CommandRunner(@buildCommand())
    runner.run (commandError, result) =>
      return callback(commandError) if commandError?

      unless @isValidExitCode(result.exitCode)
        return callback(new Error("Process exited with code #{result.exitCode}"))

      xml2js.parseString result.stdout, (xmlError, xml) =>
        return callback(xmlError) if xmlError?
        callback(null, @createViolationsFromCheckstyleXml(xml))

  buildCommand: ->
    throw new Error('::buildCommand must be overridden')

  isValidExitCode: (exitCode) ->
    throw new Error('::isValidExitCode must be overridden')

  createViolationsFromCheckstyleXml: (xml) ->
    return [] unless xml.checkstyle.file?
    for element in xml.checkstyle.file[0].error
      # JSHint only returns one point instead of a range, so we're going to set
      # both sides of the range to the same thing.
      bufferPoint = new Point(element.$.line - 1, element.$.column - 1)
      bufferRange = new Range(bufferPoint, bufferPoint)
      new Violation(element.$.severity, bufferRange, element.$.message)
