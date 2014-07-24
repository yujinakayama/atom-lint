path = require 'path'
{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'
LinterError = require '../linter-error'

ERROR_PATTERN = ///
^(.+):(\d+):  # file / line
\s*([^]+) # message
///

module.exports =
class Erlc
  @canonicalName = 'erlc'

  constructor: (@filePath) ->

  run: (callback) ->
    @runErlc (error, violations) ->
      if error?
        callback(error)
      else
        callback(null, violations)

  runErlc: (callback) ->
    runner = new CommandRunner(@buildCommand())

    runner.run (error, result) =>
      return callback(error) if error?

      if result.exitCode == 0 || result.exitCode == 1
        violations = @parseLog(result.stdout)
        callback(null, violations)
      else
        callback(new LinterError("erlc exited with code #{result.exitCode}", result))

  parseLog: (log) ->
    # Example of erlc output
    # $ erlc <options> hello.erl
    # hello.erl:3: function goofy/1 undefined          # an error
    # hello.erl:12: Warning: function boo/0 is unused  # a warning

    lines = log.split('\n')

    for line in lines
      continue unless line

      matches = line.match(ERROR_PATTERN)
      continue unless matches
      [_, filePath, lineNumber, message] = matches

      severity = 'error'

      if message.startsWith('Warning: ')
        severity = 'warning'

      bufferPoint = new Point(parseInt(lineNumber) - 1, 0)
      bufferRange = new Range(bufferPoint, bufferPoint)
      new Violation(severity, bufferRange, message)

  buildCommand: ->
    # The official linter for Erlang is flymake within Emacs
    # Our build command works in the same way as erlang-flymake.el
    # see: https://github.com/erlang/otp/blob/maint/lib/tools/emacs/erlang-flymake.el
    command = []

    userErlcPath = atom.config.get('atom-lint.erlc.path')

    if userErlcPath?
      command.push(userErlcPath)
    else
      command.push('erlc')

    directoryPath = path.dirname(@filePath)

    if directoryPath.endsWith('/src')
      projectRoot = path.dirname(directoryPath)
      command.push('-I', path.join(projectRoot, 'include'))
      command.push('-I', path.join(projectRoot, 'deps'))
      command.push('-pa', path.join(projectRoot, 'ebin'))

    command.push('-Wall')
    command.push('+warn_obsolete_guard')
    command.push('+warn_unused_import')
    command.push('+warn_shadow_vars')
    command.push('+warn_export_vars')
    command.push('+strong_validation')
    command.push('+report')
    command.push(@filePath)
    command
