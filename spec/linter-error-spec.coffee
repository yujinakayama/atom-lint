LinterError = require '../lib/linter-error'
CommandRunner = require '../lib/command-runner'

describe 'LinterError', ->
  # coffeelint: disable=max_line_length
  commandResult =
    command: ['rubocop', '--foo']
    env:
      PATH: '/Users/me/.rbenv/bin:/Users/me/.cabal/bin:/Users/me/bin:/Users/me/.dotfiles/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/Users/me/.rbenv/shims:/Users/me/.go/bin'
    exitCode: 123
    stdout: 'foo'
    stderr: """
invalid option: --foo
/Users/me/.rbenv/versions/2.1.2/lib/ruby/gems/2.1.0/gems/rubocop-0.24.1/lib/rubocop/options.rb:82:in `parse'
/Users/me/.rbenv/versions/2.1.2/lib/ruby/gems/2.1.0/gems/rubocop-0.24.1/lib/rubocop/cli.rb:19:in `run'
/Users/me/.rbenv/versions/2.1.2/lib/ruby/gems/2.1.0/gems/rubocop-0.24.1/bin/rubocop:14:in `block in <top (required)>'
/Users/me/.rbenv/versions/2.1.2/lib/ruby/2.1.0/benchmark.rb:294:in `realtime'
/Users/me/.rbenv/versions/2.1.2/lib/ruby/gems/2.1.0/gems/rubocop-0.24.1/bin/rubocop:13:in `<top (required)>'
/Users/me/.rbenv/versions/2.1.2/bin/rubocop:23:in `load'
/Users/me/.rbenv/versions/2.1.2/bin/rubocop:23:in `<main>'
"""
  # coffeelint: enable=max_line_length

  beforeEach ->

  describe 'name', ->
    it 'always returns "LinterError"', ->
      error = new LinterError
      expect(error.name).toBe('LinterError')

  describe 'stack', ->
    it 'returns stacktrace', ->
      error = new LinterError
      expect(error.stack).toContain(' at ')

  describe 'message', ->
    describe 'when a string message is passed to constructor', ->
      it 'returns the message', ->
        error = new LinterError('This is a message')
        expect(error.message).toBe('This is a message')

    describe 'when null is passed to constructor', ->
      it 'returns an empty string', ->
        error = new LinterError(null)
        expect(error.message).toBe('')

    describe 'when no message is passed to constructor', ->
      it 'returns an empty string', ->
        error = new LinterError
        expect(error.message).toBe('')

  describe '::toString', ->
    describe 'when the error has a message', ->
      it 'returns a string including the message', ->
        error = new LinterError('some message')
        expect(error.toString()).toMatch(/^LinterError: some message/)

    describe 'when the error has a command result', ->
      it 'returns a string including the command execution result', ->
        error = new LinterError(null, commandResult)
        # coffeelint: disable=max_line_length
        expect(error.toString()).toBe(
          """
          LinterError
              command: ["rubocop","--foo"]
              PATH: /Users/me/.rbenv/bin:/Users/me/.cabal/bin:/Users/me/bin:/Users/me/.dotfiles/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/Users/me/.rbenv/shims:/Users/me/.go/bin
              exit code: 123
              stdout:
                  foo
              stderr:
                  invalid option: --foo
                  /Users/me/.rbenv/versions/2.1.2/lib/ruby/gems/2.1.0/gems/rubocop-0.24.1/lib/rubocop/options.rb:82:in `parse'
                  /Users/me/.rbenv/versions/2.1.2/lib/ruby/gems/2.1.0/gems/rubocop-0.24.1/lib/rubocop/cli.rb:19:in `run'
                  /Users/me/.rbenv/versions/2.1.2/lib/ruby/gems/2.1.0/gems/rubocop-0.24.1/bin/rubocop:14:in `block in <top (required)>'
                  /Users/me/.rbenv/versions/2.1.2/lib/ruby/2.1.0/benchmark.rb:294:in `realtime'
                  /Users/me/.rbenv/versions/2.1.2/lib/ruby/gems/2.1.0/gems/rubocop-0.24.1/bin/rubocop:13:in `<top (required)>'
                  /Users/me/.rbenv/versions/2.1.2/bin/rubocop:23:in `load'
                  /Users/me/.rbenv/versions/2.1.2/bin/rubocop:23:in `<main>'
          """
        )
        # coffeelint: enable=max_line_length
