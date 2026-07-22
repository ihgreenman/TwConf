# Copyright 2020-2025 Ian Greenhoe
require "minitest/autorun"
require "Tokenizer"

class TestTokenizer < Minitest::Test
    def setup
        @tokenizer = Tokenizer.new

        @caseInsensitiveTokens = [ '<Mod Left Control>', '<lctrl>', '<ctrl>', '<Mod Left Shift>', '<lshift>', '<Mod Left Alt>', '<lalt>', '<lopt>', '<loption>', '<alt>' ];
        @caseSensitiveTokens = [ 'A', 'a', 'B', 'b', 'C', 'c', 'D', 'd', 'elephant', 'fox', 'gapple' ];

        @caseInsensitiveTokens.each do |value|
            @tokenizer.caseInsensitiveTokens[value] = { 'value' => value, 'insensitive' => true }
        end

        @caseSensitiveTokens.each do |value|
            @tokenizer.caseSensitiveTokens[value] = { 'value' => value, 'insensitive' => false }
        end
    end

    # @param tokenizer [Tokenizer]
    # @param expectedInsensitive [Map<String, object>]
    # @param expectedSensitive [Map<String, object>]
    # @return [void]
    def check_all(tokenizer, expectedInsensitive, expectedSensitive)
        assert_equal(tokenizer.caseInsensitiveTokens.length, expectedInsensitive.length)
        expectedInsensitive.each { |k, v| assert_equal(tokenizer.caseInsensitiveTokens[k].object_id, v.object_id) }
        tokenizer.caseInsensitiveTokens.each { |k, v| assert_equal(expectedInsensitive[k].object_id, v.object_id) }

        assert_equal(tokenizer.caseSensitiveTokens.length, expectedSensitive.length)
        expectedSensitive.each { |k, v| assert_equal(tokenizer.caseSensitiveTokens[k].object_id, v.object_id) }
        tokenizer.caseSensitiveTokens.each { |k, v| assert_equal(expectedSensitive[k].object_id, v.object_id) }
    end

    # @return [void]
    def test_add_remove
        tokenizer = Tokenizer.new
        expectedInsensitive = {}
        expectedSensitive = {}
        check_all(tokenizer, expectedInsensitive, expectedSensitive)

        obj = { 'a'=>'b' }
        tokenizer.caseInsensitiveTokens['foo'] = obj
        expectedInsensitive['FOO'] = obj
        check_all(tokenizer, expectedInsensitive, expectedSensitive)

        obj = { 'c'=>'d' }
        tokenizer.caseSensitiveTokens['bar'] = obj
        expectedSensitive['bar'] = obj
        check_all(tokenizer, expectedInsensitive, expectedSensitive)

        obj = { 'e'=>'f' }
        tokenizer.add('baz', true, obj)
        expectedInsensitive['BAZ'] = obj
        check_all(tokenizer, expectedInsensitive, expectedSensitive)

        obj = { 'g'=>'h' }
        tokenizer.add('quux', false, obj)
        expectedSensitive['quux'] = obj
        check_all(tokenizer, expectedInsensitive, expectedSensitive)

        tokenizer.delete 'foo'
        expectedInsensitive.delete 'FOO'
        check_all(tokenizer, expectedInsensitive, expectedSensitive)

        tokenizer.delete 'bar'
        expectedSensitive.delete 'bar'
        check_all(tokenizer, expectedInsensitive, expectedSensitive)
    end

    # @return [void]
    def test_add_duplicates
        tokenizer = Tokenizer.new
        expectedInsensitive = {}
        expectedSensitive = {}
        check_all(tokenizer, expectedInsensitive, expectedSensitive)

        obj = { 'a'=>'b' }
        tokenizer.caseInsensitiveTokens['foo'] = obj
        expectedInsensitive['FOO'] = obj
        check_all(tokenizer, expectedInsensitive, expectedSensitive)

        obj = { 'c'=>'d' }
        tokenizer.caseSensitiveTokens['bar'] = obj
        expectedSensitive['bar'] = obj
        check_all(tokenizer, expectedInsensitive, expectedSensitive)

        obj = { 'e'=>'f' }
        tokenizer.caseSensitiveTokens['foo'] = obj
        expectedSensitive['foo'] = obj
        expectedInsensitive.delete('FOO')
        check_all(tokenizer, expectedInsensitive, expectedSensitive)

        obj = { 'g'=>'h' }
        tokenizer.caseInsensitiveTokens['bar'] = obj
        expectedInsensitive['BAR'] = obj
        expectedSensitive.delete('bar')
        check_all(tokenizer, expectedInsensitive, expectedSensitive)

        obj = { 'a'=>'b' }
        tokenizer.caseInsensitiveTokens['fOO'] = obj
        expectedInsensitive['FOO'] = obj
        expectedSensitive.delete 'foo'
        check_all(tokenizer, expectedInsensitive, expectedSensitive)
    end

    # @param str [String]
    # @param expected [Array<Array>]
    # @return [void]
    def check_tokens(str, expected)
        actual = @tokenizer.tokenize(str)
        assert !actual.nil?

        assert_equal(actual.length, expected.length)
        expected.each_with_index do |k, index|
            assert_equal(actual[index]['value'], k[0])
            assert_equal(actual[index]['insensitive'], k[1])
        end
    end

    # @return [void]
    def test_tokenize_empty
        check_tokens('', [])
    end

    # @return [void]
    def test_tokenize_sensitive
        @caseSensitiveTokens.each { |k| check_tokens(k, [[k, false]]) }

        @caseSensitiveTokens.each do |k1|
            @caseSensitiveTokens.each { |k2| check_tokens(k1 + k2, [[k1, false], [k2, false]]) }
        end
    end

    # @return [void]
    def test_tokenize_insensitive_simple
        @caseInsensitiveTokens.each { |k| check_tokens(k, [[k, true]]) }

        @caseInsensitiveTokens.each do |k1|
            @caseInsensitiveTokens.each { |k2| check_tokens(k1 + k2, [[k1, true], [k2, true]]) }
        end
    end

    # @return [void]
    def test_tokenize_insensitive
        @caseInsensitiveTokens.each do |k|
            check_tokens(k, [[k, true]])
            check_tokens(k.upcase, [[k, true]])
            check_tokens(k.downcase, [[k, true]])
        end

        @caseInsensitiveTokens.each do |k1|
            @caseInsensitiveTokens.each do |k2|
                check_tokens(k1 + k2, [[k1, true], [k2, true]])
                check_tokens((k1 + k2).upcase, [[k1, true], [k2, true]])
                check_tokens((k1 + k2).downcase, [[k1, true], [k2, true]])
                check_tokens(k1.upcase + k2.downcase, [[k1, true], [k2, true]])
                check_tokens(k1.downcase + k2.upcase, [[k1, true], [k2, true]])
            end
        end
    end

    # @return [void]
    def test_tokenize_combined
        srand 0x6d1ce

        all_tokens = []
        @caseSensitiveTokens.each { |k| all_tokens.push [k, false] }
        @caseInsensitiveTokens.each { |k| all_tokens.push [k, true] }

        (0..1000).each do |_|
            count = rand 10
            str = ''
            expected = []

            (0..count).each do |_|
                token = all_tokens[rand all_tokens.length]

                if token[1]
                    case rand(3)
                    when 0
                        str += token[0]
                    when 1
                        str += token[0].upcase
                    when 2
                        str += token[0].downcase
                    end
                else
                    str += token[0]
                end

                expected.push token
            end

            check_tokens(str, expected)
        end
    end
end
