# Copyright 2020-2025 Ian Greenhoe

# Composite HID key code
class HIDComposite
    # Individual component key codes
    attr_reader :components

    # Default name (for display)
    attr_reader :name

    # Unparse -- the cannonical version for parsing
    attr_reader :unparse

    # The modifier code. One byte.
    attr_reader :modifier

    # The base scan code. One byte.
    attr_reader :baseCode

    # The full scan code. Two bytes.
    attr_reader :code

    def initialize(hidKeys)
        @components = hidKeys.clone
        @components.sort! { |a, b| a.code <=> b.code }
        first = true
        @name = ''
        @unparse = ''
        @modifier = 0
        @baseCode = 0
        @code = 0

        @components.each do |k|
            if first
                first = false
            else
                @name += '+'
            end

            @name += k.name
            @unparse += k.unparse
            @modifier |= k.modifier
            @baseCode |= k.baseCode
            @code |= k.code
        end
    end

    def HIDComposite.extract(keyboard, code)
        baseCode = code >> 8
        modifier = code & 0xff

        composite = []
        baseKeys = keyboard.keys[baseCode]
        throw "Bad keycode #{code.to_s(16)}" unless baseKeys

        composite = baseKeys.length > 1 && 0 != (baseKeys[1].modifier & modifier) ? [baseKeys[1]] : [baseKeys[0]]
        modifier = (modifier | composite[0].modifier) - composite[0].modifier

        (0..7).each do |bit|
            mask = 1 << bit
            composite.push keyboard.modifiers[mask] if 0 != (modifier & mask)
        end

        HIDComposite.new(composite)
    end
end