# Copyright 2020-2025 Ian Greenhoe
require "minitest/autorun"
require "NotifyHash"

class TestNotifyHash < Minitest::Test
    def setup
    end

    def check_all(actual, expected)
        assert_equal(actual.length, expected.length)
        expected.each do |k, v|
            assert_equal(actual[k].object_id, v.object_id)
            assert(actual.member? k)
            assert(!actual.member?(k + '_'))
        end
        actual.each { |k, v| assert_equal(expected[k].object_id, v.object_id) }
    end

    # @param actual [Array]
    # @param expected [Array]
    def check_changes(actual, expected)
        assert_equal(actual.length, expected.length)
        expected.each_with_index do |v, index|
            assert_equal(actual[index][0], v[0])
            assert_equal(actual[index][1].object_id, v[1].object_id)
        end
    end

    def test_add_remove
        changes = []
        actual = NotifyHash.new { |index, value| changes.push [index, value] }
        expected = {}
        expectedChanges = []
        check_all(actual, expected)
        check_changes(changes, expectedChanges)

        obj = { 'a'=>'b' }
        actual['foo'] = obj
        expected['foo'] = obj
        expectedChanges.push ['foo', obj]
        check_all(actual, expected)
        check_changes(changes, expectedChanges)

        obj = { 'c'=>'d' }
        actual['bar'] = obj
        expected['bar'] = obj
        expectedChanges.push ['bar', obj]
        check_all(actual, expected)
        check_changes(changes, expectedChanges)

        obj = { 'e'=>'f' }
        actual['baz']= obj
        expected['baz'] = obj
        expectedChanges.push ['baz', obj]
        check_all(actual, expected)
        check_changes(changes, expectedChanges)

        actual.delete('bar')
        expected.delete('bar')
        expectedChanges.push ['bar', nil]
        check_all(actual, expected)
        check_changes(changes, expectedChanges)
    end

    def test_add_remove_modifier
        changes = []
        actual = NotifyHash.new { |index, value| changes.push [index, value] }
        actual.normalizeInputCallback = lambda { |index, value| [index.upcase, value] }
        expected = {}
        expectedChanges = []
        check_all(actual, expected)
        check_changes(changes, expectedChanges)

        obj = { 'a'=>'b' }
        actual['foo'] = obj
        expected['FOO'] = obj
        expectedChanges.push ['FOO', obj]
        check_all(actual, expected)
        check_changes(changes, expectedChanges)

        obj = { 'c'=>'d' }
        actual['bar'] = obj
        expected['BAR'] = obj
        expectedChanges.push ['BAR', obj]
        check_all(actual, expected)
        check_changes(changes, expectedChanges)

        obj = { 'e'=>'f' }
        actual['baz']= obj
        expected['BAZ'] = obj
        expectedChanges.push ['BAZ', obj]
        check_all(actual, expected)
        check_changes(changes, expectedChanges)

        actual.delete('bar')
        expected.delete('BAR')
        expectedChanges.push ['BAR', nil]
        check_all(actual, expected)
        check_changes(changes, expectedChanges)
    end
end
