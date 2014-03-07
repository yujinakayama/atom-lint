Rubocop = require '../../lib/linter/rubocop'

describe 'Rubocop', ->
  rubocop = null

  beforeEach ->
    rubocop = new Rubocop('/path/to/target.rb')

  describe 'constructCommand', ->
    describe 'when the target file path is "/path/to/target.rb"', ->
      it 'returns ["rubocop", "--format", "json", "/path/to/target.rb"]', ->
        expect(rubocop.constructCommand()).toEqual(['rubocop', '--format', 'json', '/path/to/target.rb'])
