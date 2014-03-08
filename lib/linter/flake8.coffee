{Range, Point} = require 'atom'
child_process = require 'child_process'
fs = require 'fs'
CommandRunner = require '../command-runner'

module.exports =
class Flake8
  constructor: (@filePath) ->

  run: (callback) ->
    @runFlake8 (err, violations) =>
      if err
        callback(null, err)
      else
        callback(violations, null)

  runFlake8: (callback) ->
    runner = new CommandRunner(@constructCommand())

    runner.run (result) ->
      return callback(null, result.error) if result.error?

      if result.exitCode == 0 || result.exitCode == 1
        # Flake8 returns errors as colon-delimited strings, so here
        # we massage them into violation objects that atom-lint expects
        violations = []
        for item in result.stdout.split '\n'
          if not item then continue

          [file, line, col, msg] = (x.trim() for x in item.split ':')

          bufferPoint = new Point parseInt(line) - 1, parseInt(col) - 1

          # Use pep8 E/W codes, mark some PyFlakes F codes as errors
          # and make all C/N codes warnings. See:
          # http://flake8.readthedocs.org/en/latest/warnings.html
          severity = switch msg[0..3]
            when 'F821', 'F822', 'F823', 'F831' then 'error'
            else
              if msg[0] is 'E' then 'error' else 'warning'

          violations.push
            severity: severity
            message: msg
            bufferRange: new Range bufferPoint, bufferPoint

        callback null, violations
      else
        callback(new Error "Process exited with code #{result.exitCode}")

  constructCommand: ->
    command = []

    userRubocopPath = atom.config.get('atom-lint.flake8.path')

    if userRubocopPath?
      command.push(userRubocopPath)
    else
      command.push('flake8')

    command.push(@filePath)
    command
