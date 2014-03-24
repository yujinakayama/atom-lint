_ = require 'lodash'

module.exports =
class Violation
  @SEVERITIES = ['warning', 'error']

  constructor: (@severity, @bufferRange, @message) ->
    unless _.contains(Violation.SEVERITIES, @severity)
      message  = "Severity must be any of #{Violation.SEVERITIES.join(',')}. "
      message += "#{@severity} is passed."
      throw new Error(message)

  getHTML: ->
    null
