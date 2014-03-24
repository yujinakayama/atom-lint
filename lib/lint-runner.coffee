path = require 'path'
CSON = require 'season'
{Emitter, Subscriber} = require 'emissary'
LinterConfig = require './linter-config'

LINTER_MAP = CSON.readFileSync(path.join(__dirname, 'linter-map.cson'))

module.exports =
class LintRunner
  Emitter.includeInto(LintRunner)
  Subscriber.includeInto(LintRunner)

  constructor: (@editor) ->
    @buffer = @editor.getBuffer()
    @lastViolations = null

  startWatching: ->
    return if @isWatching()

    @switchLinter()

    @grammerChangeSubscription = @subscribe @editor, 'grammar-changed', =>
      @switchLinter()

  stopWatching: ->
    if @grammerChangeSubscription?
      @grammerChangeSubscription.off()
      @grammerChangeSubscription = null

    @deactivate()

  refresh: ->
    return unless @isWatching()
    @switchLinter()

  isWatching: ->
    @grammerChangeSubscription?

  switchLinter: ->
    scopeName = @editor.getGrammar().scopeName
    linterName = LINTER_MAP[scopeName]

    return @deactivate() unless linterName

    linterConfig = new LinterConfig(linterName)
    return @deactivate() unless linterConfig.isFileToLint(@getFilePath())

    @activate(linterName)

  activate: (linterName) ->
    wasAlreadyActivated = @linterConstructor?

    linterPath = "./linter/#{linterName}"
    @linterConstructor = require linterPath

    unless wasAlreadyActivated
      @emit('activate')

    @lint()

    unless @bufferSubscription?
      @bufferSubscription = @subscribe @buffer, 'saved reloaded', =>
        @lint()

  deactivate: ->
    @lastViolations = null

    if @bufferSubscription?
      @bufferSubscription.off()
      @bufferSubscription = null

    if @linterConstructor?
      @linterConstructor = null
      @emit('deactivate')

  lint: ->
    linter = new @linterConstructor(@getFilePath())
    linter.run (error, violations) =>
      @setLastViolations(violations)
      @emit('lint', error, @lastViolations)

  getFilePath: ->
    @buffer.getUri()

  getActiveLinter: ->
    @linterConstructor

  getLastViolations: ->
    @lastViolations

  setLastViolations: (violations) ->
    @lastViolations = violations
    return unless @lastViolations?
    @lastViolations = @lastViolations.sort (a, b) ->
      a.bufferRange.compare(b.bufferRange)
