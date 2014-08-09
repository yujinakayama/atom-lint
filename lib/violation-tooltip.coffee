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
                  '<span class="message"></span><wbr><span class="tags"></span>' +
                  '<div class="attachment"></div>' +
                '</div>' +
              '</div>'
  })

  getDefaults: ->
    ViolationTooltip.DEFAULTS

  setContent: ->
    $content = @tip().find('.tooltip-inner')
    violation = @options.violation

    $content.find('.message').html(violation.getMessageHTML() || '')
    $content.find('.tags').html(violation.getTagsHTML() || '')

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

    $content = @tip().find('.tooltip-inner')

    $code = $content.find('code, pre')

    if $code.length > 0
      frontColor = Color($content.css('color'))
      $code.css('color', frontColor.clone().rgbaString())
      $code.css('background-color', frontColor.clone().clearer(0.96).rgbaString())
      $code.css('border-color', frontColor.clone().clearer(0.86).rgbaString())
