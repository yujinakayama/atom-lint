SCSSLint = require '../../lib/linter/scss-lint'

describe 'SCSSLint', ->
  scssLint = null

  beforeEach ->
    scssLint = new SCSSLint('/path/to/target.scss')

  describe 'isValidExitCode', ->
    describe 'with 0', ->
      it 'returns true', ->
        expect(scssLint.isValidExitCode(0)).toBeTruthy()

    describe 'with 1', ->
      it 'returns true', ->
        expect(scssLint.isValidExitCode(1)).toBeTruthy()

    describe 'with 2', ->
      it 'returns true', ->
        expect(scssLint.isValidExitCode(2)).toBeTruthy()

    describe 'with 65', ->
      it 'returns true for older SCSSLint versions', ->
        expect(scssLint.isValidExitCode(65)).toBeTruthy()

    describe 'with any other value', ->
      it 'returns false', ->
        expect(scssLint.isValidExitCode(-1)).toBeFalsy()
        expect(scssLint.isValidExitCode(3)).toBeFalsy()
        expect(scssLint.isValidExitCode(66)).toBeFalsy()
