{$} = require 'atom'
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
