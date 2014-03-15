CheckstyleBase = require './checkstyle-base'

module.exports =
class CoffeeLint extends CheckstyleBase
  buildCommand: ->
    command = []

    userCoffeeLintPath = atom.config.get('atom-lint.coffeelint.path')

    if userCoffeeLintPath?
      command.push(userCoffeeLintPath)
    else
      command.push('coffeelint')

    command.push('--checkstyle')
    command.push(@filePath)
    command

  isValidExitCode: (exitCode) ->
    # CoffeeLint returns an exit code of 2 when everything worked, but the check failed.
    # And code 1 for parse errors.
    0 <= exitCode <= 2
