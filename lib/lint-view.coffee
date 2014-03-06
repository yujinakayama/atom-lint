{View} = require 'atom'
path = require('path');
CSON = require 'season'
ViolationView = require './violation-view'

linterMap = CSON.readFileSync(path.join(__dirname, 'linter-map.cson'));

module.exports =
class RubocopView extends View
  @content: ->
    @div class: 'lint'

  initialize: (@editorView) ->
    @editor = @editorView.getEditor()
    @violationViews = []
    @enableIfSupportedGrammar()
    @subscribe @editor, 'grammar-changed', =>
      @enableIfSupportedGrammar()

  enableIfSupportedGrammar: ->
    scopeName = @editor.getGrammar().scopeName
    linterName = linterMap[scopeName]
    if linterName
      @enable(linterName)
    else
      @disable()

  enable: (linterName) ->
    linterPath = "./linter/#{linterName}"
    @linterConstructor = require linterPath

    @update()
    @bufferSubscription = @subscribe @editor.getBuffer(), 'saved', =>
      @update()

  disable: ->
    @bufferSubscription?.off()
    @removeViolationViews()

  update: ->
    filePath = @editor.getBuffer().getUri()
    linter = new @linterConstructor(filePath)
    linter.run (violations, error) =>
      if error
        console.log(error)
      else
        @removeViolationViews()
        @addViolationViews(violations)

  addViolationViews: (violations) ->
    for violation in violations
      violationView = new ViolationView(violation, this)
      @violationViews.push(violationView)
      @append(violationView)

  removeViolationViews: ->
    while view = @violationViews.shift()
      view.remove()

  beforeRemove: ->
    @disable()
