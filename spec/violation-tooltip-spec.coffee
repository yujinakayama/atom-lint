{Range, Point} = require 'atom'
ViolationTooltip = require '../lib/violation-tooltip'
Violation = require '../lib/violation'

describe 'ViolationTooltip', ->
  tooltip = null

  bufferPoint = new Point(1, 2)
  bufferRange = new Range(bufferPoint, bufferPoint)
  violation = new Violation('warning', bufferRange, 'This is a message')

  originalAtomLintConfig = atom.config.get('atom-lint')

  beforeEach ->
    atom.config.set('atom-lint', null)

    {editorView} = prepareWorkspace()
    # editorView.append('<div id="target"></div>')

    options =
      violation: violation
      container: editorView
      editorView: editorView

    tooltip = new ViolationTooltip(editorView, options)

  afterEach ->
    tooltip?.destroy()
    atom.config.set('atom-lint', originalAtomLintConfig)

  describe '::show', ->
    describe 'when config "atom-lint.showViolationMetadata" is true', ->
      beforeEach ->
        atom.config.set('atom-lint.showViolationMetadata', true)

      it 'shows metadata of the violation', ->
        tooltip.show()
        $metadata = tooltip.content().find('.metadata')
        expect($metadata.css('display')).not.toBe('none')

    describe 'when config "atom-lint.showViolationMetadata" is false', ->
      beforeEach ->
        atom.config.set('atom-lint.showViolationMetadata', false)

      it 'hides metadata of the violation', ->
        tooltip.show()
        $metadata = tooltip.content().find('.metadata')
        expect($metadata.css('display')).toBe('none')

  describe 'when the tooltip is shown', ->
    describe 'and config "atom-lint.showViolationMetadata" is changed from true to false', ->
      beforeEach ->
        atom.config.set('atom-lint.showViolationMetadata', true)
        tooltip.show()
        atom.config.set('atom-lint.showViolationMetadata', false)

      it 'hides metadata of the violation', ->
        $metadata = tooltip.content().find('.metadata')
        expect($metadata.css('display')).toBe('none')

    describe 'and config "atom-lint.showViolationMetadata" is changed from false to true', ->
      beforeEach ->
        atom.config.set('atom-lint.showViolationMetadata', false)
        tooltip.show()
        atom.config.set('atom-lint.showViolationMetadata', true)

      it 'shows metadata of the violation', ->
        $metadata = tooltip.content().find('.metadata')
        expect($metadata.css('display')).not.toBe('none')
