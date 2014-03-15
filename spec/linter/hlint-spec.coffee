HLint = require '../../lib/linter/hlint'

describe 'HLint', ->
  hlint = null

  beforeEach ->
    hlint = new HLint('/path/to/target.hs')

  describe 'buildCommand', ->
    originalHLintPath = atom.config.get('atom-lint.hlint.path')

    afterEach ->
      atom.config.set('atom-lint.hlint.path', originalHLintPath)

    describe 'when the target file path is "/path/to/target.hs"', ->
      describe 'and config "atom-lint.hlint.path" is "/path/to/hlint"', ->
        it 'returns ["/path/to/hlint", "/path/to/target.hs"]', ->
          atom.config.set('atom-lint.hlint.path', '/path/to/hlint')
          expect(hlint.buildCommand())
            .toEqual(['/path/to/hlint', '/path/to/target.hs'])

      describe 'and config "atom-lint.hlint.path" is not set', ->
        it 'returns ["hlint", "/path/to/target.hs"]', ->
          atom.config.set('atom-lint.hlint.path', null)
          expect(hlint.buildCommand())
            .toEqual(['hlint', '/path/to/target.hs'])