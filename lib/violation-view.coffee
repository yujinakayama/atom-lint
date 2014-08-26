_ = require 'lodash'
{$, View, Range, Point} = require 'atom'
ViolationTooltip = require './violation-tooltip'

module.exports =
class ViolationView extends View
  @content: ->
    @div class: 'violation', =>
      @div class: 'violation-arrow'
      @div class: 'violation-area'

  initialize: (@violation, @lintView) ->
    @lintView.append(this)

    @editorView = @lintView.editorView
    @editor = @editorView.getEditor()

    @initializeSubviews()
    @initializeStates()

    @trackEdit()
    @trackCursor()
    @showHighlight()
    @toggleTooltipWithCursorPosition()

  initializeSubviews: ->
    @arrow = @find('.violation-arrow')
    @arrow.addClass("violation-#{@violation.severity}")

    @area = @find('.violation-area')
    @area.addClass("violation-#{@violation.severity}")

  initializeStates: ->
    screenRange = @editor.screenRangeForBufferRange(@violation.bufferRange)
    @screenStartPosition = screenRange.start
    @screenEndPosition = screenRange.end

    @isValid = true

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
    options = { invalidate: 'inside', persistent: false }
    @marker = @editor.markScreenRange(@getCurrentScreenRange(), options)

    @editor.decorateMarker(@marker, { type: 'gutter', class: "lint-#{@violation.severity}" })

    @marker.on 'changed', (event) =>
      # Head and Tail: Markers always have a head and sometimes have a tail.
      # If you think of a marker as an editor selection, the tail is the part that's stationary
      # and the head is the part that moves when the mouse is moved.
      # A marker without a tail always reports an empty range at the head position.
      # A marker with a head position greater than the tail is in a "normal" orientation.
      # If the head precedes the tail the marker is in a "reversed" orientation.
      @screenStartPosition = event.newTailScreenPosition
      @screenEndPosition = event.newHeadScreenPosition
      @isValid = event.isValid

      if @isValid
        if @isVisibleMarkerChange(event)
          # TODO: EditorView::pixelPositionForScreenPosition lies when a line above the marker was
          #   removed and it was invoked from this marker's "changed" event.
          setImmediate =>
            @showHighlight()
            @toggleTooltipWithCursorPosition()
        else
          # Defer repositioning views that are currently outside of visibile area of scroll view.
          # This is important to avoid UI freeze when so many markers are changed by a single
          # modification (e.g. inserting/deleting the first line in the file).

          # Hide the views for now, so that the repositioning-pending views won't be shown in the
          # visible area of the scroll view.
          @hide()

          # This should be held by each ViolationView instance. Otherwise it will be called only
          # once for all instance events.
          @scheduleDeferredShowHighlight ?= _.debounce(@showHighlight, 500)
          @scheduleDeferredShowHighlight()
      else
        @hideHighlight()
        @violationTooltip?.hide()

  isVisibleMarkerChange: (event) ->
    editorFirstVisibleRow = @editorView.getFirstVisibleScreenRow()
    editorLastVisibleRow = @editorView.getLastVisibleScreenRow()
    [event.oldTailScreenPosition, event.newTailScreenPosition].some (position) ->
      editorFirstVisibleRow <= position.row <= editorLastVisibleRow

  trackCursor: ->
    @subscribe @editor.getCursor(), 'moved', =>
      if @isValid
        @toggleTooltipWithCursorPosition()
      else
        @violationTooltip?.hide()

  showHighlight: ->
    @updateHighlight()
    @show()

  hideHighlight: ->
    @hide()

  updateHighlight: ->
    startPixelPosition = @editorView.pixelPositionForScreenPosition(@screenStartPosition)
    endPixelPosition = @editorView.pixelPositionForScreenPosition(@screenEndPosition)
    arrowSize = @editorView.charWidth / 2
    verticalOffset = @editorView.lineHeight + Math.floor(arrowSize / 4)

    @css
      'top': startPixelPosition.top
      'left': startPixelPosition.left
      'width': @editorView.charWidth - (@editorView.charWidth % 2) # Adjust toolbar tip center
      'height': verticalOffset

    @arrow.css
      'border-right-width': arrowSize
      'border-bottom-width': arrowSize
      'border-left-width': arrowSize

    borderThickness = 1
    borderOffset = arrowSize / 2
    @area.css
      'left': borderOffset # Avoid protruding left edge of the border from the arrow
      'width': endPixelPosition.left - startPixelPosition.left - borderOffset
      'height': verticalOffset
    if @screenEndPosition.column - @screenStartPosition.column > 1
      @area.addClass("violation-border")
    else
      @area.removeClass("violation-border")

  toggleTooltipWithCursorPosition: ->
    cursorPosition = @editor.getCursor().getScreenPosition()

    if cursorPosition.row is @screenStartPosition.row &&
       cursorPosition.column is @screenStartPosition.column
      # @tooltip conflicts with View's @tooltip function.
      @violationTooltip ?= @createViolationTooltip()
      @violationTooltip.show()
    else
      @violationTooltip?.hide()

  getCurrentBufferStartPosition: ->
    @editor.bufferPositionForScreenPosition(@screenStartPosition)

  getCurrentScreenRange: ->
    new Range(@screenStartPosition, @screenEndPosition)

  beforeRemove: ->
    @marker?.destroy()
    @violationTooltip?.destroy()

  createViolationTooltip: ->
    options =
      violation: @violation
      container: @lintView
      selector: @find('.violation-area')
      editorView: @editorView

    new ViolationTooltip(this, options)
