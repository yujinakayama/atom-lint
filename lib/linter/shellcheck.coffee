{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'

module.exports =
class ShellCheck
  @canonicalName = 'ShellCheck'

  constructor: (@filePath) ->

  run: (callback) ->
    @runShellCheck (error, comments) =>
      return callback(error) if error?
      violations = comments.map(@createViolationFromComment)
      callback(null, violations)

  createViolationFromComment: (comment) ->
    bufferPoint = new Point(comment.line - 1, comment.column - 1)
    bufferRange = new Range(bufferPoint, bufferPoint)
    # https://github.com/koalaman/shellcheck/blob/master/ShellCheck/Simple.hs#L61-L64
    severity = if comment.level == 'error' then 'error' else 'warning'
    new Violation(severity, bufferRange, comment.message)

  runShellCheck: (callback) ->
    runner = new CommandRunner(@buildCommand())

    runner.run (error, result) ->
      return callback(error) if error?

      # https://github.com/koalaman/shellcheck/blob/v0.3.2/shellcheck.hs#L263
      if result.exitCode == 0 || result.exitCode == 1
        try
          callback(null, JSON.parse(result.stdout))
        catch error
          callback(error)
      else
        callback(new Error("Process exited with code #{result.exitCode}"))

  buildCommand: ->
    command = []

    userShellCheckPath = atom.config.get('atom-lint.shellcheck.path')

    if userShellCheckPath?
      command.push(userShellCheckPath)
    else
      command.push('shellcheck')

    command.push('--format', 'json', @filePath)
    command
