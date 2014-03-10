# Minimize additional startup time of Atom caused by atom-lint.
LintView = null

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

  disable: ->
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
    return if editorView.find('.lint').length > 0
    LintView ?= require './lint-view'
    lintView = new LintView(editorView)
    @lintViews.push(lintView)
    editorView.overlayer.append(lintView)
