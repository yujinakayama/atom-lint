JsHint = require '../../lib/linter/jshint'

describe 'JsHint', ->
  jsHint = null

  beforeEach ->
    jsHint = new JsHint('/path/to/target.js')

  describe 'constructCommand', ->
    originalJSHintPath = atom.config.get('atom-lint.jshint.path')

    afterEach ->
      atom.config.set('atom-lint.jshint.path', originalJSHintPath)

    describe 'when the target file path is "/path/to/target.js"', ->
      describe 'and config "atom-lint.jshint.path" is "/path/to/jshint"', ->
        it 'returns ["/path/to/jshint", "/path/to/target.js"]', ->
          atom.config.set('atom-lint.jshint.path', '/path/to/jshint')
          expect(jsHint.constructCommand())
            .toEqual(['/path/to/jshint', '--reporter=checkstyle', '/path/to/target.js'])

      describe 'and config "atom-lint.flake8.path" is not set', ->
        it 'returns ["jshint", "/path/to/target.js"]', ->
          atom.config.set('atom-lint.jshint.path', null)
          expect(jsHint.constructCommand())
            .toEqual(['jshint', '--reporter=checkstyle', '/path/to/target.js'])
