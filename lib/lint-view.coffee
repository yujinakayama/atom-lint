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
    @gutterView = @editorView.gutter

    @violations = []
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

    @lint()
    @bufferSubscription = @subscribe @editor.getBuffer(), 'saved', =>
      @lint()
    # http://discuss.atom.io/t/decorating-the-left-gutter/1321/4
    @editorViewSubscription = @subscribe @editorView, 'editor:display-updated', =>
      @updateGutterMarkers()

  disable: ->
    @violations = []

    @editorViewSubscription?.off()
    @bufferSubscription?.off()

    @removeViolationViews()
    @updateGutterMarkers()

  lint: ->
    filePath = @editor.getBuffer().getUri()
    linter = new @linterConstructor(filePath)
    linter.run (error, violations) =>
      @violations = violations
      if error?
        console.log(error)
      else
        @removeViolationViews()
        @addViolationViews(violations)
        @updateGutterMarkers()

  addViolationViews: (violations) ->
    for violation in violations
      violationView = new ViolationView(violation, this)
      @violationViews.push(violationView)
      @append(violationView)

  removeViolationViews: ->
    while view = @violationViews.shift()
      view.remove()

  updateGutterMarkers: ->
    return unless @gutterView.isVisible()

    @gutterView.removeClassFromAllLines('lint-warning')
    @gutterView.removeClassFromAllLines('lint-error')

    return unless @violations

    for violation in @violations
      line = violation.bufferRange.start.row
      klass = "lint-#{violation.severity}"
      @gutterView.addClassToLine(line, klass)

  beforeRemove: ->
    @disable()
