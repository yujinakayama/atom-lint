indent = (string, width) ->
  indentation = ' '.repeat(width)
  indentation + string.split("\n").join("\n" + indentation)

module.exports =
class LinterError extends Error
  constructor: (message = undefined, commandResult = undefined) ->
    @message = message.toString() if message?
    @commandResult = commandResult
    Error.captureStackTrace(this, @constructor)

  name: @name

  toString: ->
    string = @name
    string += ": #{@message}" if @message

    if @commandResult?
      string += '\n'
      string += "    command: #{JSON.stringify(@commandResult.command)}\n"
      string += "    PATH: #{@commandResult.env.PATH}\n"
      string += "    exit code: #{@commandResult.exitCode}\n"
      string += '    stdout:\n'
      string += indent(@commandResult.stdout, 8) + '\n'
      string += '    stderr:\n'
      string += indent(@commandResult.stderr, 8)

    string
