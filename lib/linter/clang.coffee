{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'
LinterError = require '../linter-error'

# /Users/me/NAKPlaybackIndicatorContentView.h:19:9: fatal error: 'UIKit/UIKit.h' file not found
DIAGNOSTIC_PATTERN = ///
^(.+):(\d+):(\d+):  # file / line / column
\s*([^:]+)\s*: # severity
\s*([^]+) # message
///

# In file included from /Users/me/NAKPlaybackIndicatorContentView.m:9:
PRELIMINARY_PATTERN = /^In file included from (.+):(\d+):/ # file / line

module.exports =
class Clang
  @canonicalName = 'Clang'

  constructor: (@filePath) ->

  run: (callback) ->
    @runClang (error, violations) ->
      if error?
        callback(error)
      else
        callback(null, violations)

  runClang: (callback) ->
    runner = new CommandRunner(@buildCommand())

    runner.run (error, result) =>
      return callback(error) if error?

      if result.exitCode == 0 || result.exitCode == 1
        violations = @parseDiagnostics(result.stderr)
        callback(null, violations)
      else
        callback(new LinterError("clang exited with code #{result.exitCode}", result))

  parseDiagnostics: (log) ->
    lines = log.split('\n')

    for line in lines
      matches = line.match(DIAGNOSTIC_PATTERN)

      unless matches
        matches = line.match(PRELIMINARY_PATTERN)
        continue unless matches
        [_, filePath, lineNumber] = matches
        if filePath == @filePath
          actualLineNumberInTargetFile = lineNumber
        continue

      [_, _, lineNumber, columnNumber, severity, message] = matches

      # It might be nice to handle "notes" natively, but for now, they are ignored
      continue if severity == 'note'

      # These tend to be errors about missing headers
      severity = 'error' if severity == 'fatal error'

      if actualLineNumberInTargetFile?
        # They don't point to the correct location themselves
        # We parsed the correct location previously
        lineNumber = actualLineNumberInTargetFile
        columnNumber = 1 # We don't know the correct column (thought it's probably 9)
        actualLineNumberInTargetFile = null

      bufferPoint = new Point(parseInt(lineNumber) - 1, parseInt(columnNumber) - 1)
      bufferRange = new Range(bufferPoint, bufferPoint)
      new Violation(severity, bufferRange, message)

  buildCommand: ->
    command = []

    userClangPath = atom.config.get('atom-lint.clang.path')
    userHeaderSearchPaths = atom.config.get('atom-lint.clang.headerSearchPaths')

    if userClangPath?
      command.push(userClangPath)
    else
      command.push('clang')

    command.push('-fsyntax-only')
    command.push('-fno-caret-diagnostics')
    command.push('-Wall')

    if userHeaderSearchPaths?
      for path in userHeaderSearchPaths
        command.push("-I#{path}")

    command.push(@filePath)
    command
