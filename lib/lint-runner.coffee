path = require 'path'
CSON = require 'season'
{Emitter, Subscriber} = require 'emissary'

LINTER_MAP = CSON.readFileSync(path.join(__dirname, 'linter-map.cson'));

module.exports =
class LintRunner
  Emitter.includeInto(LintRunner)
  Subscriber.includeInto(LintRunner)

  constructor: (@editor) ->
    @buffer = @editor.getBuffer()

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

    unless @bufferSaveSubscription?
      @bufferSaveSubscription = @subscribe @buffer, 'saved', =>
        @lint()

  deactivate: ->
    if @bufferSaveSubscription?
      @bufferSaveSubscription.off()
      @bufferSaveSubscription = null

    if @linterConstructor?
      @linterConstructor = null
      @emit('deactivate')

  getCurrentLinter: ->
    @linterConstructor

  lint: ->
    filePath = @buffer.getUri()
    linter = new @linterConstructor(filePath)
    linter.run (error, violations) =>
      @emit('lint', error, violations)
