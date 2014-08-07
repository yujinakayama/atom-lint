Color = require 'color'
AnnotationTooltip = require './annotation-tooltip'

module.exports =
class ViolationTooltip extends AnnotationTooltip
  applyAdditionalStyle: ->
    super()

    $tip = @tip()
    $code = $tip.find('.tooltip-inner code, pre')

    if $code.length > 0
      frontColor = Color($tip.find('.tooltip-inner').css('color'))
      $code.css('color', frontColor.clone().rgbaString())
      $code.css('background-color', frontColor.clone().clearer(0.96).rgbaString())
      $code.css('border-color', frontColor.clone().clearer(0.86).rgbaString())
