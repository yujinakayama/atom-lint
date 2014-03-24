# Minimize additional startup time of Atom caused by atom-lint.
LintView = null
LintStatusView = null
LinterConfig = null

module.exports =
  activate: ->
    atom.workspaceView.command 'lint:toggle', => @toggle()
    @lintViews = []
    @enable()

  deactivate: ->
    @disable()

  enable: ->
    @enabled = true

    # Subscribing to every current and future editor
    @editorViewSubscription = atom.workspaceView.eachEditorView (editorView) =>
      @injectLintViewIntoEditorView(editorView)

    @injectLintStatusViewIntoStatusBar()
    atom.packages.once 'activated', =>
      @injectLintStatusViewIntoStatusBar()

    LinterConfig ?= require './linter-config'
    @configSubscription = atom.config.observe LinterConfig.ROOT_KEY, =>
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

  injectLintViewIntoEditorView: (editorView) ->
    return unless editorView.getPane()?
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
