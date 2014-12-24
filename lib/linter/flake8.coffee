{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'
LinterError = require '../linter-error'

module.exports =
class Flake8
  @canonicalName = 'flake8'

  constructor: (@filePath) ->

  run: (callback) ->
    @runFlake8 (error, violations) ->
      if error?
        callback(error)
      else
        callback(null, violations)

  runFlake8: (callback) ->
    runner = new CommandRunner(@buildCommand())

    runner.run (error, result) ->
      return callback(error) if error?

      if result.exitCode == 0 || result.exitCode == 1
        # Flake8 returns errors as colon-delimited strings, so here
        # we massage them into violation objects that atom-lint expects
        violations = []
        for item in result.stdout.split '\n'
          if not item then continue

          elements = (x.trim() for x in item.split(':'))
          continue unless elements.length == 4
          [file, line, col, msg] = elements

          bufferPoint = new Point(parseInt(line) - 1, parseInt(col) - 1)
          bufferRange = new Range(bufferPoint, bufferPoint)

          # Use pep8 E/W codes, mark some PyFlakes F codes as errors
          # and make all C/N codes warnings. See:
          # http://flake8.readthedocs.org/en/latest/warnings.html
          severity = switch msg[0..3]
            when 'F821', 'F822', 'F823', 'F831' then 'error'
            else
              if msg[0] is 'E' then 'error' else 'warning'

          violations.push(new Violation(severity, bufferRange, msg))

        callback(null, violations)
      else
        callback(new LinterError("flake8 exited with code #{result.exitCode}", result))

  buildCommand: ->
    command = []

    userFlake8Path = atom.config.get('atom-lint.flake8.path')
    userFlake8Config = atom.config.get('atom-lint.flake8.configPath')

    if userFlake8Path?
      command.push(userFlake8Path)
    else
      command.push('flake8')

    if userFlake8Config?
      command.push("--config=#{userFlake8Config}")

    command.push(@filePath)
    command
