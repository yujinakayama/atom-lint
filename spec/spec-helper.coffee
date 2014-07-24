{WorkspaceView} = require 'atom'
path = require 'path'
fs = require 'fs'
temp = require 'temp'
_ = require 'lodash'

window.prepareWorkspace = (options = {}) ->
  projectPath = temp.mkdirSync('lint-runner-spec-')
  atom.project.setPath(projectPath)

  filename = options.filename || 'sample.txt'
  filePath = path.join(projectPath, filename)
  fs.writeFileSync(filePath, 'This is a sample file.')

  atom.workspaceView = new WorkspaceView
  atom.workspaceView.attachToDom()
  atom.workspaceView.openSync(filename)

  if options.activatePackage
    waitsForPromise ->
      atom.packages.activatePackage('atom-lint')

  editorView: atom.workspaceView.getActiveView()

window.waitsForEventToBeEmitted = (targetObject, eventName, context) ->
  emitted = false

  targetObject.on eventName, ->
    emitted = true

  context()

  waitsFor ->
    emitted

window.expectEventNotToBeEmitted = (targetObject, eventName, context) ->
  emitted = false

  targetObject.on eventName, ->
    emitted = true

  context()

  waits(100)

  runs ->
    expect(emitted).toBe(false)

window.loadGrammar = (languageName) ->
  packageName = "language-#{languageName}"
  atom.packages.loadPackage(packageName)
  aPackage = atom.packages.getLoadedPackage(packageName)

  return null unless aPackage

  aPackage.loadGrammarsSync()

  scopeName = "source.#{languageName}"

  _.find aPackage.grammars, (grammar) ->
    grammar.scopeName == scopeName
