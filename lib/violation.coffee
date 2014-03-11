_ = require 'lodash'

module.exports =
class Violation
  @SEVERITIES = ['warning', 'error']

  constructor: (@severity, @bufferRange, @message) ->
    unless _.contains(Violation.SEVERITIES, @severity)
      throw new Error("Severity must be any of #{Violation.SEVERITIES}.")
