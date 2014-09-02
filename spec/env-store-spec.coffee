EnvStore = require '../lib/env-store'
{$} = require 'atom'
require './spec-helper'

describe 'EnvStore', ->
  originalEnv = null

  beforeEach ->
    originalEnv = $.extend(true, {}, process.env)
    EnvStore.clear()

  afterEach ->
    process.env = originalEnv

  describe '.get', ->
    describe 'when no env is cached on disk', ->
      it 'always returns the current env', ->
        expect(EnvStore.get().PATH).toBe(process.env.PATH)
        expect(EnvStore.get().PATH).toBe(process.env.PATH)

      describe 'and the current env is empty', ->
        beforeEach ->
          process.env = {}

        it 'does not raise error', ->
          expect ->
            EnvStore.get()
          .not.toThrow()

    describe 'when an env is cached on disk and new Atom instance is launched', ->
      cache = ->
        EnvStore.get()
        # Emulate a new Atom instance
        EnvStore.clearEphemeralCache()

      describe 'and the current env has SHLVL', ->
        describe 'and the cached env also has SHLVL', ->
          beforeEach ->
            process.env.SHLVL = '2'
            process.env.THIS_IS_CACHED = 'true'
            cache()
            process.env.SHLVL = '2'

          describe 'and even the cached env has more keys than the current one', ->
            beforeEach ->
              delete(process.env.THIS_IS_CACHED)

            it 'always returns the current env', ->
              expect(EnvStore.get().THIS_IS_CACHED).toBeUndefined()

        describe 'and the cached env does not have SHLVL', ->
          beforeEach ->
            delete(process.env.SHLVL)
            process.env.THIS_IS_CACHED = 'true'
            cache()
            process.env.SHLVL = '2'
            delete(process.env.THIS_IS_CACHED)

          it 'returns the current env', ->
            expect(EnvStore.get().THIS_IS_CACHED).toBeUndefined()

      describe 'and the current env does not have SHLVL', ->
        describe 'and the cached env has SHLVL', ->
          beforeEach ->
            process.env.SHLVL = '2'
            cache()
            delete(process.env.SHLVL)
            process.env.THIS_IS_CURRENT = 'true'

          it 'returns the cached env', ->
            expect(EnvStore.get().THIS_IS_CURRENT).toBeUndefined()

        describe 'and the cached env also does not have SHLVL', ->
          beforeEach ->
            delete(process.env.SHLVL)
            process.env.FOO = 'foo'
            process.env.PATH += ':/foo/bar'
            cache()

          describe 'and the current env has more keys than the cached one', ->
            beforeEach ->
              process.env.BAR = 'bar'

            it 'returns the current env', ->
              env = EnvStore.get()
              expect(env.FOO).toBe('foo')
              expect(env.BAR).toBe('bar')

          describe 'and the cached env has more keys than the current one', ->
            beforeEach ->
              delete(process.env.FOO)

            it 'returns the cached env', ->
              env = EnvStore.get()
              expect(env.FOO).toBe('foo')

          describe 'and the current and the cached env have same numbers of keys', ->
            describe 'and the current one has longer PATH', ->
              beforeEach ->
                process.env.PATH += ':/foo/bar/baz'

              it 'returns the current one', ->
                expect(EnvStore.get().PATH).toContain(':/foo/bar/baz')

            describe 'and the cache one has longer PATH', ->
              beforeEach ->
                process.env.PATH = process.env.PATH.slice(0, -4)

              it 'returns the cached one', ->
                expect(EnvStore.get().PATH).toContain(':/foo/bar')

            describe 'and the current and cached env have same length PATH', ->
              beforeEach ->
                process.env.PATH = process.env.PATH.replace('/bar', '/baz')

              it 'returns the current one', ->
                expect(EnvStore.get().PATH).toContain(':/foo/baz')
