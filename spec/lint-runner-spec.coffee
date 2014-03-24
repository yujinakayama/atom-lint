LintRunner = require '../lib/lint-runner'
Rubocop = require '../lib/linter/rubocop'
Flake8 = require '../lib/linter/flake8'
path = require 'path'
require './spec-helper'

describe 'LintRunner', ->
  lintRunner = null
  editorView = null
  editor = null
  buffer = null

  filename = 'sample.txt'
  originalAtomLintConfig = atom.config.get('atom-lint')

  beforeEach ->
    atom.config.set('atom-lint', null)

    {editorView} = prepareWorkspace('filename': filename)
    editor = editorView.getEditor()
    buffer = editor.getBuffer()
    lintRunner = new LintRunner(editor)

  afterEach ->
    atom.config.set('atom-lint', originalAtomLintConfig)

  describe 'initially', ->
    it 'has no active linter', ->
      expect(lintRunner.getActiveLinter()).toBeFalsy()

  describe '::startWatching', ->
    describe "when the editor's grammar is Ruby", ->
      beforeEach ->
        editor.setGrammar(loadGrammar('ruby'))

      describe 'and the filename is not specified in config "atom-lint.rubocop.ignoredNames"', ->
        it 'activates RuboCop', ->
          lintRunner.startWatching()
          expect(lintRunner.getActiveLinter()).toBe(Rubocop)

        it 'emits "activate" event', ->
          waitsForEventToBeEmitted lintRunner, 'activate', ->
            lintRunner.startWatching()

        it 'emits "lint" event', ->
          waitsForEventToBeEmitted lintRunner, 'lint', ->
            lintRunner.startWatching()

      describe 'and the filename is specified in config "atom-lint.rubocop.ignoredNames"', ->
        beforeEach ->
          atom.config.pushAtKeyPath('atom-lint.rubocop.ignoredNames', filename)

        it 'does not activate any linter', ->
          lintRunner.startWatching()
          expect(lintRunner.getActiveLinter()).toBeFalsy()

        it 'does not emit "activate" event', ->
          expectEventNotToBeEmitted lintRunner, 'activate', ->
            lintRunner.startWatching()

        it 'does not emit "lint" event', ->
          expectEventNotToBeEmitted lintRunner, 'lint', ->
            lintRunner.startWatching()

    describe "when the editor's grammar is Python", ->
      beforeEach ->
        editor.setGrammar(loadGrammar('python'))

      it 'activates flake8', ->
        lintRunner.startWatching()
        expect(lintRunner.getActiveLinter()).toBe(Flake8)

      it 'emits "activate" event', ->
        waitsForEventToBeEmitted lintRunner, 'activate', ->
          lintRunner.startWatching()

      it 'emits "lint" event', ->
        waitsForEventToBeEmitted lintRunner, 'lint', ->
          lintRunner.startWatching()

    describe "when the editor's grammar is unknown", ->
      beforeEach ->
        editor.setGrammar(loadGrammar('yaml'))

      it 'does not activate any linter', ->
        lintRunner.startWatching()
        expect(lintRunner.getActiveLinter()).toBeFalsy()

      it 'does not emit "activate" event', ->
        expectEventNotToBeEmitted lintRunner, 'activate', ->
          lintRunner.startWatching()

      it 'does not emit "lint" event', ->
        expectEventNotToBeEmitted lintRunner, 'lint', ->
          lintRunner.startWatching()

    describe "when already watching and a linter is activated", ->
      beforeEach ->
        editor.setGrammar(loadGrammar('ruby'))
        waitsForEventToBeEmitted lintRunner, 'lint', ->
          lintRunner.startWatching()

      it 'does not change linter', ->
        lintRunner.startWatching()
        expect(lintRunner.getActiveLinter()).toBe(Rubocop)

      it 'does not emit "activate" event', ->
        expectEventNotToBeEmitted lintRunner, 'activate', ->
          lintRunner.startWatching()

      it 'does not emit "lint" event', ->
        expectEventNotToBeEmitted lintRunner, 'lint', ->
          lintRunner.startWatching()

  describe '::stopWatching', ->
    describe 'when any linter is already activated', ->
      beforeEach ->
        editor.setGrammar(loadGrammar('ruby'))
        lintRunner.startWatching()

      it 'deactivates the linter', ->
        lintRunner.stopWatching()
        expect(lintRunner.getActiveLinter()).toBeFalsy()

      it 'emits "deactivate" event', ->
        waitsForEventToBeEmitted lintRunner, 'deactivate', ->
          lintRunner.stopWatching()

    describe 'when no linter is activated', ->
      beforeEach ->
        lintRunner.startWatching()

      it 'does nothing with linter', ->
        lintRunner.stopWatching()
        expect(lintRunner.getActiveLinter()).toBeFalsy()

      it 'does not emit "deactivate" event', ->
        expectEventNotToBeEmitted lintRunner, 'deactivate', ->
          lintRunner.stopWatching()

  describe '::refresh', ->
    describe 'when RuboCop is already activated', ->
      beforeEach ->
        editor.setGrammar(loadGrammar('ruby'))
        waitsForEventToBeEmitted lintRunner, 'lint', ->
          lintRunner.startWatching()

      describe 'then the filename is added to config "atom-lint.rubocop.ignoredNames"', ->
        beforeEach ->
          atom.config.pushAtKeyPath('atom-lint.rubocop.ignoredNames', filename)

        it 'deactivates RuboCop', ->
          lintRunner.refresh()
          expect(lintRunner.getActiveLinter()).toBeFalsy()

      describe 'and config is not changed', ->
        it 'does nothing with linter', ->
          lintRunner.refresh()
          expect(lintRunner.getActiveLinter()).toBe(Rubocop)

    describe 'when not watching', ->
      beforeEach ->
        editor.setGrammar(loadGrammar('ruby'))

      it 'does nothing with linter', ->
        lintRunner.refresh()
        expect(lintRunner.getActiveLinter()).toBeFalsy()

  describe 'when watching and RuboCop is already activated', ->
    beforeEach ->
      editor.setGrammar(loadGrammar('ruby'))
      waitsForEventToBeEmitted lintRunner, 'lint', ->
        lintRunner.startWatching()

    describe 'and a file is saved', ->
      it 'emits "lint" event', ->
        waitsForEventToBeEmitted lintRunner, 'lint', ->
          buffer.emit('saved')

    describe 'and a file is reloaded', ->
      it 'emits "lint" event', ->
        waitsForEventToBeEmitted lintRunner, 'lint', ->
          buffer.emit('reloaded')

    describe "and the editor's grammar is changed to Python", ->
      it 'activates flake8', ->
        editor.setGrammar(loadGrammar('python'))
        expect(lintRunner.getActiveLinter()).toBe(Flake8)

      it 'does not emit "activate" event', ->
        expectEventNotToBeEmitted lintRunner, 'activate', ->
          editor.setGrammar(loadGrammar('python'))

      it 'does not emit "deactivate" event', ->
        expectEventNotToBeEmitted lintRunner, 'deactivate', ->
          editor.setGrammar(loadGrammar('python'))

      it 'emits "lint" event', ->
        waitsForEventToBeEmitted lintRunner, 'lint', ->
          editor.setGrammar(loadGrammar('python'))

      describe 'and a file is saved', ->
        beforeEach ->
          waitsForEventToBeEmitted lintRunner, 'lint', ->
            editor.setGrammar(loadGrammar('python'))

        it 'emits "lint" event only once', ->
          emitCount = 0

          lintRunner.on 'lint', ->
            emitCount++

          buffer.emit('saved')

          waits(500)

          runs ->
            expect(emitCount).toBe(1)

  describe 'when watching and no linter is activated', ->
    beforeEach ->
      lintRunner.startWatching()

    describe 'and a file is saved', ->
      it 'does not emit "lint" event', ->
        expectEventNotToBeEmitted lintRunner, 'lint', ->
          buffer.emit('saved')

    describe "and the editor's grammar is changed to Python", ->
      it 'activates flake8', ->
        editor.setGrammar(loadGrammar('python'))
        expect(lintRunner.getActiveLinter()).toBe(Flake8)

      it 'emits "activate" event', ->
        waitsForEventToBeEmitted lintRunner, 'activate', ->
          editor.setGrammar(loadGrammar('python'))

      it 'does not emit "deactivate" event', ->
        expectEventNotToBeEmitted lintRunner, 'deactivate', ->
          editor.setGrammar(loadGrammar('python'))

      it 'emits "lint" event', ->
        waitsForEventToBeEmitted lintRunner, 'lint', ->
          editor.setGrammar(loadGrammar('python'))

  describe 'when not watching', ->
    describe 'and a file is saved', ->
      it 'does not emit "lint" event', ->
        expectEventNotToBeEmitted lintRunner, 'lint', ->
          buffer.emit('saved')

    describe "and the editor's grammar is changed to Python", ->
      it 'does not emits "lint" event', ->
        expectEventNotToBeEmitted lintRunner, 'lint', ->
          editor.setGrammar(loadGrammar('python'))

      it 'does not emit "activate" event', ->
        expectEventNotToBeEmitted lintRunner, 'activate', ->
          editor.setGrammar(loadGrammar('python'))

      it 'does not emit "deactivate" event', ->
        expectEventNotToBeEmitted lintRunner, 'deactivate', ->
          editor.setGrammar(loadGrammar('python'))
