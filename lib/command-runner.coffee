{$} = require 'atom'
child_process = require 'child_process'
os = require 'os'
path = require 'path'
fs = require 'fs'

module.exports =
class CommandRunner
  CommandRunner.fetchPathEnvOfLoginShell = (callback) ->
    if !process.env.SHELL
      return callback(null, "SHELL environment variable is not set.")

    if process.env.SHELL.match(/csh$/)
      # csh/tcsh does not allow to execute a command (-c) in a login shell (-l).
      return callback(null, "#{process.env.SHELL} is not supported.")

    outputPath = path.join(os.tmpdir(), 'CommandRunner_fetchPathEnvOfLoginShell.txt')
    command = "#{process.env.SHELL} -l -i -c 'echo -n \"$PATH\" > #{outputPath}'"

    child_process.exec command, (execError, stdout, stderr) ->
      return callback(null, execError) if execError?
      fs.readFile outputPath, (readError, data) ->
        return callback(null, readError) if readError?
        callback(data.toString(), null)

  constructor: (@command) ->

  run: (callback) ->
    if @command[0].indexOf('/') == 0
      @runWithEnv(process.env, callback)
    else
      CommandRunner.fetchPathEnvOfLoginShell (path, error) =>
        env = if path?
                $.extend({}, process.env, { PATH: path })
              else
                process.env

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
      callback(result)
      hasInvokedCallback = true

    proc.on 'error', (error) ->
      return if hasInvokedCallback
      result.error = error
      callback(result)
      hasInvokedCallback = true
