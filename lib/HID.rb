# Copyright 2020-2025 Ian Greenhoe

# Multiple HIDComposite keys
class HID
    attr_reader :hidKeys
    attr_reader :unparse

    def initialize(hidKeys)
        @hidKeys = hidKeys.clone

        @unparse = ''

        @hidKeys.each do |k|
            @unparse += k.unparse
        end
    end

    def HID.parse(keyboard, str)
        tokens = keyboard.tokenize(str)
        result = []
        current = []
        tokens.each do |token|
            current.push token

            unless token.is_modifier?
                result.push HIDComposite.new(current)
                current.clear
            end
        end

        throw "Incomplete keycode at end of '#{str}'" unless current.empty?

        return HID.new(result)
    end

    def HID.decode(keyboard, code, strings)
        hidComposites = 0xff == (code & 0xff) ? strings.getString(code >> 8) : [HIDComposite.extract(keyboard, code)]

        return HID.new(hidComposites)
    end

    def encode(strings)
        if @hidKeys.length > 1
            index = strings.addString(self)
            return (index << 8) | 0xff
        end

        return @hidKeys[0].code
    end
end
