Color = require 'color'
{$} = require 'atom'
AnnotationTooltip = require './annotation-tooltip'
Config = require './config'

module.exports =
class ViolationTooltip extends AnnotationTooltip
  @DEFAULTS = $.extend({}, AnnotationTooltip.DEFAULTS, {
    violation: null
    template: '<div class="tooltip">' +
                '<div class="tooltip-arrow"></div>' +
                '<div class="tooltip-inner">' +
                  '<span class="message"></span><wbr><span class="metadata"></span>' +
                  '<div class="attachment"></div>' +
                '</div>' +
              '</div>'
  })

  init: (type, element, options) ->
    super(type, element, options)

    @violation = options.violation

    @configSubscription = Config.onDidChange 'showViolationMetadata', (event) =>
      @switchMetadataDisplay()

  getDefaults: ->
    ViolationTooltip.DEFAULTS

  setContent: ->
    @setMessageContent()
    @setMetadataContent()
    @setAttachmentContent()
    @tip().removeClass('fade in top bottom left right')

  setMessageContent: ->
    @content().find('.message').html(@violation.getMessageHTML() || '')

  setMetadataContent: ->
    @content().find('.metadata').html(@violation.getMetadataHTML() || '')

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

    @switchMetadataDisplay()

  switchMetadataDisplay: ->
    if @shouldShowMetadata()
      # It looks good when metadata fit in the last line of message:
      #                                                                          | Max width
      # | Prefer single-quoted strings when you don't need string interpolation  | Actual width
      # | or special symbols. [ Style/StringLiterals ]
      #                       ~~~ inline .metadata ~~~

      # However there's an ugly padding when metadata don't fit in the last line:
      #                                                                          | Max width
      # | Missing top-level module documentation comment.                        | Actual width
      # | [ Style/Documentation ]                         ~~~~~ugly padding~~~~~~
      #   ~~~ inline metadata ~~~

      # Clear the padding by making the metadata block element:
      #                                                                          | Max width
      # | Missing top-level module documentation comment. | Actual width
      # | [ Style/Documentation ]
      #   ~~~ block metadata ~~~~
      unless @metadataFitInLastLineOfMessage()
        @content().find('.metadata').addClass('block-metadata')
    else
      @content().find('.metadata').hide()

  shouldShowMetadata: ->
    Config.get('showViolationMetadata')

  metadataFitInLastLineOfMessage: ->
    # Make .metadata inline element to check if it fits in the last line of message
    $metadata = @content().find('.metadata')
    $metadata.css('display', 'inline')

    $message = @content().find('.message')
    messageBottom = $message.position().top + $message.height()

    $metadata = @content().find('.metadata')
    metadataBottom = $metadata.position().top + $metadata.height()

    $metadata.css('display', '')

    messageBottom == metadataBottom

  content: ->
    @contentElement ?= @tip().find('.tooltip-inner')

  destroy: ->
    super()
    @configSubscription.off()
