child_process = require 'child_process'
os = require 'os'
path = require 'path'
fs = require 'fs'
_ = require 'lodash'
{$} = require 'atom'

each_slice = (array, size, callback) ->
  for i in [0..array.length] by size
    slice = array.slice(i, i + size)
    callback(slice)

module.exports =
class CommandRunner
  @_cachedEnv = undefined

  @fetchEnvOfLoginShell = (callback) ->
    if !process.env.SHELL
      return callback(new Error("SHELL environment variable is not set."))

    if process.env.SHELL.match(/csh$/)
      # csh/tcsh does not allow to execute a command (-c) in a login shell (-l).
      return callback(new Error("#{process.env.SHELL} is not supported."))

    outputPath = path.join(os.tmpdir(), 'CommandRunner_fetchEnvOfLoginShell.txt')
    # Running non-shell-builtin command with -i (interactive) option causes shell to freeze with
    # CPU 100%. So we run it in subshell to make it non-interactive.
    command = "#{process.env.SHELL} -l -i -c '$(printenv > #{outputPath})'"

    child_process.exec command, (execError, stdout, stderr) =>
      return callback(execError) if execError?
      fs.readFile outputPath, (readError, data) =>
        return callback(readError) if readError?
        env = @parseResultOfPrintEnv(data.toString())
        callback(null, env)

  @parseResultOfPrintEnv: (string) ->
    env = {}

    # JS does not support lookbehind assertion.
    lines_and_last_chars = string.split(/([^\\])\n/)
    lines = each_slice lines_and_last_chars, 2, (slice) ->
      slice.join('')

    for line in lines
      matches = line.match(/^(.+?)=([\S\s]*)$/)
      continue unless matches?
      [_match, key, value] = matches
      continue if !(key?) || key.length == 0
      env[key] = value

    env

  @mergePathEnvs: (baseEnv, subsequentEnv) ->
    for key in ['PATH', 'GEM_PATH']
      baseEnv[key] = @mergePaths(baseEnv[key], subsequentEnv[key])
    baseEnv

  @mergePaths: (baseString, subsequentString) ->
    basePaths = if baseString then baseString.split(':') else []
    subsequentPaths = if subsequentString then subsequentString.split(':') else []
    paths = basePaths.concat(subsequentPaths)
    _.uniq(paths).join(':')

  @getEnv: (callback) ->
    if @_cachedEnv == undefined
      @fetchEnvOfLoginShell (error, env) =>
        env ?= {}
        @_cachedEnv = @mergePathEnvs(env, process.env)
        callback(@_cachedEnv)
    else
      callback(@_cachedEnv)

  constructor: (@command) ->

  run: (callback) ->
    CommandRunner.getEnv (env) =>
      env ?= process.env
      @runWithEnv(env, callback)

  runWithEnv: (env, callback) ->
    proc = child_process.spawn(@command[0], @command.splice(1), { env: env })

    result =
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
