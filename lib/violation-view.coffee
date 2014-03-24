{$, View, Range, Point} = require 'atom'
ViolationTooltip = require './violation-tooltip'

module.exports =
class ViolationView extends View
  @content: ->
    @div class: 'violation', =>
      @div class: 'violation-arrow'

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
      'top': pixelPosition.top
      'left': pixelPosition.left
      'width': @editorView.charWidth
      'height': @editorView.lineHeight + (arrowSize / 2)

    $arrow = @find('.violation-arrow')
    $arrow.css
      'border-right-width': arrowSize
      'border-bottom-width': arrowSize
      'border-left-width': arrowSize
    $arrow.addClass("violation-#{@violation.severity}")

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
