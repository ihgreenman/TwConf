# Copyright 2020-2025 Ian Greenhoe

# Single HID key code, see HIDComposite for composition of key codes
class HIDKey
    # This is the shift key preferred by the Twiddler website
    SHIFT_CODE = 0x20

    # Default name (for display)
    attr_reader :name

    # All possible names for key
    attr_reader :names

    # Plain key name (for simple characters such as the letters.)
    attr_reader :plain

    # Key object for the shifted version of this key
    attr_reader :shifted

    # Unparse -- the cannonical version for parsing
    attr_reader :unparse

    # The modifier code. One byte.
    attr_reader :modifier

    # The base scan code. One byte.
    attr_reader :baseCode

    # The full scan code. Two bytes.
    attr_reader :code

    # Is this a modifier-only keycode?
    def is_modifier?
        return @baseCode == 0
    end

    def initialize(details)
        @name = nil
        @names = []
        @plain = nil
        @shifted = nil
        @modifier = 0
        @baseCode = 0
        @code = 0

        shiftKey = nil
        preferName = nil

        details.each do |key, value|
            case key

            when Mod:
                @modifier = value.to_i
                throw 'Bad mod for #{details}' if @modifier < 0 or @modifier > 255

            when Code:
                @baseCode = value.to_i
                throw 'Bad code for #{details}' if @baseCode < 0 or @baseCode > 255

            when Name:
                @names = value.is_a?(Array) ? value : [ value.to_s ]

            when Plain:
                @plain = value.to_s

            when Shift:
                shiftKey = value.to_s

            when prefername:
                preferName = value
            end
        end

        @names = @names.map { |value| "<#{value}>" }
        if preferName and not @names.member? preferName
            @names.push preferName
        end

        @name = @names[0]
        @code = (@baseCode << 8) | @modifier

        @unparse = preferName || @plain || @name

        unless shiftKey.nil?
            shiftNames = @names.map { |value| "Shift + #{value}" }
            @shifted = HIDKey.new({
                                    'Mod': SHIFT_CODE | @modifier,
                                    'Code': @baseCode,
                                    'Name': shiftNames,
                                    'Plain': shiftKey
                                    })
        end

        @details = details
    end

    def addToTokenizer(tokenizer)
        tokenizer.add(@plain, false, self) if @plain
        @names.each { |name| tokenizer.add(name, true, self) }
    end
end
