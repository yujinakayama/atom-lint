Rubocop = require '../../lib/linter/rubocop'

describe 'Rubocop', ->
  rubocop = null
  defaultOptions = ['rubocop', '--format', 'json', '--display-cop-names', '/path/to/target.rb']

  beforeEach ->
    rubocop = new Rubocop('/path/to/target.rb')

  describe 'buildCommand', ->
    describe 'when the target file path is "/path/to/target.rb"', ->
      describe 'path', ->
        originalRubocopPath = atom.config.get('atom-lint.rubocop.path')

        afterEach ->
          atom.config.set('atom-lint.rubocop.path', originalRubocopPath)

        describe 'and config "atom-lint.rubocop.path" is "/path/to/rubocop"', ->
          it 'returns ["/path/to/rubocop", "--format", "json", "--display-cop-names",
          "/path/to/target.rb"]', ->
            atom.config.set('atom-lint.rubocop.path', '/path/to/rubocop')
            expect(rubocop.buildCommand())
              .toEqual(['/path/to/rubocop', '--format', 'json', '--display-cop-names',
              '/path/to/target.rb'])

        describe 'and config "atom-lint.rubocop.path" is not set', ->
          it 'returns ["rubocop", "--format", "json", "--display-cop-names",
          "/path/to/target.rb"]', ->
            atom.config.set('atom-lint.rubocop.path', null)
            expect(rubocop.buildCommand()).toEqual(defaultOptions)

      describe 'showDisplayCopNames', ->
        originaShowDisplayCopNames = atom.config.get('atom-lint.rubocop.showDisplayCopNames')

        afterEach ->
          atom.config.set('atom-lint.rubocop.path', originaShowDisplayCopNames)

        describe 'and config "atom-lint.rubocop.showDisplayCopNames" is true', ->
          it 'returns ["rubocop", "--format", "json", "--display-cop-names",
          "/path/to/target.rb"]', ->
            atom.config.set('atom-lint.rubocop.showDisplayCopNames', true)
            expect(rubocop.buildCommand()).toEqual(defaultOptions)

        describe 'and config "atom-lint.rubocop.showDisplayCopNames" is false', ->
          it 'returns ["rubocop", "--format", "json", "/path/to/target.rb"]', ->
            atom.config.set('atom-lint.rubocop.showDisplayCopNames', false)
            expect(rubocop.buildCommand())
              .toEqual(['rubocop', '--format', 'json', '/path/to/target.rb'])

        describe 'and config "atom-lint.rubocop.showDisplayCopNames" is not set', ->
          it 'returns ["rubocop", "--format", "json", "--display-cop-names",
          "/path/to/target.rb"]', ->
            atom.config.set('atom-lint.rubocop.showDisplayCopNames', null)
            expect(rubocop.buildCommand()).toEqual(defaultOptions)
