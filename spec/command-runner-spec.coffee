CommandRunner = require '../lib/command-runner'

describe 'CommandRunner', ->
  originalPath = process.env.PATH
  originalShell = process.env.SHELL

  afterEach ->
    process.env.PATH = originalPath
    process.env.SHELL = originalShell

  describe 'fetchPathEnvOfLoginShell', ->
    itPassesValidPath = ->
      it 'passes valid PATH', ->
        hasFetched = false

        CommandRunner.fetchPathEnvOfLoginShell (path, error) ->
          expect(path.constructor).toBe(String)
          expect(path).toMatch(/\/[^:]+(?::\/[^:]+)/)
          expect(error).toBeNull()
          hasFetched = true

        waitsFor ->
          hasFetched

    describe 'when the login shell is bash', ->
      beforeEach ->
        process.env.SHELL = '/bin/bash'

      itPassesValidPath()

    describe 'when the login shell is zsh', ->
      beforeEach ->
        process.env.SHELL = '/bin/zsh'

      itPassesValidPath()

    describe 'when the login shell is tcsh', ->
      beforeEach ->
        process.env.SHELL = '/bin/tcsh'

      it 'passes error', ->
        hasFetched = false

        CommandRunner.fetchPathEnvOfLoginShell (path, error) ->
          expect(error).toMatch(/tcsh.+not.+supported/)
          expect(path).toBeNull()
          hasFetched = true

        waitsFor ->
          hasFetched

    describe 'when SHELL enviroment variable is not set', ->
      beforeEach ->
        process.env.SHELL = ''

      it 'passes error', ->
        hasFetched = false

        CommandRunner.fetchPathEnvOfLoginShell (path, error) ->
          expect(error).toMatch(/SHELL.+not.+set/)
          expect(path).toBeNull()
          hasFetched = true

        waitsFor ->
          hasFetched

  describe 'getPathEnvOfLoginShell', ->
    beforeEach ->
      CommandRunner._cachedPathEnvOfLoginShell = undefined

    describe 'on first invocation', ->
      it 'invokes fetchPathEnvOfLoginShell and passes the result', ->
        spyOn(CommandRunner, 'fetchPathEnvOfLoginShell').andCallThrough()

        hasGotten = false

        CommandRunner.getPathEnvOfLoginShell (path) ->
          expect(path).toMatch(/\/[^:]+(?::\/[^:]+)/)
          expect(CommandRunner.fetchPathEnvOfLoginShell).toHaveBeenCalled()
          hasGotten = true

        waitsFor ->
          hasGotten

    describe 'on second invocation', ->
      itReturnsCachedResultOfFetchPathEnvOfLoginShell = ->
        it 'returns cached result of fetchPathEnvOfLoginShell', ->
          hasGotten = false

          CommandRunner.getPathEnvOfLoginShell (path) ->
            hasGotten = true

          waitsFor ->
            hasGotten

          runs ->
            hasGotten = false
            spyOn(CommandRunner, 'fetchPathEnvOfLoginShell').andCallThrough()

            CommandRunner.getPathEnvOfLoginShell (path) ->
              expect(CommandRunner.fetchPathEnvOfLoginShell).not.toHaveBeenCalled()
              hasGotten = true

          waitsFor ->
            hasGotten

      describe 'and the result of fetchPathEnvOfLoginShell is valid PATH', ->
        itReturnsCachedResultOfFetchPathEnvOfLoginShell()

      describe 'and the result of fetchPathEnvOfLoginShell is null', ->
        beforeEach ->
          process.env.SHELL = ''

        itReturnsCachedResultOfFetchPathEnvOfLoginShell()

  describe 'run', ->
    beforeEach ->
      CommandRunner._cachedPathEnvOfLoginShell = undefined

    run = (command, callback) ->
      hasRun = false

      runner = new CommandRunner(command)
      runner.run (result) ->
        callback(result)
        hasRun = true

      waitsFor ->
        hasRun

    it 'handles arguments include whitespaces', ->
      run ['echo', '-n', 'foo   bar'], (result) ->
        expect(result.stdout).toBe('foo   bar')

    describe 'when the command run successfully', ->
      it 'passes stdout', ->
        run ['echo', '-n', 'foo'], (result) ->
          expect(result.stdout).toBe('foo')

      it 'passes stderr', ->
        run ['ls', 'non-existent-file'], (result) ->
          expect(result.stderr).toMatch(/no such file/i)

      it 'passes exit code', ->
        run ['ls', '/'], (result) ->
          expect(result.exitCode).toBe(0)
        run ['ls', 'non-existent-file'], (result) ->
          expect(result.exitCode).toBe(1)

      it 'passes no error', ->
        run ['ls', '/'], (result) ->
          expect(result.error).toBeFalsy()

    describe 'when the command is not found', ->
      it 'invokes the callback only once', ->
        invocationCount = 0

        runner = new CommandRunner(['non-existent-command'])
        runner.run (result) ->
          invocationCount++

        waits(500)

        runs ->
          expect(invocationCount).toBe(1)

      it 'passes empty stdout', ->
        run ['non-existent-command'], (result) ->
          expect(result.stdout).toBe('')

      it 'passes empty stderr', ->
        run ['non-existent-command'], (result) ->
          expect(result.stderr).toBe('')

      it 'passes undefined exit code', ->
        run ['non-existent-command'], (result) ->
          expect(result.exitCode).toBeUndefined()

      it 'passes ENOENT error', ->
        run ['non-existent-command'], (result) ->
          expect(result.error.code).toBe('ENOENT')

    describe 'when the command is specified as an absolute path', ->
      it 'runs the command with the current PATH', ->
        run ['/usr/bin/perl', '-e', 'print $ENV{PATH}'], (result) ->
          expect(result.stdout).toBe(process.env.PATH)

    describe 'when the command is specified as a basename', ->
      describe 'and PATH of the login shell can be fetched', ->
        it 'runs the command with PATH of the login shell', ->
          process.env.PATH = '/usr/bin'
          run ['perl', '-e', 'print $ENV{PATH}'], (result) ->
            expect(result.stdout).not.toBe('/usr/bin')

        it 'does not modify PATH of the current process', ->
          process.env.PATH = '/usr/bin'
          run ['perl', '-e', 'print $ENV{PATH}'], (result) ->
            expect(process.env.PATH).toBe('/usr/bin')

      describe 'and PATH of the login shell cannot be fetched', ->
        it 'runs the command with the current PATH', ->
          process.env.SHELL = ''
          run ['perl', '-e', 'print $ENV{PATH}'], (result) ->
            expect(result.stdout).toBe(process.env.PATH)
