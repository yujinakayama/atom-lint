{$, View, Range, Point} = require 'atom'
ViolationTooltip = require './violation-tooltip'

module.exports =
class ViolationView extends View
  @content: ->
    @div class: 'violation'

  initialize: (@violation, @lintView) ->
    @editorView = @lintView.editorView
    @editor = @editorView.getEditor()

    screenRange = @editor.screenRangeForBufferRange(@violation.bufferRange)
    @headScreenPosition = screenRange.start
    @tailScreenPosition = screenRange.end

    @prepareTooltip()
    @trackEdit()
    @trackCursor()
    @showArrow()

  prepareTooltip: ->
    HTML = @violation.getHTML()
    @violationTooltip
      title: HTML || @violation.message
      html: HTML?
      container: @lintView
      viewport: @lintView

  trackEdit: ->
    @marker = @editor.markScreenRange(@getCurrentScreenRange(), invalidation: 'inside')
    @marker.on 'changed', ({newHeadScreenPosition, newTailScreenPosition, isValid}) =>
      @headScreenPosition = newHeadScreenPosition
      @tailScreenPosition = newTailScreenPosition
      if isValid
        @violationTooltip('show')
      else
        @violationTooltip('hide')

  trackCursor: ->
    @subscribe @editor.getCursor(), 'moved', (event) =>
      {newScreenPosition} = event
      if newScreenPosition.row is @headScreenPosition.row &&
         newScreenPosition.column is @tailScreenPosition.column
        @violationTooltip('show')
      else
        @violationTooltip('hide')

  showArrow: ->
    pixelPosition = @editorView.pixelPositionForScreenPosition(@getCurrentScreenRange().start)
    arrowSize = @editorView.charWidth / 2
    @css
      'border-right-width': arrowSize
      'border-bottom-width': arrowSize
      'border-left-width': arrowSize
      'top': pixelPosition.top + @editorView.lineHeight - (arrowSize / 2)
      'left': pixelPosition.left
    @addClass("violation-#{@violation.severity}")
    @show()

  hideArrow: ->
    @hide()

  getCurrentScreenRange: ->
    new Range(@headScreenPosition, @tailScreenPosition)

  violationTooltip: (option) ->
    @each ->
      $this = $(this)
      data = $this.data('bs.tooltip')
      options = typeof option == 'object' && option

      if !data
        $this.data('bs.tooltip', (data = new ViolationTooltip(this, options)))
      if typeof option == 'string'
        data[option]()

  beforeRemove: ->
    @marker?.destroy()
    @violationTooltip('destroy')
