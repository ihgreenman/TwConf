# Copyright 2020-2025 Ian Greenhoe
require 'set'
require 'NotifyHash'

# Tokenizer
class Tokenizer
    attr_reader :caseInsensitiveTokens
    attr_reader :caseSensitiveTokens

    def initialize
        @doRebuild = true

        @caseInsensitiveTokens = NotifyHash.new do |k, v|
            if v
                toDelete = @caseSensitiveTokens.keys.filter { |key| key.upcase == k }
                toDelete.each { |key| @caseSensitiveTokens.delete key }
            end
            @caseSensitiveTokens.delete k if v
            @doRebuild = true
        end

        @caseInsensitiveTokens.normalizeInputCallback = lambda do |k, v|
            [k.upcase, v]
        end

        @caseSensitiveTokens = NotifyHash.new do |k, v|
            @caseInsensitiveTokens.delete k.upcase if v
            @doRebuild = true
        end
    end

    def length
        return @caseInsensitiveTokens.length + @caseSensitiveTokens.length
    end

    def add(token, caseInsensitive, obj)
        throw 'Empty token' if token.empty?
        if caseInsensitive
            @caseInsensitiveTokens[token] = obj
        else
            @caseSensitiveTokens[token] = obj
        end
    end

    def delete(token)
        throw 'Empty token' if token.empty?
        @caseInsensitiveTokens.delete token
        @caseSensitiveTokens.delete token
    end

    def tokenize(str)
        if str.nil? or str.empty?
            return []
        end

        rebuild if @doRebuild

        upper = str.upcase

        result = []

        if @caseInsensitiveTokens.member? upper
            result.push @caseInsensitiveTokens[upper]
            return result
        end

        if @caseSensitiveTokens.member? str
            result.push @caseSensitiveTokens[str]
            return result
        end

        current = str
        oldLength = str.length + 1

        while current.length > 0
            if current.length == oldLength
                throw "Parse error in '#{str}' at '#{current}'"
            end

            oldLength = current.length

            # NOTE: these two loops don't break after a match, so if two
            # registered tokens shared a first character AND one were a
            # strict prefix of the other (e.g. "A" and "AB" both
            # case-sensitive), matching the shorter one first would mutate
            # `current`/`upper` mid-`.each`, and the longer token could then
            # spuriously match again against the leftover remainder within
            # the same pass -- an order-dependent double-consumption bug.
            # Not currently triggered: verified against both English_QWERTY
            # and English_Dvorak's actual token sets, no such prefix
            # conflicts exist today. This would need to be fixed (longest-
            # match-wins, with a break) before adding any keyboard layout
            # whose token names could overlap this way -- e.g. full
            # internationalization with additional language layouts.
            @byInitialInsensitive[upper[0] || ''].each do |token|
                if upper.start_with? token
                    upper = upper[token.length..upper.length]
                    current = current[token.length..current.length]
                    result.push @caseInsensitiveTokens[token]
                end
            end

            @byInitialSensitive[current[0] || ''].each do |token|
                if current.start_with? token
                    upper = upper[token.length..upper.length]
                    current = current[token.length..current.length]
                    result.push @caseSensitiveTokens[token]
                end
            end
        end

        result
    end

    def rebuild
        @doRebuild = false

        @byInitialSensitive = {}
        @byInitialSensitive.default = Set.new

        @caseSensitiveTokens.each do |token, _|
            first = token[0..0]
            list = @byInitialSensitive.fetch(first) { @byInitialSensitive[first] = Set.new }
            list.add token
        end

        @byInitialInsensitive = {}
        @byInitialInsensitive.default = Set.new

        @caseInsensitiveTokens.each do |token, _|
            first = token[0..0]
            list = @byInitialInsensitive.fetch(first) { @byInitialInsensitive[first] = Set.new }
            list.add token
        end
    end
end
