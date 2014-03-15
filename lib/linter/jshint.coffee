CheckstyleBase = require './checkstyle-base'

module.exports =
class JsHint extends CheckstyleBase
  buildCommand: ->
    command = []

    userJsHintPath = atom.config.get('atom-lint.jshint.path')

    if userJsHintPath?
      command.push(userJsHintPath)
    else
      command.push('jshint')

    command.push('--reporter', 'checkstyle')
    command.push(@filePath)
    command

  isValidExitCode: (exitCode) ->
    # JSHint returns an exit code of 2 when everything worked, but the check failed.
    # https://github.com/jshint/jshint/issues/916
    exitCode == 0 || exitCode == 2
