child_process = require 'child_process'
os = require 'os'
path = require 'path'
fs = require 'fs'
{$} = require 'atom'

module.exports =
class CommandRunner
  @_cachedPathEnvOfLoginShell = undefined

  @fetchPathEnvOfLoginShell = (callback) ->
    if !process.env.SHELL
      return callback(new Error("SHELL environment variable is not set."))

    if process.env.SHELL.match(/csh$/)
      # csh/tcsh does not allow to execute a command (-c) in a login shell (-l).
      return callback(new Error("#{process.env.SHELL} is not supported."))

    outputPath = path.join(os.tmpdir(), 'CommandRunner_fetchPathEnvOfLoginShell.txt')
    command = "#{process.env.SHELL} -l -i -c 'echo -n \"$PATH\" > #{outputPath}'"

    child_process.exec command, (execError, stdout, stderr) ->
      return callback(execError) if execError?
      fs.readFile outputPath, (readError, data) ->
        return callback(readError) if readError?
        callback(null, data.toString())

  @getPathEnvOfLoginShell = (callback) ->
    if @_cachedPathEnvOfLoginShell == undefined
      @fetchPathEnvOfLoginShell (error, path) =>
        @_cachedPathEnvOfLoginShell = path || null
        callback(path)
    else
      callback(@_cachedPathEnvOfLoginShell)

  constructor: (@command) ->

  run: (callback) ->
    if @command[0].indexOf('/') == 0
      @runWithEnv(process.env, callback)
    else
      CommandRunner.getPathEnvOfLoginShell (path) =>
        env =
          if path?
            $.extend({}, process.env, { PATH: path })
          else
            process.env

        @runWithEnv(env, callback)

  runWithEnv: (env, callback) ->
    proc = child_process.spawn(@command[0], @command.splice(1), { env: env })

    if @stdin?
        proc.stdin.end @stdin, "utf-8"

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
