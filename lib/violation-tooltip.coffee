Color = require 'color'
{$} = require 'atom'
AnnotationTooltip = require './annotation-tooltip'

module.exports =
class ViolationTooltip extends AnnotationTooltip
  @DEFAULTS = $.extend({}, AnnotationTooltip.DEFAULTS, {
    violation: null
    template: '<div class="tooltip">' +
                '<div class="tooltip-arrow"></div>' +
                '<div class="tooltip-inner">' +
                  '<div class="message"></div>' +
                  '<div class="attachment"></div>' +
                  '<div class="metadata"></div>' +
                '</div>' +
              '</div>'
  })

  getDefaults: ->
    ViolationTooltip.DEFAULTS

  setContent: ->
    $content = @tip().find('.tooltip-inner')
    violation = @options.violation

    $content.find('.message').html(violation.getMessageHTML())

    $attachment = $content.find('.attachment')
    attachment = violation.getAttachmentHTML()
    if attachment?
      $attachment.html(attachment)
    else
      $attachment.hide()

    @tip().removeClass('fade in top bottom left right')

  hasContent: ->
    @options.violation?

  applyAdditionalStyle: ->
    super()

    $tip = @tip()
    $code = $tip.find('.tooltip-inner code, pre')

    if $code.length > 0
      frontColor = Color($tip.find('.tooltip-inner').css('color'))
      $code.css('color', frontColor.clone().rgbaString())
      $code.css('background-color', frontColor.clone().clearer(0.96).rgbaString())
      $code.css('border-color', frontColor.clone().clearer(0.86).rgbaString())
