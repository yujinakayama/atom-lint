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

  init: (type, element, options) ->
    super(type, element, options)
    @violation = options.violation

  getDefaults: ->
    ViolationTooltip.DEFAULTS

  setContent: ->
    @setMessageContent()
    @setTagsContent()
    @setAttachmentContent()
    @tip().removeClass('fade in top bottom left right')

  setMessageContent: ->
    @content().find('.message').html(@violation.getMessageHTML() || '')

  setTagsContent: ->
    @content().find('.tags').html(@violation.getTagsHTML() || '')

  setAttachmentContent: ->
    $attachment = @content().find('.attachment')
    HTML = @violation.getAttachmentHTML()
    if HTML?
      $attachment.html(HTML)
    else
      $attachment.hide()

  hasContent: ->
    @violation?

  applyAdditionalStyle: ->
    super()

    $code = @content().find('code, pre')

    if $code.length > 0
      frontColor = Color(@content().css('color'))
      $code.css('color', frontColor.clone().rgbaString())
      $code.css('background-color', frontColor.clone().clearer(0.96).rgbaString())
      $code.css('border-color', frontColor.clone().clearer(0.86).rgbaString())

  content: ->
    @contentElement ?= @tip().find('.tooltip-inner')
