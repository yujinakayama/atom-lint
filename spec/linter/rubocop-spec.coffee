Rubocop = require '../../lib/linter/rubocop'

describe 'Rubocop', ->
  rubocop = null

  beforeEach ->
    rubocop = new Rubocop('/path/to/target.rb')

  describe 'buildCommand', ->
    originalRubocopPath = atom.config.get('atom-lint.rubocop.path')

    afterEach ->
      atom.config.set('atom-lint.rubocop.path', originalRubocopPath)

    describe 'when the target file path is "/path/to/target.rb"', ->
      describe 'and config "atom-lint.rubocop.path" is "/path/to/rubocop"', ->
        it 'returns ["/path/to/rubocop", "--format", "json", "/path/to/target.rb"]', ->
          atom.config.set('atom-lint.rubocop.path', '/path/to/rubocop')
          expect(rubocop.buildCommand())
            .toEqual(['/path/to/rubocop', '--format', 'json', '/path/to/target.rb'])

      describe 'and config "atom-lint.rubocop.path" is not set', ->
        it 'returns ["rubocop", "--format", "json", "/path/to/target.rb"]', ->
          atom.config.set('atom-lint.rubocop.path', null)
          expect(rubocop.buildCommand())
            .toEqual(['rubocop', '--format', 'json', '/path/to/target.rb'])
