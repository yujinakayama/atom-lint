path = require 'path'
{View} = require 'atom'
CSON = require 'season'
_ = require 'lodash'
LintRunner = require './lint-runner'
ViolationView = require './violation-view'
Violation = require './violation'

module.exports =
class RubocopView extends View
  @content: ->
    @div class: 'lint'

  initialize: (@editorView) ->
    @editor = @editorView.getEditor()
    @gutterView = @editorView.gutter

    @lastViolations = null
    @violationViews = []

    @lintRunner = new LintRunner(@editor)
    @lintRunner.on 'activate', => @onLinterActivation()
    @lintRunner.on 'deactivate', => @onLinterDeactivation()
    @lintRunner.on 'lint', (error, violations) => @onLint(error, violations)
    @lintRunner.startWatching()

    @editorView.command 'lint:move-to-next-violation', => @moveToNextViolation()
    @editorView.command 'lint:move-to-previous-violation', => @moveToPreviousViolation()

  onLinterActivation: ->
    # http://discuss.atom.io/t/decorating-the-left-gutter/1321/4
    @editorDisplayUpdateSubscription = @subscribe @editorView, 'editor:display-updated', =>
      @updateGutterMarkers()

  onLinterDeactivation: ->
    @lastViolations = null
    @editorDisplayUpdateSubscription?.off()
    @removeViolationViews()
    @updateGutterMarkers()

  onLint: (error, violations) ->
    @setLastViolations(violations)

    @updateGutterMarkers()
    @removeViolationViews()

    if error?
      console.log(error)
    else
      @addViolationViews(violations)

  beforeRemove: ->
    @lintRunner.stopWatching()

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

    return unless @lastViolations

    for violation in @lastViolations
      line = violation.bufferRange.start.row
      klass = "lint-#{violation.severity}"
      @gutterView.addClassToLine(line, klass)

  setLastViolations: (violations) ->
    @lastViolations = violations
    return unless @lastViolations?
    @lastViolations = @lastViolations.sort (a, b) ->
      a.bufferRange.compare(b.bufferRange)

  moveToNextViolation: ->
    @moveToNeighborViolation('next')

  moveToPreviousViolation: ->
    @moveToNeighborViolation('previous')

  moveToNeighborViolation: (direction) ->
    if direction == 'next'
      enumerationMethod = 'find'
      comparingMethod = 'isGreaterThan'
    else
      enumerationMethod = 'findLast'
      comparingMethod = 'isLessThan'

    currentCursorPosition = @editor.getCursor().getBufferPosition()

    # OPTIMIZE: Consider using binary search.
    neighborViolation = _[enumerationMethod] @lastViolations, (violation) ->
      violation.bufferRange.start[comparingMethod](currentCursorPosition)

    if neighborViolation?
      @editor.setCursorBufferPosition(neighborViolation.bufferRange.start)
    else
      atom.beep()
