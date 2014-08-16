minimatch = require 'minimatch'

module.exports =
class Config
  @ROOT_KEY: 'atom-lint'

  @getAbsoluteKeyPath: (keys...) ->
    keys.unshift(@ROOT_KEY)
    keys.join('.')

  @get: (keyPath) ->
    absoluteKeyPath = @getAbsoluteKeyPath(keyPath)
    atom.config.get(absoluteKeyPath)

  @set: (keyPath, value) ->
    absoluteKeyPath = @getAbsoluteKeyPath(keyPath)
    atom.config.set(absoluteKeyPath, value)

  @observe: (args...) ->
    callback = args.pop()
    keyPath = args

    absoluteKeyPath = @getAbsoluteKeyPath(keyPath...)
    options = { callNow: false }
    atom.config.observe(absoluteKeyPath, options, callback)

  constructor: (@subKey) ->

  get: (keyPath) ->
    absoluteKeyPath = Config.getAbsoluteKeyPath(@subKey, keyPath)
    atom.config.get(absoluteKeyPath)

  isFileToLint: (absolutePath) ->
    linterIgnoredNames = @get('ignoredNames') || []
    globalIgnoredNames = Config.get('ignoredNames') || []
    ignoredNames = linterIgnoredNames.concat(globalIgnoredNames)

    relativePath = atom.project.relativize(absolutePath)

    ignoredNames.every (ignoredName) ->
      !minimatch(relativePath, ignoredName)
