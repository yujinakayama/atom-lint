child_process = require 'child_process'
os = require 'os'
path = require 'path'
fs = require 'fs'
crypto = require 'crypto'
_ = require 'lodash'

each_slice = (array, size, callback) ->
  for i in [0..array.length] by size
    slice = array.slice(i, i + size)
    callback(slice)

module.exports =
class CommandRunner
  @fetchEnvOfLoginShell: (callback) ->
    if !process.env.SHELL
      return callback(new Error("SHELL environment variable is not set."))

    if process.env.SHELL.match(/csh$/)
      # csh/tcsh does not allow to execute a command (-c) in a login shell (-l).
      return callback(new Error("#{process.env.SHELL} is not supported."))

    outputPath = @getEnvOutputFilePath()
    # Running non-shell-builtin command with -i (interactive) option causes shell to freeze with
    # CPU 100%. So we run it in subshell to make it non-interactive.
    command = "#{process.env.SHELL} -l -i -c '$(printenv > #{outputPath})'"

    child_process.exec command, (execError, stdout, stderr) =>
      return callback(execError) if execError?

      fs.readFile outputPath, (readError, data) =>
        fs.unlinkSync(outputPath) if fs.existsSync(outputPath)
        return callback(readError) if readError?

        env = @parseResultOfPrintEnv(data.toString())
        callback(null, env)

  @getEnvOutputFilePath: ->
    randomHex = crypto.randomBytes(20).toString('hex')
    outputPath = path.join(os.tmpdir(), "atom-lint_#{randomHex}.txt")
    fs.unlinkSync(outputPath) if fs.existsSync(outputPath)
    outputPath

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
    if @cachedEnv == undefined
      @fetchEnvOfLoginShell (error, env) =>
        console.log(error.stack) if error? && !@supressError

        if env?
          @cachedEnv = @mergePathEnvs(env, process.env)
        else
          @cachedEnv = process.env

        callback(@cachedEnv)
    else
      callback(@cachedEnv)

  constructor: (@command) ->

  run: (callback) ->
    CommandRunner.getEnv (env) =>
      @runWithEnv(env, callback)

  runWithEnv: (env, callback) ->
    options =
      env: env
      cwd: atom.project.path

    proc = child_process.spawn(@command[0], @command.slice(1), options)

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
