minimatch = require 'minimatch'

module.exports =
class LinterConfig
  @ROOT_KEY = 'atom-lint'

  constructor: (@linterKey) ->

  getKeyPathForSubKeys: (keys...) ->
    keys.unshift(LinterConfig.ROOT_KEY)
    keys.join('.')

  getLinterSetting: (key) ->
    keyPath = @getKeyPathForSubKeys(@linterKey, key)
    atom.config.get(keyPath)

  getGlobalSetting: (key) ->
    keyPath = @getKeyPathForSubKeys(key)
    atom.config.get(keyPath)

  isFileToLint: (absolutePath) ->
    linterIgnoredNames = @getLinterSetting('ignoredNames') || []
    globalIgnoredNames = @getGlobalSetting('ignoredNames') || []
    ignoredNames = linterIgnoredNames.concat(globalIgnoredNames)

    relativePath = atom.project.relativize(absolutePath)

    ignoredNames.every (ignoredName) ->
      !minimatch(relativePath, ignoredName)
