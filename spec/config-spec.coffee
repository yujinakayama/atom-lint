Config = require '../lib/config'
path = require 'path'
require './spec-helper'

describe 'Config', ->
  linterConfig = null
  originalAtomLintConfig = atom.config.get('atom-lint')

  beforeEach ->
    atom.config.set('atom-lint', null)
    linterConfig = new Config('some-linter')

  afterEach ->
    atom.config.set('atom-lint', originalAtomLintConfig)

  describe '.onDidChange', ->
    it 'returns an subscription object', ->
      subscription = Config.onDidChange 'foo', ->
      expect(subscription.off).not.toBeNull()
      subscription.off()

    it 'invokes the callback when the key path under `atom-lint` key is modified', ->
      invoked = false

      subscription = Config.onDidChange 'foo', ->
        invoked = true
        subscription.off()

      atom.config.set('atom-lint.foo', 'bar')

      waitsFor ->
        invoked

    describe 'when no key path is passed', ->
      it 'invokes the callback when any key under `atom-lint` namespace is modified', ->
        invoked = false

        subscription = Config.onDidChange ->
          invoked = true
          subscription.off()

        atom.config.set('atom-lint.foo', 'bar')

        waitsFor ->
          invoked

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
