child_process = require 'child_process'
EnvStore = require './env-store'

module.exports =
class CommandRunner
  constructor: (@command) ->

  run: (callback) ->
    env = Object.create(EnvStore.get())
    npm_bin = atom.project.getPaths().map (p) -> path.join(p, 'node_modules', '.bin')
    env.PATH = npm_bin.concat(env.PATH).join(path.delimiter)
    @runWithEnv(env, callback)

  runWithEnv: (env, callback) ->
    proc = @createChildProcess(env)

    result =
      command: @command
      env: env
      stdout: ''
      stderr: ''

    hasInvokedCallback = false

    proc.stdout.on 'data', (data) ->
      result.stdout += data

    proc.stderr.on 'data', (data) ->
      result.stderr += data

    proc.on 'close', (exitCode) ->
      return if hasInvokedCallback
      result.exitCode = exitCode
      callback(null, result)
      hasInvokedCallback = true

    proc.on 'error', (error) ->
      return if hasInvokedCallback
      callback(error, result)
      hasInvokedCallback = true

  createChildProcess: (env) ->
    options = { env: env }
    options.cwd = atom.project.path if atom.project.path

    if process.platform == 'win32'
      options.windowsVerbatimArguments = true
      child_process.spawn('cmd', ['/s', '/c', '"' + @command.join(' ') + '"'], options)
    else
      child_process.spawn(@command[0], @command.slice(1), options)
