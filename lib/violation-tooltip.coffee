{$} = require 'atom'
Color = require 'color'
window.jQuery = $
require '../vendor/bootstrap/js/tooltip'
Tooltip = $.fn.tooltip.Constructor

module.exports =
class ViolationTooltip extends Tooltip
  @DEFAULTS = $.extend({}, Tooltip.DEFAULTS, { placement: 'bottom' })

  getDefaults: ->
    ViolationTooltip.DEFAULTS

  getCalculatedOffset: (placement, pos, actualWidth, actualHeight) ->
    top: pos.top + pos.height
    left: pos.left + pos.width / 2

  # The event 'show.bs.tooltip' is too early,
  # and 'shown.bs.tooltip' is a bit late.
  show: ->
    super()
    @applyAdditionalStyle()

  applyAdditionalStyle: ->
    $tip = @tip()
    $pre = $tip.find('.tooltip-inner pre')

    frontColor = Color($tip.find('.tooltip-inner').css('color'))
    $pre.css('color', frontColor.clone().rgbString())
    $pre.css('background-color', frontColor.clone().clearer(0.96).rgbString())
    $pre.css('border-color', frontColor.clone().clearer(0.86).rgbString())
