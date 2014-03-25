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
