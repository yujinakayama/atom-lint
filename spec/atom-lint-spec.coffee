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
