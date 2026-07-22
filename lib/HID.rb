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
        # Low byte 0xff means "code is a string-table index", per the Twiddler
        # protocol. A single composite whose modifier byte is itself 0xff (all
        # 8 modifiers held) would be indistinguishable from that sentinel, so
        # HID#encode always routes that case through the string table instead
        # of encoding it directly -- see encode below.
        hidComposites = 0xff == (code & 0xff) ? strings.getString(code >> 8) : [HIDComposite.extract(keyboard, code)]

        return HID.new(hidComposites)
    end

    def encode(strings)
        if @hidKeys.length == 1 and (@hidKeys[0].code & 0xff) != 0xff
            return @hidKeys[0].code
        end

        # Either multiple keys, or a single key whose low byte would collide
        # with the 0xff string-table sentinel -- both must go through the
        # string table, per protocol.
        index = strings.addString(self)
        (index << 8) | 0xff
    end
end
