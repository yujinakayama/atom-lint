{$, View, Range, Point} = require 'atom'
ViolationTooltip = require './violation-tooltip'

module.exports =
class ViolationView extends View
  @content: ->
    @div class: 'violation', =>
      @div class: 'violation-arrow'

  initialize: (@violation, @lintView) ->
    @lintView.append(this)

    @editorView = @lintView.editorView
    @editor = @editorView.getEditor()

    screenRange = @editor.screenRangeForBufferRange(@violation.bufferRange)
    @startScreenPosition = screenRange.start
    @endScreenPosition = screenRange.end

    @prepareTooltip()
    @trackEdit()
    @trackCursor()
    @showArrow()
    @toggleTooltipWithCursorPosition()

  prepareTooltip: ->
    HTML = @violation.getHTML()
    @violationTooltip
      title: HTML || @violation.message
      html: HTML?
      container: @lintView

  trackEdit: ->
    @marker = @editor.markScreenRange(@getCurrentScreenRange(), invalidation: 'inside')
    @marker.on 'changed', ({newHeadScreenPosition, newTailScreenPosition, isValid}) =>
      # Head and Tail: Markers always have a head and sometimes have a tail.
      # If you think of a marker as an editor selection, the tail is the part that's stationary
      # and the head is the part that moves when the mouse is moved.
      # A marker without a tail always reports an empty range at the head position.
      # A marker with a head position greater than the tail is in a "normal" orientation.
      # If the head precedes the tail the marker is in a "reversed" orientation.
      @startScreenPosition = newTailScreenPosition
      @endScreenPosition = newHeadScreenPosition
      if isValid
        @violationTooltip('show')
      else
        @violationTooltip('hide')

  trackCursor: ->
    @subscribe @editor.getCursor(), 'moved', =>
      @toggleTooltipWithCursorPosition()

  toggleTooltipWithCursorPosition: ->
    cursorPosition = @editor.getCursor().getScreenPosition()

    if cursorPosition.row is @startScreenPosition.row &&
       cursorPosition.column is @startScreenPosition.column
      @violationTooltip('show')
    else
      @violationTooltip('hide')

  showArrow: ->
    pixelPosition = @editorView.pixelPositionForScreenPosition(@getCurrentScreenRange().start)
    arrowSize = @editorView.charWidth / 2

    @css
      'top': pixelPosition.top
      'left': pixelPosition.left
      'width': @editorView.charWidth - (@editorView.charWidth % 2) # Adjust toolbar tip center
      'height': @editorView.lineHeight + (arrowSize / 4)

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
    new Range(@startScreenPosition, @endScreenPosition)

  violationTooltip: (option) ->
    violationView = this
    @each ->
      $this = $(this)
      data = $this.data('bs.tooltip')
      options = typeof option == 'object' && option
      options.violationView = violationView

      if !data
        $this.data('bs.tooltip', (data = new ViolationTooltip(this, options)))
      if typeof option == 'string'
        data[option]()

  beforeRemove: ->
    @marker?.destroy()
    @violationTooltip('destroy')
