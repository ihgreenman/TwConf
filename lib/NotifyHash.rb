# Copyright 2020-2025 Ian Greenhoe

# Hash that sends a notification when changed
class NotifyHash
    attr_reader :modifyCallback
    attr_accessor :normalizeInputCallback

    def initialize(&modifyCallback)
        @modifyCallback = modifyCallback
        @normalizeInputCallback = nil
        @hash = {}
    end

    def length
        @hash.length
    end

    def [](index)
        @hash[index]
    end

    def []=(index, value)
        if @normalizeInputCallback
            (index, value) = @normalizeInputCallback.call(index, value)
        end

        # NOTE: unlike a real Hash, storing `false` here is indistinguishable
        # from deleting the key, since `if value` treats both as falsy. Not
        # currently triggered -- the only values ever stored in a NotifyHash
        # are token objects (always truthy) -- but would need a nil check
        # instead of a truthiness check if that ever changes.
        if value
            @hash[index] = value
        else
            @hash.delete(index)
        end
        @modifyCallback.call(index, value)
    end

    # NOTE: unlike a real Hash#each, a zero-arity block raises here instead of
    # just being called with no arguments. Not currently triggered -- every
    # caller in this codebase passes a 1- or 2-arity block -- but a drop-in
    # zero-arg block (e.g. `hash.each { do_something }`) would break here
    # where it would work on a real Hash.
    def each(&callback)
        throw 'insufficent arguments in callback' if callback.arity == 0
        @hash.each { |k, v| callback.call([k, v]) } if callback.arity == 1
        @hash.each { |k, v| callback.call(k, v) } if callback.arity > 1
    end

    def delete(index)
        if @normalizeInputCallback
            (index, _) = @normalizeInputCallback.call(index, nil)
        end

        @hash.delete index
        @modifyCallback.call(index, nil)
    end

    def member?(index)
        @hash.member?(index)
    end

    def keys
        @hash.keys
    end

    def values
        @hash.values
    end
end
