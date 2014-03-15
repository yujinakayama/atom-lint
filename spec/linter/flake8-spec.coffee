Flake8 = require '../../lib/linter/flake8'

describe 'Flake8', ->
  flake8 = null

  beforeEach ->
    flake8 = new Flake8('/path/to/target.py')

  describe 'buildCommand', ->
    originalFlake8Path = atom.config.get('atom-lint.flake8.path')

    afterEach ->
      atom.config.set('atom-lint.flake8.path', originalFlake8Path)

    describe 'when the target file path is "/path/to/target.py"', ->
      describe 'and config "atom-lint.flake8.path" is "/path/to/flake8"', ->
        it 'returns ["/path/to/flake8", "/path/to/target.py"]', ->
          atom.config.set('atom-lint.flake8.path', '/path/to/flake8')
          expect(flake8.buildCommand())
            .toEqual(['/path/to/flake8', '/path/to/target.py'])

      describe 'and config "atom-lint.flake8.path" is not set', ->
        it 'returns ["flake8", "/path/to/target.py"]', ->
          atom.config.set('atom-lint.flake8.path', null)
          expect(flake8.buildCommand())
            .toEqual(['flake8', '/path/to/target.py'])
