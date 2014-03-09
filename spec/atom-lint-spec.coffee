{WorkspaceView} = require 'atom'
path = require 'path'
fs = require 'fs'
temp = require 'temp'

describe 'atom-lint', ->
  editorView = null

  sampleFilename = 'sample.rb'

  beforeEach ->
    projectPath = temp.mkdirSync('atom-lint-spec-')
    atom.project.setPath(projectPath)

    sampleFilePath = path.join(projectPath, sampleFilename)
    fs.writeFileSync(sampleFilePath, 'foo = 1')

    atom.workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()
    atom.workspaceView.openSync(sampleFilename)
    editorView = atom.workspaceView.getActiveView()

    waitsForPromise ->
      atom.packages.activatePackage('atom-lint')

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
