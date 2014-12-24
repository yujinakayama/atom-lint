# Minimize additional startup time of Atom caused by atom-lint.
LintView = null
LintStatusView = null
Config = null
_ = null

module.exports =
  configDefaults:
    ignoredNames: []
    showViolationMetadata: true

  activate: ->
    atom.workspaceView.command 'lint:toggle', => @toggle()
    atom.workspaceView.command 'lint:toggle-violation-metadata', => @toggleViolationMetadata()

    @lintViews = []
    @enable()

  deactivate: ->
    atom.workspaceView?.off('lint:toggle-violation-metadata')
    atom.workspaceView?.off('lint:toggle')
    @disable()

  enable: ->
    @enabled = true

    # Subscribing to every current and future editor
    @editorViewSubscription = atom.workspaceView.eachEditorView (editorView) =>
      @injectLintViewIntoEditorView(editorView)

    @injectLintStatusViewIntoStatusBar()
    atom.packages.once 'activated', =>
      @injectLintStatusViewIntoStatusBar()

    Config ?= require './config'
    @configSubscription = Config.onDidChange (event) =>
      return unless @shouldRefleshWithConfigChange(event.oldValue, event.newValue)
      for lintView in @lintViews
        lintView.refresh()

  disable: ->
    @lintStatusView?.remove()
    @lintStatusView = null

    @configSubscription?.off()
    @editorViewSubscription?.off()

    while view = @lintViews.shift()
      view.remove()

    @enabled = false

  toggle: ->
    if @enabled
      @disable()
    else
      @enable()

  toggleViolationMetadata: ->
    key = 'showViolationMetadata'
    currentValue = Config.get(key)
    Config.set(key, !currentValue)

  injectLintViewIntoEditorView: (editorView) ->
    return unless editorView.getPane()?
    return unless editorView.attached
    return if editorView.lintView?
    LintView ?= require './lint-view'
    lintView = new LintView(editorView)
    @lintViews.push(lintView)

  injectLintStatusViewIntoStatusBar: ->
    return if @lintStatusView?
    statusBar = atom.workspaceView.statusBar
    return unless statusBar?
    LintStatusView ?= require './lint-status-view'
    @lintStatusView = new LintStatusView(statusBar)
    statusBar.prependRight(@lintStatusView)

  shouldRefleshWithConfigChange: (previous, current) ->
    previous.showViolationMetadata = current.showViolationMetadata = null
    _ ?= require 'lodash'
    !_.isEqual(previous, current)
