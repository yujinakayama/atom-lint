os = require 'os'
path = require 'path'
fs = require 'fs'
rimraf = require 'rimraf'
CommandRunner = require '../lib/command-runner'

describe 'CommandRunner', ->
  workingDir = path.join(os.tmpdir(), 'atom-lint-spec')
  originalWorkingDirectory = process.cwd()
  originalHOME = process.env.HOME
  originalPATH = process.env.PATH
  originalSHELL = process.env.SHELL

  CommandRunner.supressError = true

  beforeEach ->
    atom.project.path = process.cwd()

  afterEach ->
    process.chdir(originalWorkingDirectory)
    process.env.HOME = originalHOME
    process.env.PATH = originalPATH
    process.env.SHELL = originalSHELL
    rimraf.sync(workingDir)

  describe '.fetchEnvOfLoginShell', ->
    itPassesAnObjectContainingAllEnvironementVariables = ->
      it 'passes an object containing all environement variables', ->
        hasFetched = false

        CommandRunner.fetchEnvOfLoginShell (error, env) ->
          expect(error).toBeFalsy()
          expect(env.PATH.constructor).toBe(String)
          expect(env.PATH).toMatch(/\/[^:]+(?::\/[^:]+)/)
          expect(env.HOME).toBe(process.env.HOME)
          hasFetched = true

        waitsFor ->
          hasFetched

    describe 'when the login shell is bash', ->
      beforeEach ->
        process.env.SHELL = '/bin/bash'

      itPassesAnObjectContainingAllEnvironementVariables()

    describe 'when the login shell is zsh', ->
      beforeEach ->
        process.env.SHELL = '/bin/zsh'

      itPassesAnObjectContainingAllEnvironementVariables()

      describe 'and CLOBBER option is unset', ->
        beforeEach ->
          fs.writeFileSync('.zshrc', 'unsetopt CLOBBER')

        itPassesAnObjectContainingAllEnvironementVariables()

    describe 'when the login shell is tcsh', ->
      beforeEach ->
        process.env.SHELL = '/bin/tcsh'

      it 'passes error', ->
        hasFetched = false

        CommandRunner.fetchEnvOfLoginShell (error, env) ->
          expect(error.message).toMatch(/tcsh.+not.+supported/)
          expect(env).toBeFalsy()
          hasFetched = true

        waitsFor ->
          hasFetched

    describe 'when SHELL enviroment variable is not set', ->
      beforeEach ->
        process.env.SHELL = ''

      it 'passes error', ->
        hasFetched = false

        CommandRunner.fetchEnvOfLoginShell (error, env) ->
          expect(error.message).toMatch(/SHELL.+not.+set/)
          expect(env).toBeFalsy()
          hasFetched = true

        waitsFor ->
          hasFetched

  describe '.mergePaths', ->
    describe 'with "/foo:/bar" and "/baz:/qux"', ->
      it 'returns "/foo:/bar:/baz:/qux"', ->
        path = CommandRunner.mergePaths('/foo:/bar', '/baz:/qux')
        expect(path).toBe('/foo:/bar:/baz:/qux')

    describe 'with "/foo:/bar" and "/foo:/baz"', ->
      it 'returns "/foo:/bar:/baz"', ->
        path = CommandRunner.mergePaths('/foo:/bar', '/foo:/baz')
        expect(path).toBe('/foo:/bar:/baz')

    describe 'with "/foo:/bar" and "/bar:/baz"', ->
      it 'returns "/foo:/bar:/baz"', ->
        path = CommandRunner.mergePaths('/foo:/bar', '/bar:/baz')
        expect(path).toBe('/foo:/bar:/baz')

    describe 'with "/foo:/bar" and ""', ->
      it 'returns "/foo:/bar"', ->
        path = CommandRunner.mergePaths('/foo:/bar', '')
        expect(path).toBe('/foo:/bar')

    describe 'with "" and "/foo:/bar"', ->
      it 'returns "/foo:/bar"', ->
        path = CommandRunner.mergePaths('', '/foo:/bar')
        expect(path).toBe('/foo:/bar')

  describe 'getEnv', ->
    beforeEach ->
      CommandRunner.cachedEnv = undefined

    describe 'on first invocation', ->
      it 'invokes .fetchEnvOfLoginShell, merges PATHs of login shell and Atom,
          then passes the env', ->
        spyOn(CommandRunner, 'fetchEnvOfLoginShell').andCallThrough()

        hasGotten = false

        process.env.PATH = '/some/unique/path'

        CommandRunner.getEnv (env) ->
          expect(env.PATH).toMatch(/\/[^:]+(?::\/[^:]+):\/some\/unique\/path/)
          expect(CommandRunner.fetchEnvOfLoginShell).toHaveBeenCalled()
          hasGotten = true

        waitsFor ->
          hasGotten

    describe 'on second invocation', ->
      itReturnsCachedResultOfFetchEnvOfLoginShell = ->
        it 'returns cached env', ->
          hasGotten = false

          CommandRunner.getEnv (env) ->
            hasGotten = true

          waitsFor ->
            hasGotten

          runs ->
            hasGotten = false
            spyOn(CommandRunner, 'fetchEnvOfLoginShell').andCallThrough()

            CommandRunner.getEnv (env) ->
              expect(CommandRunner.fetchEnvOfLoginShell).not.toHaveBeenCalled()
              hasGotten = true

          waitsFor ->
            hasGotten

      describe 'and the result of .fetchEnvOfLoginShell is valid', ->
        itReturnsCachedResultOfFetchEnvOfLoginShell()

      describe 'and the result of fetchEnvOfLoginShell is null', ->
        beforeEach ->
          process.env.SHELL = ''

        itReturnsCachedResultOfFetchEnvOfLoginShell()

        it 'returns the env of Atom alternatively', ->
          hasGotten = false

          CommandRunner.getEnv (env) ->
            expect(env.HOME).toBe(process.env.HOME)
            hasGotten = true

          waitsFor ->
            hasGotten

  describe 'run', ->
    beforeEach ->
      CommandRunner.cachedEnv = undefined

    run = (command, callback) ->
      hasRun = false

      runner = new CommandRunner(command)
      runner.run (error, result) ->
        callback(error, result)
        hasRun = true

      waitsFor ->
        hasRun

    it 'handles arguments include whitespaces', ->
      run ['echo', '-n', 'foo   bar'], (error, result) ->
        expect(result.stdout).toBe('foo   bar')

    it 'passes the executed command', ->
      run ['echo', '-n', 'foo'], (error, result) ->
        expect(result.command).toEqual(['echo', '-n', 'foo'])

    it 'passes the environment variables', ->
      run ['echo', '-n', 'foo'], (error, result) ->
        expect(result.env.PATH).toContain('/bin')

    describe 'when atom.project.path is set', ->
      beforeEach ->
        rimraf.sync(workingDir) if fs.existsSync(workingDir)
        fs.mkdirSync(workingDir)
        atom.project.path = workingDir

      it 'runs the command there', ->
        run ['pwd'], (error, result) ->
          expect(result.stdout.trim()).toBe(fs.realpathSync(atom.project.path))

    describe 'when atom.project.path is not set', ->
      beforeEach ->
        atom.project.path = null

      it 'runs the command in the current working directory', ->
        run ['pwd'], (error, result) ->
          expect(result.stdout.trim()).toBe(process.cwd())

    describe 'when the command run successfully', ->
      it 'passes stdout', ->
        run ['echo', '-n', 'foo'], (error, result) ->
          expect(result.stdout).toBe('foo')

      it 'passes stderr', ->
        run ['ls', 'non-existent-file'], (error, result) ->
          expect(result.stderr).toMatch(/no such file/i)

      it 'passes exit code', ->
        run ['ls', '/'], (error, result) ->
          expect(result.exitCode).toBe(0)
        run ['ls', 'non-existent-file'], (error, result) ->
          expect(result.exitCode).toBe(1)

      it 'passes no error', ->
        run ['ls', '/'], (error, result) ->
          expect(result.error).toBeFalsy()

    describe 'when the command is not found', ->
      it 'invokes the callback only once', ->
        invocationCount = 0

        runner = new CommandRunner(['non-existent-command'])
        runner.run (error, result) ->
          invocationCount++

        waits(500)

        runs ->
          expect(invocationCount).toBe(1)

      it 'passes empty stdout', ->
        run ['non-existent-command'], (error, result) ->
          expect(result.stdout).toBe('')

      it 'passes empty stderr', ->
        run ['non-existent-command'], (error, result) ->
          expect(result.stderr).toBe('')

      it 'passes undefined exit code', ->
        run ['non-existent-command'], (error, result) ->
          expect(result.exitCode).toBeUndefined()

      it 'passes ENOENT error', ->
        run ['non-existent-command'], (error, result) ->
          expect(error.code).toBe('ENOENT')
