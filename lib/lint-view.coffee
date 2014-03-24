path = require 'path'
{View} = require 'atom'
CSON = require 'season'
_ = require 'lodash'
LintRunner = require './lint-runner'
ViolationView = require './violation-view'
Violation = require './violation'

module.exports =
class LintView extends View
  @content: ->
    @div class: 'lint'

  initialize: (@editorView) ->
    @editorView.lintView = this

    @editor = @editorView.getEditor()
    @gutterView = @editorView.gutter

    @violationViews = []

    @lintRunner = new LintRunner(@editor)
    @lintRunner.on 'activate', => @onLinterActivation()
    @lintRunner.on 'deactivate', => @onLinterDeactivation()
    @lintRunner.on 'lint', (error, violations) => @onLint(error, violations)
    @lintRunner.startWatching()

    @editorView.command 'lint:move-to-next-violation', => @moveToNextViolation()
    @editorView.command 'lint:move-to-previous-violation', => @moveToPreviousViolation()

  refresh: ->
    @lintRunner.refresh()

  onLinterActivation: ->
    # http://discuss.atom.io/t/decorating-the-left-gutter/1321/4
    @editorDisplayUpdateSubscription = @subscribe @editorView, 'editor:display-updated', =>
      @updateGutterMarkers()

  onLinterDeactivation: ->
    @editorDisplayUpdateSubscription?.off()
    @removeViolationViews()
    @updateGutterMarkers()

  onLint: (error, violations) ->
    @updateGutterMarkers()
    @removeViolationViews()

    if error?
      console.log(error)
    else
      @addViolationViews(violations)

  beforeRemove: ->
    @lintRunner.stopWatching()
    @editorView.lintView = undefined

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

    for severity in Violation.SEVERITIES
      @gutterView.removeClassFromAllLines("lint-#{severity}")

    return unless @getLastViolations()

    for violation in @getLastViolations()
      line = violation.bufferRange.start.row
      klass = "lint-#{violation.severity}"
      @gutterView.addClassToLine(line, klass)

  moveToNextViolation: ->
    @moveToNeighborViolation('next')

  moveToPreviousViolation: ->
    @moveToNeighborViolation('previous')

  moveToNeighborViolation: (direction) ->
    unless @getLastViolations()?
      atom.beep()
      return

    if direction == 'next'
      enumerationMethod = 'find'
      comparingMethod = 'isGreaterThan'
    else
      enumerationMethod = 'findLast'
      comparingMethod = 'isLessThan'

    currentCursorPosition = @editor.getCursor().getBufferPosition()

    # OPTIMIZE: Consider using binary search.
    neighborViolation = _[enumerationMethod] @getLastViolations(), (violation) ->
      violation.bufferRange.start[comparingMethod](currentCursorPosition)

    if neighborViolation?
      @editor.setCursorBufferPosition(neighborViolation.bufferRange.start)
    else
      atom.beep()

  getLastViolations: ->
    @lintRunner.getLastViolations()
