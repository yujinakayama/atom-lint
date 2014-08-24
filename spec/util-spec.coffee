util = require '../lib/util'
require './spec-helper'

describe 'util', ->
  describe '.punctuate', ->
    for eachPunctuation in ['.', ',', '!', '?', ':', ';']
      describe "when the text ends with a #{eachPunctuation}", ->
        punctuation = eachPunctuation

        it 'does nothing', ->
          text = "Hi#{punctuation}"
          expect(util.punctuate(text)).toBe(text)

    describe 'when the text does not end with a punctuation', ->
      it 'adds a period to the end', ->
        expect(util.punctuate('Hi')).toBe('Hi.')
