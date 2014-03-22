{View} = require 'atom'

module.exports =
class LintStatusView extends View
  @content: ->
    @div class: 'lint-status inline-block', =>
      @span class: 'linter-name'
      @span class: 'lint-summary'

  initialize: (@statusBarView) ->
    @subscribeToLintRunner()
    @update()

    @subscribe @statusBarView, 'active-buffer-changed', =>
      @unsubscribeFromLintRunner()
      @subscribeToLintRunner()
      @update()

  getActiveLintRunner: ->
    editorView = atom.workspaceView.getActiveView()
    editorView?.lintView?.lintRunner

  subscribeToLintRunner: ->
    activeLintRunner = @getActiveLintRunner()
    return unless activeLintRunner?
    @subscription = activeLintRunner.on 'activate deactivate lint', =>
      @update()

  unsubscribeFromLintRunner: ->
    @subscription?.off()
    @subscription = null

  update: ->
    activeLinter = @getActiveLintRunner()?.getActiveLinter()

    if activeLinter?
      @displayLinterName(activeLinter.canonicalName)
      violations = @getActiveLintRunner().getLastViolations()
      @displaySummary(violations)
    else
      @displayLinterName()
      @displaySummary()

  displayLinterName: (text) ->
    @find('.linter-name').text(text || '')

  displaySummary: (violations) ->
    html = ''

    if violations?
      if violations.length == 0
        html += '<span class="icon icon-check lint-clean"></span>'
      else
        errorCount = @countViolationsOfSeverity(violations, 'error')
        if errorCount > 0
          html += "<span class=\"icon icon-alert lint-error\"></span> #{errorCount}"
        warningCount = @countViolationsOfSeverity(violations, 'warning')
        if warningCount > 0
          html += "<span class=\"icon icon-alert lint-warning\"></span> #{warningCount}"

    @find('.lint-summary').html(html)

  countViolationsOfSeverity: (violations, severity) ->
    return 0 unless violations?
    violations.filter (violation) ->
      violation.severity == severity
    .length
