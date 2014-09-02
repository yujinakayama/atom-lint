fs = require 'fs-plus'
path = require 'path'

module.exports =
  get: ->
    return @ephemeralCache if @ephemeralCache?

    persistentCache = @loadPersistentCache()
    @ephemeralCache = @selectRicherEnv(persistentCache)
    @savePersistentCache(@ephemeralCache)
    @ephemeralCache

  clear: ->
    @clearEphemeralCache()
    @clearPersistentCache()

  clearEphemeralCache: ->
    @ephemeralCache = null

  clearPersistentCache: ->
    cacheFilePath = @getPersistentCacheFilePath()

    if fs.existsSync(cacheFilePath)
      fs.unlinkSync(cacheFilePath)

  selectRicherEnv: (cached) ->
    current = process.env

    return current if current.SHLVL?
    return cached if cached.SHLVL?

    if @getKeyCount(current) == @getKeyCount(cached)
      if current.PATH?.length >= cached.PATH?.length
        current
      else
        cached
    else if @getKeyCount(current) > @getKeyCount(cached)
      current
    else
      cached

  loadPersistentCache: ->
    cacheFilePath = @getPersistentCacheFilePath()

    if fs.existsSync(cacheFilePath)
      json = fs.readFileSync(cacheFilePath)
      JSON.parse(json)
    else
      {}

  savePersistentCache: (env) ->
    json = JSON.stringify(env)
    fs.writeFileSync(@getPersistentCacheFilePath(), json)

  getPersistentCacheFilePath: ->
    dotAtomPath = fs.absolute('~/.atom')
    path.join(dotAtomPath, 'storage', 'atom-lint-env.json')

  getKeyCount: (object) ->
    Object.keys(object).length
