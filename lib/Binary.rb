# Copyright 2020-2025 Ian Greenhoe

# Binary file reader
class Binary
    attr_accessor :autoResize
    attr_accessor :readOnly
    attr_reader :data
    attr_reader :loaded

    def initialize(filename = nil)
        @data = []
        @autoResize = false
        @readOnly = false
        @loaded = false

        return if filename.nil? or filename.empty?

        File.open(filename, 'r') do |file|
            @loaded = true

            loop do
                b = file.getbyte
                break if b.nil?

                @data.push b
            end
        end
    end

    def save(filename)
        data = @data.pack('C*')

        File.open(filename, 'w') do |file|
            file.write data
        end
    end

    def length
        @data.length
    end

    def length=(size)
        throw 'Read only' if @readOnly

        delta = size - @data.length

        return if delta.zero?

        if delta.negative?
            @data = @data.first(size)
        else
            @data.push(*([ 0 ] * delta))
        end
    end

    def getBit(offset, index)
        return 0 if @data.length <= offset or offset < 0 or index < 0 or index > 7

        (@data[offset] >> index) & 0x01
    end

    def setBit(offset, index, value = 1)
        throw 'Read only' if @readOnly
        throw 'Bad index' if index < 0 or index > 7
        throw 'Bad offset' if offset < 0
        handleResize(offset + 1)

        if value == false || value == 0
            @data[offset] &= 0xff - (1 << index)
        else
            @data[offset] |= 1 << index
        end
    end

    def clearBit(offset, index)
        throw 'Read only' if @readOnly
        throw 'Bad index' if index.negative? or index > 7
        throw 'Bad offset' if offset.negative?
        handleResize offset + 1

        @data[offset] &= 0xff - (1 << index)
    end

    def getU8(offset)
        return 0 if @data.length <= offset or offset.negative?

        @data[offset]
    end

    def setU8(offset, value)
        throw 'Bad offset' if offset.negative?
        handleResize offset + 1

        @data[offset] = value & 0xff
    end

    def getU16(offset)
        return 0 if @data.length <= offset or offset.negative?

        @data[offset] + ((@data[offset + 1] || 0) << 8)
    end

    def setU16(offset, value)
        throw 'Bad offset' if offset.negative?
        handleResize offset + 2

        @data[offset]     =  value       & 0xff
        @data[offset + 1] = (value >> 8) & 0xff
    end

    def getU32(offset)
        return 0 if @data.length <= offset or offset.negative?

        @data[offset] +
            ((@data[offset + 1] || 0) <<  8) +
            ((@data[offset + 2] || 0) << 16) +
            ((@data[offset + 3] || 0) << 24)
    end

    def setU32(offset, value)
        throw 'Bad offset' if offset.negative?
        handleResize offset + 4

        @data[offset]     =  value        & 0xff
        @data[offset + 1] = (value >>  8) & 0xff
        @data[offset + 2] = (value >> 16) & 0xff
        @data[offset + 3] = (value >> 24) & 0xff
    end

    private

    def handleResize(size)
        return if @data.length >= size

        throw 'Short file' unless @autoResize
        self.length = size
    end
end
