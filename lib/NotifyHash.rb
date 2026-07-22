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

        if value
            @hash[index] = value
        else
            @hash.delete(index)
        end
        @modifyCallback.call(index, value)
    end

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
