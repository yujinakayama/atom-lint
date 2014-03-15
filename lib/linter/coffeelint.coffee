JsHint = require './jshint'

module.exports =
class CoffeeLint extends JsHint
  constructCommand: ->
    command = []

    userCoffeeLintPath = atom.config.get('atom-lint.coffeelint.path')

    if userCoffeeLintPath?
      command.push(userCoffeeLintPath)
    else
      command.push('coffeelint')

    command.push('--checkstyle')
    command.push(@filePath)
    command
