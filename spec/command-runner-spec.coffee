os = require 'os'
path = require 'path'
fs = require 'fs'
rimraf = require 'rimraf'
CommandRunner = require '../lib/command-runner'
child_process = require 'child_process'

describe 'CommandRunner', ->
  workingDir = path.join(os.tmpdir(), 'atom-lint-spec')
  originalWorkingDirectory = process.cwd()
  originalHOME = process.env.HOME
  originalPATH = process.env.PATH
  originalSHELL = process.env.SHELL

  CommandRunner.supressError = true

  beforeEach ->
    rimraf.sync(workingDir) if fs.existsSync(workingDir)
    fs.mkdirSync(workingDir)
    process.env.HOME = workingDir
    process.chdir(workingDir)
    atom.project.path = workingDir

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

    describe 'when environment variables of the login shell can be fetched', ->
      it 'runs the command with the env', ->
        process.env.PATH = '/usr/bin'
        run ['perl', '-e', 'print $ENV{PATH}'], (error, result) ->
          expect(result.stdout).not.toBe('/usr/bin')

      it 'does not modify the env of the current process', ->
        process.env.PATH = '/usr/bin'
        run ['perl', '-e', 'print $ENV{PATH}'], (error, result) ->
          expect(process.env.PATH).toBe('/usr/bin')

    describe 'when environment variables of the login shell cannot be fetched', ->
      it 'runs the command with the current env', ->
        process.env.SHELL = ''
        run ['perl', '-e', 'print $ENV{PATH}'], (error, result) ->
          expect(result.stdout).toBe(process.env.PATH)

  describe 'runWithEnv', ->
    beforeEach ->
      @orginalProjectPath = atom.project.path
      @command = 'echo'
      @flags = ['-n', 'foo   bar']

      @child_process_obj =
        stderr:
          on: ->
        stdout:
          on: ->
        spawn: -> this
        on: ->

      @commandRunner = new CommandRunner(['echo', '-n', 'foo   bar'])
      @cb = ->
        works = true

    afterEach ->
      atom.project.path = @orginalProjectPath

    describe 'and echo is the command', ->
      describe 'and the project exists', ->
        it 'will add the CWD to the options', ->
          spyOn(child_process, 'spawn').andReturn(@child_process_obj)
          env = process.env
          options =
            env: env
            cwd: @orginalProjectPath

          @commandRunner.runWithEnv(env, @cb)
          expect(child_process.spawn)
            .toHaveBeenCalledWith(@command, @flags, options)

      describe 'and the project does not exists', ->
        beforeEach ->
          atom.project.path = null

        it 'won`t add the CWD to the options', ->
          spyOn(child_process, 'spawn').andReturn(@child_process_obj)
          env = process.env
          options =
            env: env
            cwd: null

          @commandRunner.runWithEnv(env, @cb)
          expect(child_process.spawn)
            .toHaveBeenCalledWith(@command, @flags, options)
