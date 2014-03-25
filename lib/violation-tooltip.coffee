{$} = require 'atom'
Color = require 'color'
window.jQuery = $
require '../vendor/bootstrap/js/tooltip'
Tooltip = $.fn.tooltip.Constructor

module.exports =
class ViolationTooltip extends Tooltip
  @DEFAULTS = $.extend({}, Tooltip.DEFAULTS, { placement: 'bottom auto' })

  getDefaults: ->
    ViolationTooltip.DEFAULTS

  show: ->
    `
    var e = $.Event('show.bs.' + this.type)

    if (this.hasContent() && this.enabled) {
      this.$element.trigger(e)

      if (e.isDefaultPrevented()) return
      var that = this;

      var $tip = this.tip()

      this.setContent()

      if (this.options.animation) $tip.addClass('fade')

      var placement = typeof this.options.placement == 'function' ?
        this.options.placement.call(this, $tip[0], this.$element[0]) :
        this.options.placement

      var autoToken = /\s?auto?\s?/i
      var autoPlace = autoToken.test(placement)
      if (autoPlace) placement = placement.replace(autoToken, '') || 'top'

      $tip
        .detach()
        .css({ top: 0, left: 0, display: 'block' })
        .addClass(placement)

      if (this.options.container) {
        $tip.appendTo(this.options.container)
      } else {
        $tip.insertAfter(this.$element)
      }

      var pos          = this.getPosition()
      var actualWidth  = $tip[0].offsetWidth
      var actualHeight = $tip[0].offsetHeight

      if (autoPlace) {
        var $parent = this.$element.parent()

        var orgPlacement = placement
        var parentWidth  =
          this.options.container == 'body' ? window.innerWidth  : $parent.outerWidth()
        var parentHeight =
          this.options.container == 'body' ? window.innerHeight : $parent.outerHeight()
        var parentLeft   = this.options.container == 'body' ? 0 : $parent.offset().left
        var logicalPos   = this.getLogicalPosition()

        placement =
          placement == 'bottom' &&
               logicalPos.top + logicalPos.height + actualHeight > parentHeight ? 'top'    :
          placement == 'top'    && logicalPos.top   - actualHeight < 0          ? 'bottom' :
          placement == 'right'  && logicalPos.right + actualWidth > parentWidth ? 'left'   :
          placement == 'left'   && logicalPos.left  - actualWidth < parentLeft  ? 'right'  :
          placement

        $tip
          .removeClass(orgPlacement)
          .addClass(placement)
      }

      var calculatedOffset = this.getCalculatedOffset(placement, pos, actualWidth, actualHeight)

      this.applyPlacement(calculatedOffset, placement)
      this.hoverState = null

      var complete = function() {
        that.$element.trigger('shown.bs.' + that.type)
      }

      $.support.transition && this.$tip.hasClass('fade') ?
        $tip
          .one($.support.transition.end, complete)
          .emulateTransitionEnd(150) :
        complete()
    }
    `

    # The event 'show.bs.tooltip' is too early,
    # and 'shown.bs.tooltip' is a bit late.
    @applyAdditionalStyle()

  applyPlacement: (offset, placement) ->
    `
    var replace
    var $tip   = this.tip()
    var width  = $tip[0].offsetWidth
    var height = $tip[0].offsetHeight

    // manually read margins because getBoundingClientRect includes difference
    var marginTop = parseInt($tip.css('margin-top'), 10)
    var marginLeft = parseInt($tip.css('margin-left'), 10)

    // we must check for NaN for ie 8/9
    if (isNaN(marginTop))  marginTop  = 0
    if (isNaN(marginLeft)) marginLeft = 0

    offset.top  = offset.top  + marginTop
    offset.left = offset.left + marginLeft

    // $.fn.offset doesn't round pixel values
    // so we use setOffset directly with our own function B-0
    $.offset.setOffset($tip[0], $.extend({
      using: function (props) {
        $tip.css({
          top: Math.round(props.top),
          left: Math.round(props.left)
        })
      }
    }, offset), 0)

    $tip.addClass('in')

    // check to see if placing tip in new offset caused the tip to resize itself
    var actualWidth  = $tip[0].offsetWidth
    var actualHeight = $tip[0].offsetHeight

    if (placement == 'top' && actualHeight != height) {
      replace = true
      offset.top = offset.top + height - actualHeight
    }

    if (/bottom|top/.test(placement)) {
      var delta = 0

      if (offset.left < 0) {
        delta       = offset.left * -2
        offset.left = 0

        $tip.offset(offset)

        actualWidth  = $tip[0].offsetWidth
        actualHeight = $tip[0].offsetHeight
      }

      this.replaceArrow(delta - width + actualWidth, actualWidth, 'left')
    } else {
      this.replaceArrow(actualHeight - height, actualHeight, 'top')
    }

    if (replace) $tip.offset(offset)
    `

    return # Avoid the JavaScript snippet being discarded by CoffeeScript compiler

  setContent: ->
    $tip  = @tip()
    title = @getTitle()

    $tip.find('.tooltip-inner')[if @options.html then 'html' else 'text'](title)
    $tip.removeClass('fade in top bottom left right')

  # Alternative ::getPosition implementation that returns logical position in the parent view.
  # The scroll position of the editor doesn't affect to this value while ::getPosition is affected.
  getLogicalPosition: ->
    el = @$element[0]
    position = @$element.position()
    position.width = el.offsetWidth
    position.height = el.offsetHeight
    position.right = position.left + position.width
    position.bottom = position.top + position.height
    position

  getCalculatedOffset: (placement, pos, actualWidth, actualHeight) ->
    switch placement
      when 'bottom'
        top: pos.top + pos.height
        left: pos.left + pos.width / 2
      when 'top'
        top: pos.top - actualHeight
        left: pos.left + pos.width / 2

  applyAdditionalStyle: ->
    $tip = @tip()
    $pre = $tip.find('.tooltip-inner pre')

    frontColor = Color($tip.find('.tooltip-inner').css('color'))
    $pre.css('color', frontColor.clone().rgbString())
    $pre.css('background-color', frontColor.clone().clearer(0.96).rgbString())
    $pre.css('border-color', frontColor.clone().clearer(0.86).rgbString())
