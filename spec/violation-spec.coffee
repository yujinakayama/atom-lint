{Range, Point} = require 'atom'
Violation = require '../lib/violation'

describe 'Violation', ->
  describe 'constructor', ->
    bufferRange = null

    beforeEach ->
      bufferPoint = new Point(1, 2)
      bufferRange = new Range(bufferPoint, bufferPoint)

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
