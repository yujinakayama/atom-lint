xml2js = require 'xml2js'
CommandRunner = require '../command-runner'

module.exports =
class XmlBase
  constructor: (@filePath) ->

  run: (callback) ->
    runner = new CommandRunner(@buildCommand())
    runner.run (commandError, result) =>
      return callback(commandError) if commandError?

      unless @isValidExitCode(result.exitCode)
        return callback(new Error("Process exited with code #{result.exitCode}"))

      xml2js.parseString result.stdout, (xmlError, xml) =>
        return callback(xmlError) if xmlError?
        callback(null, @createViolationsFromXml(xml))

  buildCommand: ->
    throw new Error('::buildCommand must be overridden')

  isValidExitCode: (exitCode) ->
    throw new Error('::isValidExitCode must be overridden')

  createViolationsFromXml: (xml) ->
    return [] unless xml.checkstyle.file?
    for element in xml.checkstyle.file[0].error
      @createViolationFromElement(element)

  createViolationFromElement: (element) ->
    throw new Error('::createViolationFromElement must be overridden')
