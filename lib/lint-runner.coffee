path = require 'path'
CSON = require 'season'
{Emitter, Subscriber} = require 'emissary'

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

  isWatching: ->
    @grammerChangeSubscription?

  switchLinter: ->
    scopeName = @editor.getGrammar().scopeName
    linterName = LINTER_MAP[scopeName]

    if linterName
      @activate(linterName)
    else
      @deactivate()

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
    filePath = @buffer.getUri()
    linter = new @linterConstructor(filePath)
    linter.run (error, violations) =>
      @setLastViolations(violations)
      @emit('lint', error, @lastViolations)

  getActiveLinter: ->
    @linterConstructor

  getLastViolations: ->
    @lastViolations

  setLastViolations: (violations) ->
    @lastViolations = violations
    return unless @lastViolations?
    @lastViolations = @lastViolations.sort (a, b) ->
      a.bufferRange.compare(b.bufferRange)
