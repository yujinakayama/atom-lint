{Range, Point} = require 'atom'
Violation = require '../lib/violation'

describe 'Violation', ->
  bufferRange = null

  beforeEach ->
    bufferPoint = new Point(1, 2)
    bufferRange = new Range(bufferPoint, bufferPoint)

  describe 'constructor', ->
    it 'sets properties', ->
      violation = new Violation('warning', bufferRange, 'This is a message')
      expect(violation.severity).toBe('warning')
      expect(violation.bufferRange).toBe(bufferRange)
      expect(violation.message).toBe('This is a message')

    describe 'when unknown severity is passed', ->
      it 'throws exception', ->
        expect ->
          new Violation('foo', bufferRange, 'This is a message')
        .toThrow()

  describe '::getMessageHTML', ->
    it 'escapes HTML entities in the message', ->
      violation = new Violation('warning', bufferRange, 'Do not use <font> tag.')
      expect(violation.getMessageHTML()).toBe('Do not use &lt;font&gt; tag.')

    it 'marks up backquotes with <code> tag', ->
      message = 'Favor `unless` over `if` for negative conditions.'
      violation = new Violation('warning', bufferRange, message)
      expect(violation.getMessageHTML())
        .toBe('Favor <code>unless</code> over <code>if</code> for negative conditions.')

    it 'marks up single quotes with <code> tag', ->
      message = "Background image 'bg_fallback.png' was used multiple times, " +
                'first declared at line 42, col 2.'
      violation = new Violation('warning', bufferRange, message)
      expect(violation.getMessageHTML())
        .toBe("Background image <code>bg_fallback.png</code> was used multiple times, " +
              'first declared at line 42, col 2.')

    it 'does not confuse single quotes used as apostrophe with quotation', ->
      message = "I don't and won't do this."
      violation = new Violation('warning', bufferRange, message)
      expect(violation.getMessageHTML())
        .toBe("I don&#39;t and won&#39;t do this.")

    it 'handles single quotes from the beginning to the end of the message', ->
      message = "'this_is_a_snippet'"
      violation = new Violation('warning', bufferRange, message)
      expect(violation.getMessageHTML())
        .toBe('<code>this_is_a_snippet</code>.')

    it 'handles backquotes next to non-whitespaces', ->
      message = 'Another good alternative is the usage of control flow `&&`/`||`.'
      violation = new Violation('warning', bufferRange, message)
      expect(violation.getMessageHTML())
        .toBe('Another good alternative is ' +
              'the usage of control flow <code>&amp;&amp;</code>/<code>||</code>.')

  describe '::getAttachmentHTML', ->
    it 'returns null by default', ->
      violation = new Violation('warning', bufferRange, 'This is a message.')
      expect(violation.getAttachmentHTML()).toBeNull()

  describe '::getMetadataHTML', ->
    it 'returns span elements for each metadata item', ->
      metadata = ['foo', 'bar']
      violation = new Violation('warning', bufferRange, 'This is a message.', metadata)
      expect(violation.getMetadataHTML())
        .toBe('<span class="item">foo</span><span class="item">bar</span>')

    it 'escapes HTML entities in the metadata', ->
      metadata = ['<foo>']
      violation = new Violation('warning', bufferRange, 'This is a message.', metadata)
      expect(violation.getMetadataHTML())
        .toBe('<span class="item">&lt;foo&gt;</span>')
