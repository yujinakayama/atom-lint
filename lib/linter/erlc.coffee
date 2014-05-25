{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'
path = require 'path'

DIAGNOSTIC_PATTERN = ///
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
        violations = @parseDiagnostics(result.stdout)
        callback(null, violations)
      else
        callback(new Error("Process exited with code #{result.exitCode}"))

  parseDiagnostics: (log) ->
    # Example of erlc output
    # $ erlc <options> hello.erl
    # hello.erl:3: function goofy/1 undefined          # an error
    # hello.erl:12: Warning: function boo/0 is unused  # a warning

    lines = log.split('\n')

    for line in lines
      continue unless line

      matches = line.match(DIAGNOSTIC_PATTERN)
      continue unless matches
      [_, filePath, lineNumber, message] = matches

      severity = "error"

      if message.startsWith("Warning: ")
        severity = "warning"

      bufferPoint = new Point(parseInt(lineNumber) - 1, 0)
      bufferRange = new Range(bufferPoint, bufferPoint)
      new Violation(severity, bufferRange, message)

  buildCommand: ->
    # The official linter for Erlang is flymake within Emacs
    # Our build command works in the same way as erlang-flymake.el
    # see: https://github.com/erlang/otp/blob/maint/lib/tools/emacs/erlang-flymake.el
    command = []
    userErlcPath = atom.config.get('atom-lint.erlc.path')

    fileFullPath = @filePath
    filePathPart = path.dirname(fileFullPath)

    if userErlcPath?
      command.push(userErlcPath)
    else
      command.push('erlc')

    if filePathPart.endsWith("/src")
      parentPathPart = filePathPart.replace('/src', '/')
      command.push('-I', "#{ parentPathPart }include/")
      command.push('-I', "#{ parentPathPart }deps/")
      command.push('-pa', "#{ parentPathPart }ebin/")

    command.push('-Wall')
    command.push('+warn_obsolete_guard')
    command.push('+warn_unused_import')
    command.push('+warn_shadow_vars')
    command.push('+warn_export_vars')
    command.push('+strong_validation')
    command.push('+report')
    command.push(fileFullPath)
    # console.log(command.join(' ')) # Show the command
    command
