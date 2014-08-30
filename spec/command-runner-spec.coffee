os = require 'os'
path = require 'path'
fs = require 'fs'
rimraf = require 'rimraf'
{$} = require 'atom'
CommandRunner = require '../lib/command-runner'

describe 'CommandRunner', ->
  workingDir = path.join(os.tmpdir(), 'atom-lint-spec')
  originalWorkingDirectory = process.cwd()
  originalEnv = null

  beforeEach ->
    originalEnv = $.extend(true, {}, process.env)
    atom.project.path = process.cwd()

  afterEach ->
    process.env = originalEnv
    process.chdir(originalWorkingDirectory)
    rimraf.sync(workingDir)

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
