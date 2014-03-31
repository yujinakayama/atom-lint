{$, View, Range, Point} = require 'atom'
ViolationTooltip = require './violation-tooltip'

module.exports =
class ViolationView extends View
  @content: ->
    @div class: 'violation', =>
      @div class: 'violation-arrow'
      @div class: 'violation-border'

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
      selector: @find('.violation-border')

  trackEdit: ->
    # :persistent -
    # Whether to include this marker when serializing the buffer. Defaults to true.
    #
    # :invalidate -
    # Determines the rules by which changes to the buffer *invalidate* the
    # marker. Defaults to 'overlap', but can be any of the following:
    # * 'never':
    #     The marker is never marked as invalid. This is a good choice for
    #     markers representing selections in an editor.
    # * 'surround':
    #     The marker is invalidated by changes that completely surround it.
    # * 'overlap':
    #     The marker is invalidated by changes that surround the start or
    #     end of the marker. This is the default.
    # * 'inside':
    #     The marker is invalidated by a change that touches the marked
    #     region in any way. This is the most fragile strategy.
    options = { invalidation: 'inside', persistent: false }
    @marker = @editor.markScreenRange(@getCurrentScreenRange(), options)
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
    startPixelPosition = @editorView.pixelPositionForScreenPosition(@startScreenPosition)
    endPixelPosition = @editorView.pixelPositionForScreenPosition(@endScreenPosition)
    arrowSize = @editorView.charWidth / 2
    verticalOffset = @editorView.lineHeight + Math.floor(arrowSize / 4)

    @css
      'top': startPixelPosition.top
      'left': startPixelPosition.left
      'width': @editorView.charWidth - (@editorView.charWidth % 2) # Adjust toolbar tip center
      'height': verticalOffset

    $arrow = @find('.violation-arrow')
    $arrow.css
      'border-right-width': arrowSize
      'border-bottom-width': arrowSize
      'border-left-width': arrowSize
    $arrow.addClass("violation-#{@violation.severity}")

    if @endScreenPosition.column - @startScreenPosition.column > 1
      borderThickness = 1
      borderOffset = arrowSize / 2
      $border = @find('.violation-border')
      $border.css
        'left': borderOffset # Avoid protruding left edge of the border from the arrow
        'width': endPixelPosition.left - startPixelPosition.left - borderOffset
        'height': verticalOffset
      $border.addClass("violation-#{@violation.severity}")

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
