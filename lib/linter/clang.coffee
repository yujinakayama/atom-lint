{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'

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

    runner.run (error, result) ->
      return callback(error) if error?

      if result.exitCode == 0 || result.exitCode == 1

        violations = []
        items = result.stderr.split '\n'
        for item in items[...-1]

          pattern = ///
          ^(.+):(\d+):(\d+):\s*  # file / line / col
          (.*):\s* # severity
          ([^]+) # message
          ///

          matches = item.match(pattern)
          if !matches?
            pattern = ///^[In\ file\ included\ from\ ](.+):(\d+):/// # prefix / file / line
            matches = item.match(pattern)
            continue unless matches?
            [_, file, line] = matches
            if !prevLine? # It's possible that there will be a bunch of nested
                          # includes that should be ignored. We only want the
                          # line number from the first one
              prevLine = line
            continue
          [_, file, line, col, severity, msg] = matches
          severity = severity.trim()
          if severity == "note"
            # It might be nice to handle "notes" natively, but for now, they are ignored
            continue
          if severity == "fatal error"
            # These tend to be errors about missing headers
            severity = "error"
          if prevLine?
            line = prevLine # They don't point to the correct location themselves
                            # We parsed the correct location previously
            col = 1         # We don't know the correct column (thought it's probably 9)
            prevLine = null
          bufferPoint = new Point(parseInt(line) - 1, parseInt(col) - 1)
          bufferRange = new Range(bufferPoint, bufferPoint)
          violation = new Violation(severity, bufferRange, msg)
          violations.push(violation)

        callback(null, violations)
      else
        callback(new Error("Process exited with code #{result.exitCode}"))

  buildCommand: ->
    command = []

    userClangPath = atom.config.get('atom-lint.clang.path')
    userClangIncludes = atom.config.get('atom-lint.clang.headerSearchPaths')

    if userClangPath?
      command.push(userClangPath)
    else
      command.push('clang')

    command.push('-cc1')
    command.push('-fsyntax-only')
    command.push('-fno-caret-diagnostics')
    command.push('-Wall')
    if userClangIncludes?
      for item in userClangIncludes
        command.push("-I#{item}")
    command.push(@filePath)
    command
