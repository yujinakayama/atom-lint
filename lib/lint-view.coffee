{View} = require 'atom'
path = require 'path'
CSON = require 'season'
LintRunner = require './lint-runner'
ViolationView = require './violation-view'

SEVERITIES = ['warning', 'error']

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
    @lastViolations = violations

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

    for severity in SEVERITIES
      @gutterView.removeClassFromAllLines("lint-#{severity}")

    return unless @lastViolations

    for violation in @lastViolations
      line = violation.bufferRange.start.row
      klass = "lint-#{violation.severity}"
      @gutterView.addClassToLine(line, klass)
