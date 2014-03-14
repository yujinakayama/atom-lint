{Range, Point} = require 'atom'
CommandRunner = require '../command-runner'
Violation = require '../violation'
os = require 'os'
path = require 'path'
fs = require 'fs'

module.exports =
class GoLint
  constructor: (@filePath) ->
    @pattern = /^\/+([^:]+):(\d+)(:(\d+))?: (.*)$/
    @gotEnv = false

  run: (callback) ->
    f = () =>
      @runGoLint (error, violations) ->
        if error?
          callback(error)
        else
          callback(null, violations)

    if @gotEnv
      f()
    else
      @getEnv f

  runGoLint: (callback) ->
    runner = new CommandRunner(@buildCommand())
    runner.run (error, result) =>
      if error?
        return callback(error)

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
          if not skippingIndented
            violations[violations.length-1].message += '\n' + item
        else
          [_, filePath, line, _, col, msg] = item.match(@pattern)
          filePath = '/' + filePath
          if filePath isnt @filePath
            skippingIndented = true
            continue

          skippingIndented = false

          line ||= '1'
          col ||= '1'

          bufferPoint = new Point(parseInt(line)-1, parseInt(col)-1)
          bufferRange = new Range(bufferPoint, bufferPoint)
          violations.push(new Violation('error', bufferRange, msg))

      callback(null, violations)

  # Grab the Go environment variables from the go tool. These variables won't
  # be in the system-wide env (hence not accessible from process.env) unless
  # they're in launchd.
  #
  # Speaking of launchd, GOPATH *still* won't be visible until it's in launchd.
  # So users of this must put 'launchctl setenv GOPATH $GOPATH' wherever they
  # set GOPATH, like in a .bash_profile or whatever.
  getEnv: (callback) ->
    (new CommandRunner([
      "go"
      "env"
      "GOARCH"
      "GOOS"
      "GOPATH"
      "GOCHAR"
    ])).run (error, result) =>
      if not error?
        [@GOARCH, @GOOS, @GOPATH, @GOCHAR] = result.stdout.split('\n')
        @importpath = "#{@GOPATH}/pkg/#{@GOOS}_#{@GOARCH}"
        @gotEnv = true
        callback()

  # Build the compile command to be run, including relevant flags and setting
  # the import path to GOPATH/pkg (the go tool *g needs to be told explicitly,
  # normally `go build` does this all for us)
  buildCommand: () ->
    # compile with all the other files in the same directory so it doesn't
    # complain about missing identifiers, etc
    here = path.dirname(@filePath)
    files = fs.readdirSync(here).filter (file) ->
      path.extname(file) in ['.go', '.c', '.h', '.s', '.cpp', '.cc', '.m']
    .map (file) ->
      path.join(here, file)

    gotool = atom.config.get('atom-lint.gc.path')
    if not gotool?
      gotool = "go"

    [
      gotool
      "tool"
      @GOCHAR + 'g'
      "-L" # use full file paths
      "-e" # don't limit # of errors
      "-s" # warn about simplifiable composite literals
      "-o", "/dev/null"
      "-I", @importpath
      files...
    ]
