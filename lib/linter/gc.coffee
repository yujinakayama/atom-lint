{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'
path = require 'path'
fs = require 'fs'

ERROR_PATTERN = /^\/+([^:]+):(\d+)(:(\d+))?: (.*)$/

module.exports =
class Gc
  @canonicalName = 'gc'

  @_cachedEnv = undefined

  # Grab the Go environment variables from the go tool. These variables won't
  # be in the system-wide env.
  @getEnv: (callback) ->
    callback(null, @_cachedEnv) unless @_cachedEnv == undefined

    runner = new CommandRunner(['go', 'env', 'GOARCH', 'GOOS', 'GOPATH', 'GOCHAR'])
    runner.run (error, result) =>
      return callback(error) if error?

      [GOARCH, GOOS, GOPATH, GOCHAR] = result.stdout.split('\n')
      @_cachedEnv =
        'GOARCH': GOARCH
        'GOOS': GOOS
        'GOPATH': GOPATH
        'GOCHAR': GOCHAR

      callback(null, @_cachedEnv)

  constructor: (@filePath) ->

  run: (callback) ->
    Gc.getEnv (error, env) =>
      return callback(error) if error?

      @runGoLint env, (error, violations) ->
        if error?
          callback(error)
        else
          callback(null, violations)

  runGoLint: (env, callback) ->
    runner = new CommandRunner(@buildCommand(env))
    runner.run (error, result) =>
      return callback(error) if error?

      violations = []
      items = result.stdout.split '\n'
      # skip sub-items under a file that is not in the active editor (since the
      # compiler will be reporting every file in the current dir since we have
      # to compile all of them to avoid "undefined" errors)
      skippingIndented = false

      for item in items
        if not item then continue

        if item[0] is '\t' and violations.length > 0
          # stuff like interfaces not being satisfied, etc will be indented
          unless skippingIndented
            violations[violations.length - 1].message += '\n' + item
        else
          [_, filePath, line, _, col, msg] = item.match(ERROR_PATTERN)
          filePath = '/' + filePath
          if filePath isnt @filePath
            skippingIndented = true
            continue

          skippingIndented = false

          line ||= '1'
          col ||= '1'

          bufferPoint = new Point(parseInt(line) - 1, parseInt(col) - 1)
          bufferRange = new Range(bufferPoint, bufferPoint)
          violations.push(new Violation('error', bufferRange, msg))

      callback(null, violations)

  # Build the compile command to be run, including relevant flags and setting
  # the import path to GOPATH/pkg (the go tool *g needs to be told explicitly,
  # normally `go build` does this all for us).
  # Opting for *g instead of go build because the linking would take up
  # unnecessary real and cpu time for no gain.
  buildCommand: (env) ->
    # compile with all the other files in the same directory so it doesn't
    # complain about missing identifiers, etc
    here = path.dirname(@filePath)

    files = fs.readdirSync(here).filter (file) ->
      path.extname(file) is '.go'
    .map (file) ->
      path.join(here, file)

    importSearchPath = "#{env.GOPATH}/pkg/#{env.GOOS}_#{env.GOARCH}"

    [
      atom.config.get('atom-lint.gc.path') || 'go'
      "tool"
      env.GOCHAR + 'g'
      "-L" # use full file paths
      "-e" # don't limit # of errors
      "-s" # warn about simplifiable composite literals
      "-o", "/dev/null"
      "-I", importSearchPath
      files...
    ]
