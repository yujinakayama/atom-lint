AtomLint = require '../lib/atom-lint'
require './spec-helper'

describe 'atom-lint', ->
  editorView = null

  beforeEach ->
    {editorView} = prepareWorkspace({ activatePackage: true })

  describe 'by default', ->
    it 'is enabled', ->
      expect(editorView.find('.lint').length).toBe(1)

  describe 'when enabled', ->
    describe 'and command "lint:toggle" is triggered', ->
      beforeEach ->
        atom.workspaceView.trigger('lint:toggle')

      it 'becomes disabled', ->
        expect(editorView.find('.lint').length).toBe(0)

  describe 'when disabled', ->
    describe 'and command "lint:toggle" is triggered', ->
      beforeEach ->
        atom.workspaceView.trigger('lint:toggle')
        atom.workspaceView.trigger('lint:toggle')

      it 'becomes enabled', ->
        expect(editorView.find('.lint').length).toBe(1)

  describe 'after deactivation and re-activation', ->
    beforeEach ->
      atom.packages.deactivatePackage('atom-lint')
      atom.packages.activatePackage('atom-lint')

    describe 'and command "lint:toggle" is triggered', ->
      beforeEach ->
        atom.workspaceView.trigger('lint:toggle')

      it 'becomes disabled', ->
        expect(editorView.find('.lint').length).toBe(0)

  describe '::shouldRefleshWithConfigChange', ->
    previous = null
    current = null

    describe 'when nothing is changed', ->
      beforeEach ->
        previous =
          ignoredNames: []
          showViolationMetadata: true
          rubocop:
            path: '/path/to/rubocop'

        current =
          ignoredNames: []
          showViolationMetadata: true
          rubocop:
            path: '/path/to/rubocop'

      it 'returns false', ->
        result = AtomLint.shouldRefleshWithConfigChange(previous, current)
        expect(result).toBe(false)

    describe 'when "ignoredNames" is changed', ->
      beforeEach ->
        previous =
          ignoredNames: []
          showViolationMetadata: true
          rubocop:
            path: '/path/to/rubocop'

        current =
          ignoredNames: ['foo']
          showViolationMetadata: true
          rubocop:
            path: '/path/to/rubocop'

      it 'returns true', ->
        result = AtomLint.shouldRefleshWithConfigChange(previous, current)
        expect(result).toBe(true)

    describe 'when "showViolationMetadata" is changed', ->
      beforeEach ->
        previous =
          ignoredNames: []
          showViolationMetadata: true
          rubocop:
            path: '/path/to/rubocop'

        current =
          ignoredNames: []
          showViolationMetadata: false
          rubocop:
            path: '/path/to/rubocop'

      it 'returns false', ->
        result = AtomLint.shouldRefleshWithConfigChange(previous, current)
        expect(result).toBe(false)

    describe 'when "ignoredNames" and "showViolationMetadata" are changed', ->
      beforeEach ->
        previous =
          ignoredNames: ['foo']
          showViolationMetadata: true
          rubocop:
            path: '/path/to/rubocop'

        current =
          ignoredNames: []
          showViolationMetadata: false
          rubocop:
            path: '/path/to/rubocop'

      it 'returns true', ->
        result = AtomLint.shouldRefleshWithConfigChange(previous, current)
        expect(result).toBe(true)
