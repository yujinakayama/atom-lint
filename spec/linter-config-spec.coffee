LinterConfig = require '../lib/linter-config'
path = require 'path'
require './spec-helper'

describe 'LinterConfig', ->
  linterConfig = null
  originalAtomLintConfig = atom.config.get('atom-lint')

  beforeEach ->
    atom.config.set('atom-lint', null)
    linterConfig = new LinterConfig('some-linter')

  afterEach ->
    atom.config.set('atom-lint', originalAtomLintConfig)

  describe '::isFileToLint', ->
    describe 'when "atom-lint.some-linter.ignoredNames" is not set', ->
      it 'returns true for "foo.txt" in the current project', ->
        filePath = path.join(atom.project.getPath(), 'foo.txt')
        expect(linterConfig.isFileToLint(filePath)).toBe(true)

    describe 'when "atom-lint.some-linter.ignoredNames" is ["foo.txt"]', ->
      beforeEach ->
        atom.config.pushAtKeyPath('atom-lint.some-linter.ignoredNames', 'foo.txt')

      it 'returns false for "foo.txt" in the current project', ->
        filePath = path.join(atom.project.getPath(), 'foo.txt')
        expect(linterConfig.isFileToLint(filePath)).toBe(false)

      it 'returns true for "bar.txt" in the current project', ->
        filePath = path.join(atom.project.getPath(), 'bar.txt')
        expect(linterConfig.isFileToLint(filePath)).toBe(true)

    describe 'when "atom-lint.some-linter.ignoredNames" is ["*.txt"]', ->
      beforeEach ->
        atom.config.pushAtKeyPath('atom-lint.some-linter.ignoredNames', '*.txt')

      it 'returns false for "foo.txt" in the current project', ->
        filePath = path.join(atom.project.getPath(), 'foo.txt')
        expect(linterConfig.isFileToLint(filePath)).toBe(false)

      it 'returns true for "foo.rb" in the current project', ->
        filePath = path.join(atom.project.getPath(), 'foo.rb')
        expect(linterConfig.isFileToLint(filePath)).toBe(true)

    describe 'when "atom-lint.some-linter.ignoredNames" is ["*.txt", "foo.*"]', ->
      beforeEach ->
        atom.config.pushAtKeyPath('atom-lint.some-linter.ignoredNames', '*.txt')
        atom.config.pushAtKeyPath('atom-lint.some-linter.ignoredNames', 'foo.*')

      it 'returns false for "foo.txt" in the current project', ->
        filePath = path.join(atom.project.getPath(), 'foo.txt')
        expect(linterConfig.isFileToLint(filePath)).toBe(false)

      it 'returns false for "foo.rb" in the current project', ->
        filePath = path.join(atom.project.getPath(), 'foo.rb')
        expect(linterConfig.isFileToLint(filePath)).toBe(false)

      it 'returns true for "bar.rb" in the current project', ->
        filePath = path.join(atom.project.getPath(), 'bar.rb')
        expect(linterConfig.isFileToLint(filePath)).toBe(true)

    describe 'when "atom-lint.ignoredNames" is ["foo.txt"]', ->
      beforeEach ->
        atom.config.pushAtKeyPath('atom-lint.ignoredNames', 'foo.txt')

      it 'returns false for "foo.txt" in the current project', ->
        filePath = path.join(atom.project.getPath(), 'foo.txt')
        expect(linterConfig.isFileToLint(filePath)).toBe(false)

      it 'returns true for "bar.txt" in the current project', ->
        filePath = path.join(atom.project.getPath(), 'bar.txt')
        expect(linterConfig.isFileToLint(filePath)).toBe(true)
