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
    @editorView.overlayer.append(this)

    @editor = @editorView.getEditor()

    @violationViews = []

    @lintRunner = new LintRunner(@editor)
    @lintRunner.on 'activate', => @onLinterActivation()
    @lintRunner.on 'deactivate', => @onLinterDeactivation()
    @lintRunner.on 'lint', (error, violations) => @onLint(error, violations)
    @lintRunner.startWatching()

    @editorView.command 'lint:move-to-next-violation', => @moveToNextViolation()
    @editorView.command 'lint:move-to-previous-violation', => @moveToPreviousViolation()

  beforeRemove: ->
    @editorView.off('lint:move-to-next-violation lint:move-to-previous-violation')
    @lintRunner.stopWatching()
    @editorView.lintView = undefined

  refresh: ->
    @lintRunner.refresh()

  onLinterActivation: ->
    # http://discuss.atom.io/t/decorating-the-left-gutter/1321/4
    @editorDisplayUpdateSubscription = @subscribe @editorView, 'editor:display-updated', =>
      if @pendingViolations?
        @addViolationViews(@pendingViolations)
        @pendingViolations = null

  onLinterDeactivation: ->
    @editorDisplayUpdateSubscription?.off()
    @removeViolationViews()

  onLint: (error, violations) ->
    @removeViolationViews()

    if error?
      console.log(error.toString())
      console.log(error.stack)
    else if @editorView.active
      @addViolationViews(violations)
    else
      # ViolationViews won't be placed properly when the editor (tab) is not active and the file is
      # reloaded by a modification by another process. So we make them pending for now and place
      # them when the editor become active.
      @pendingViolations = violations

  addViolationViews: (violations) ->
    for violation in violations
      violationView = new ViolationView(violation, this)
      @violationViews.push(violationView)

  removeViolationViews: ->
    while view = @violationViews.shift()
      view.remove()

  getValidViolationViews: ->
    @violationViews.filter (violationView) ->
      violationView.isValid

  moveToNextViolation: ->
    @moveToNeighborViolation('next')

  moveToPreviousViolation: ->
    @moveToNeighborViolation('previous')

  moveToNeighborViolation: (direction) ->
    if @violationViews.length == 0
      atom.beep()
      return

    if direction == 'next'
      enumerationMethod = 'find'
      comparingMethod = 'isGreaterThan'
    else
      enumerationMethod = 'findLast'
      comparingMethod = 'isLessThan'

    currentCursorPosition = @editor.getCursor().getScreenPosition()

    # OPTIMIZE: Consider using binary search.
    neighborViolationView = _[enumerationMethod] @getValidViolationViews(), (violationView) ->
      violationPosition = violationView.screenStartPosition
      violationPosition[comparingMethod](currentCursorPosition)

    if neighborViolationView?
      @editor.setCursorScreenPosition(neighborViolationView.screenStartPosition)
    else
      atom.beep()
