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

    # It looks good when tags fit in the last line of message:
    #                                                                          | Max width
    # | Prefer single-quoted strings when you don't need string interpolation  | Actual width
    # | or special symbols. [ Style/StringLiterals ]
    #                       ~~~~~ inline .tags ~~~~~

    # However there's an ugly padding when tags don't fit in the last line:
    #                                                                          | Max width
    # | Missing top-level module documentation comment.                        | Actual width
    # | [ Style/Documentation ]                         ~~~~~ugly padding~~~~~~
    #   ~~~~~ inline tags ~~~~~

    # Clear the padding by making the tags block element:
    #                                                                          | Max width
    # | Missing top-level module documentation comment. | Actual width
    # | [ Style/Documentation ]
    #   ~~~~~ block tags ~~~~~~
    unless @tagsFitsInLastLineOfMessage()
      @content().find('.tags').addClass('block-tags')

  tagsFitsInLastLineOfMessage: ->
    return @fits if @fits?

    # Make .tags inline element to check if it fits in the last line of message
    $tags = @content().find('.tags')
    $tags.css('display', 'inline')

    $message = @content().find('.message')
    messageBottom = $message.position().top + $message.height()

    $tags = @content().find('.tags')
    tagsBottom = $tags.position().top + $tags.height()

    $tags.css('display', '')

    @fits = (messageBottom == tagsBottom)

  content: ->
    @contentElement ?= @tip().find('.tooltip-inner')
