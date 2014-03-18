# Minimize additional startup time of Atom caused by atom-lint.
LintView = null
LintStatusView = null

module.exports =
  activate: ->
    atom.workspaceView.command 'lint:toggle', => @toggle()
    @lintViews = []
    @enable()

  deactivate: ->
    @disable()

  enable: ->
    @enabled = true

    # Already instantiated tabs
    for editorView in atom.workspaceView.getEditorViews()
      @injectLintViewIntoEditorView(editorView)

    # Invoked on instantiation of new tab
    @editorViewSubscription = atom.workspaceView.eachEditorView (editorView) =>
      return unless editorView.getPane()?
      @injectLintViewIntoEditorView(editorView)

    @injectLintStatusViewIntoStatusBar()
    atom.packages.once 'activated', =>
      @injectLintStatusViewIntoStatusBar()

  disable: ->
    @lintStatusView?.remove()
    @lintStatusView = null

    @editorViewSubscription?.off()

    while view = @lintViews.shift()
      view.remove()

    @enabled = false

  toggle: ->
    if @enabled
      @disable()
    else
      @enable()

  injectLintViewIntoEditorView: (editorView) ->
    return unless editorView.attached
    return if editorView.lintView?
    LintView ?= require './lint-view'
    lintView = new LintView(editorView)
    @lintViews.push(lintView)
    editorView.overlayer.append(lintView)

  injectLintStatusViewIntoStatusBar: ->
    return if @lintStatusView?
    statusBar = atom.workspaceView.statusBar
    return unless statusBar?
    LintStatusView ?= require './lint-status-view'
    @lintStatusView = new LintStatusView(statusBar)
    statusBar.prependRight(@lintStatusView)
