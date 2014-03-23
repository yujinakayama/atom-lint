minimatch = require 'minimatch'

module.exports =
class LinterConfig
  @ROOT_KEY = 'atom-lint'

  constructor: (@linterKey) ->

  getBaseKeyPath: ->
    @getKeyPathForSubKey()

  getKeyPathForSubKey: (subKey) ->
    keys = [LinterConfig.ROOT_KEY, @linterKey]
    keys.push(subKey) if subKey?
    keys.join('.')

  get: (subKey) ->
    keyPath = @getKeyPathForSubKey(subKey)
    atom.config.get(keyPath)

  isFileToLint: (absolutePath) ->
    ignoredNames = @get('ignoredNames')
    return true unless ignoredNames?

    relativePath = atom.project.relativize(absolutePath)

    ignoredNames.every (ignoredName) ->
      !minimatch(relativePath, ignoredName)
