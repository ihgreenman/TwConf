# Copyright 2020-2025 Ian Greenhoe

require 'Tokenizer'

# represents a set of mappings of scan codes/names to keys
class KeyboardLayout
    # The provided or generated name of this keyboard mapping
    attr_reader :name

    # The language name for this keyboard mapping
    attr_reader :language

    # The layout for the language (such as QWERTY or Dvorak)
    attr_reader :layout

    # The list of keys in this keyboard mapping
    attr_reader :allKeys

    # The list of modifiers
    attr_reader :modifiers

    # The list of plain keys
    attr_reader :keys

    def initialize(details)
        @details = details
        @allKeys = []

        details.each_with_index do |value, index|
            if index.zero?
                @language = value['Language']
                @layout = value['Layout']
                @name = value['Name'] || "#{@language}_#{@layout}"
            else
                key = HIDKey.new value
                @allKeys.push key
                @allKeys.push key.shifted if key.shifted
            end
        end

        @modifiers = {}
        @keys = {}
        @tokenizer = Tokenizer.new

        @allKeys.each do |key|
            key.addToTokenizer(@tokenizer)

            if key.baseCode == 0
                @modifiers[key.modifier] = key
            else
                list = @keys[key.baseCode]

                if list.nil?
                    list = []
                    @keys[key.baseCode] = list
                end

                list.push key
            end
        end
    end

    def tokenize(str)
        @tokenizer.tokenize(str)
    end

    @@layouts = nil
    @@mappings = nil

    def self.layouts
        return @@layouts unless @@layouts.nil?

        @@mappings = [
            { 'Language' => 'English', 'Layout' => 'QWERTY' },
            { 'Mod' => 0x01, 'Name' => [ 'Mod Left Control',  'lctrl', 'ctrl' ] },
            { 'Mod' => 0x02, 'Name' => [ 'Mod Left Shift',    'lshift' ] },
            { 'Mod' => 0x04, 'Name' => [ 'Mod Left Alt',      'lalt',  'lopt', 'loption',  'alt' ] },
            { 'Mod' => 0x08, 'Name' => [ 'Mod Left Meta',     'lmeta', 'lgui', 'lcommand', 'meta' ] },

            { 'Mod' => 0x10, 'Name' => [ 'Mod Right Control', 'rctrl' ] },
            { 'Mod' => 0x20, 'Name' => [ 'Mod Right Shift',   'rshift', 'shift' ] },
            { 'Mod' => 0x40, 'Name' => [ 'Mod Right Alt',     'ralt',  'ropt', 'roption' ] },
            { 'Mod' => 0x80, 'Name' => [ 'Mod Right Meta',    'rmeta', 'rgui', 'rcommand' ] },

            { 'Code' => 0x04, 'Name' => 'Key A', 'Plain' => 'a', 'Shift' => 'A' },
            { 'Code' => 0x05, 'Name' => 'Key B', 'Plain' => 'b', 'Shift' => 'B' },
            { 'Code' => 0x06, 'Name' => 'Key C', 'Plain' => 'c', 'Shift' => 'C' },
            { 'Code' => 0x07, 'Name' => 'Key D', 'Plain' => 'd', 'Shift' => 'D' },
            { 'Code' => 0x08, 'Name' => 'Key E', 'Plain' => 'e', 'Shift' => 'E' },
            { 'Code' => 0x09, 'Name' => 'Key F', 'Plain' => 'f', 'Shift' => 'F' },
            { 'Code' => 0x0A, 'Name' => 'Key G', 'Plain' => 'g', 'Shift' => 'G' },
            { 'Code' => 0x0B, 'Name' => 'Key H', 'Plain' => 'h', 'Shift' => 'H' },
            { 'Code' => 0x0C, 'Name' => 'Key I', 'Plain' => 'i', 'Shift' => 'I' },
            { 'Code' => 0x0D, 'Name' => 'Key J', 'Plain' => 'j', 'Shift' => 'J' },
            { 'Code' => 0x0E, 'Name' => 'Key K', 'Plain' => 'k', 'Shift' => 'K' },
            { 'Code' => 0x0F, 'Name' => 'Key L', 'Plain' => 'l', 'Shift' => 'L' },
            { 'Code' => 0x10, 'Name' => 'Key M', 'Plain' => 'm', 'Shift' => 'M' },
            { 'Code' => 0x11, 'Name' => 'Key N', 'Plain' => 'n', 'Shift' => 'N' },
            { 'Code' => 0x12, 'Name' => 'Key O', 'Plain' => 'o', 'Shift' => 'O' },
            { 'Code' => 0x13, 'Name' => 'Key P', 'Plain' => 'p', 'Shift' => 'P' },
            { 'Code' => 0x14, 'Name' => 'Key Q', 'Plain' => 'q', 'Shift' => 'Q' },
            { 'Code' => 0x15, 'Name' => 'Key R', 'Plain' => 'r', 'Shift' => 'R' },
            { 'Code' => 0x16, 'Name' => 'Key S', 'Plain' => 's', 'Shift' => 'S' },
            { 'Code' => 0x17, 'Name' => 'Key T', 'Plain' => 't', 'Shift' => 'T' },
            { 'Code' => 0x18, 'Name' => 'Key U', 'Plain' => 'u', 'Shift' => 'U' },
            { 'Code' => 0x19, 'Name' => 'Key V', 'Plain' => 'v', 'Shift' => 'V' },
            { 'Code' => 0x1A, 'Name' => 'Key W', 'Plain' => 'w', 'Shift' => 'W' },
            { 'Code' => 0x1B, 'Name' => 'Key X', 'Plain' => 'x', 'Shift' => 'X' },
            { 'Code' => 0x1C, 'Name' => 'Key Y', 'Plain' => 'y', 'Shift' => 'Y' },
            { 'Code' => 0x1D, 'Name' => 'Key Z', 'Plain' => 'z', 'Shift' => 'Z' },
            { 'Code' => 0x1E, 'Name' => 'Key 1', 'Plain' => '1', 'Shift' => '!' },
            { 'Code' => 0x1F, 'Name' => 'Key 2', 'Plain' => '2', 'Shift' => '@' },
            { 'Code' => 0x20, 'Name' => 'Key 3', 'Plain' => '3', 'Shift' => '#' },
            { 'Code' => 0x21, 'Name' => 'Key 4', 'Plain' => '4', 'Shift' => '$' },
            { 'Code' => 0x22, 'Name' => 'Key 5', 'Plain' => '5', 'Shift' => '%' },
            { 'Code' => 0x23, 'Name' => 'Key 6', 'Plain' => '6', 'Shift' => '^' },
            { 'Code' => 0x24, 'Name' => 'Key 7', 'Plain' => '7', 'Shift' => '&' },
            { 'Code' => 0x25, 'Name' => 'Key 8', 'Plain' => '8', 'Shift' => '*' },
            { 'Code' => 0x26, 'Name' => 'Key 9', 'Plain' => '9', 'Shift' => '(' },
            { 'Code' => 0x27, 'Name' => 'Key 0', 'Plain' => '0', 'Shift' => ')' },

            { 'Code' => 0x28, 'Name' => [ 'Key Enter',     'enter'     ], 'Plain' => '\\n', 'preferName' => '<return>' },
            { 'Code' => 0x29, 'Name' => [ 'Key Escape',    'escape'    ], 'Plain' => '\\e', 'preferName' => '<esc>' },
            { 'Code' => 0x2A, 'Name' => [ 'Key Backspace', 'backspace' ], 'Plain' => '\\b', 'preferName' => '<bsp>' },
            { 'Code' => 0x2B, 'Name' =>   'Key Tab',                      'Plain' => '\\t', 'preferName' => '<tab>' },

            { 'Code' => 0x2C, 'Name' => [ 'Key Space', 'space' ],   'Plain' => ' ' },
            { 'Code' => 0x2D, 'Name' => 'Key Minus',       'Plain' => '-',    'Shift' => '_' },
            { 'Code' => 0x2E, 'Name' => 'Key Equal',       'Plain' => '=',    'Shift' => '+' },
            { 'Code' => 0x2F, 'Name' => 'Key Left Brace',  'Plain' => '[',    'Shift' => '{' },
            { 'Code' => 0x30, 'Name' => 'Key Right Brace', 'Plain' => ']',    'Shift' => '}' },

            { 'Code' => 0x31, 'Name' => [ 'Key Backslash', 'backslash' ], 'Plain' => '\\\\', 'preferName' => '<bslash>' },
            { 'Code' => 0x31, 'Mod' => 0x20, 'Name' => [ 'Key Vertical Bar', 'vertical bar', 'bar', 'vbar' ], 'Plain' => '|' },

            # TODO: Code 0x32 Non-US # and ~

            { 'Code' => 0x33, 'Name' => 'Key Semicolon', 'Plain' => ';', 'Shift' => ':' },

            { 'Code' => 0x34, 'Name' => [ 'Key Apostrophe', 'apostrophe' ], 'Plain' => '\'', 'preferName' => '<singlequote>' },
            { 'Code' => 0x34, 'Mod' => 0x20, 'Name' => 'Shift + <Key Apostrophe>', 'Plain' => '"', 'preferName' => '<doublequote>' },

            { 'Code' => 0x35, 'Name' => 'Key Grave', 'Plain' => '`', 'Shift' => '~' },

            { 'Code' => 0x36, 'Name' => [ 'Key Comma', 'comma' ], 'Plain' => ',' },
            { 'Code' => 0x36, 'Mod' => 0x20, 'Name' => [ 'Shift + <Key Comma>', 'less than' ], 'Plain' => '\\<', 'preferName' => '<lt>' },

            { 'Code' => 0x37, 'Name' => 'Key Dot',   'Plain' => '.', 'Shift' => '>' },
            { 'Code' => 0x38, 'Name' => 'Key Slash', 'Plain' => '/', 'Shift' => '?' },

            { 'Code' => 0x39, 'Name' => [ 'Key Capslock', 'CapsLock', 'caps' ] },
            { 'Code' => 0x3A, 'Name' => [ 'Key F1',  'f1'  ] },
            { 'Code' => 0x3B, 'Name' => [ 'Key F2',  'f2'  ] },
            { 'Code' => 0x3C, 'Name' => [ 'Key F3',  'f3'  ] },
            { 'Code' => 0x3D, 'Name' => [ 'Key F4',  'f4'  ] },
            { 'Code' => 0x3E, 'Name' => [ 'Key F5',  'f5'  ] },
            { 'Code' => 0x3F, 'Name' => [ 'Key F6',  'f6'  ] },
            { 'Code' => 0x40, 'Name' => [ 'Key F7',  'f7'  ] },
            { 'Code' => 0x41, 'Name' => [ 'Key F8',  'f8'  ] },
            { 'Code' => 0x42, 'Name' => [ 'Key F9',  'f9'  ] },
            { 'Code' => 0x43, 'Name' => [ 'Key F10', 'f10' ] },
            { 'Code' => 0x44, 'Name' => [ 'Key F11', 'f11' ] },
            { 'Code' => 0x45, 'Name' => [ 'Key F12', 'f12' ] },

            { 'Code' => 0x46, 'Name' => [ 'Key Print Screen', 'printscreen'         ] },
            { 'Code' => 0x47, 'Name' => [ 'Key Scroll Lock',  'scrolllock'          ] },
            { 'Code' => 0x48, 'Name' => [ 'Key Pause',        'pause'               ] },
            { 'Code' => 0x49, 'Name' => [ 'Key Insert',       'insert', 'ins'       ] },
            { 'Code' => 0x4A, 'Name' => [ 'Key Home',         'home'                ] },
            { 'Code' => 0x4B, 'Name' => [ 'Key Page Up',      'pageup'              ] },
            { 'Code' => 0x4C, 'Name' => [ 'Key Delete',       'delete', 'del'       ] },
            { 'Code' => 0x4D, 'Name' => [ 'Key End',          'end'                 ] },
            { 'Code' => 0x4E, 'Name' => [ 'Key Page Down',    'pagedown'            ] },
            { 'Code' => 0x4F, 'Name' => [ 'Key Right',        'right', 'rightarrow' ] },
            { 'Code' => 0x50, 'Name' => [ 'Key Left',         'left', 'leftarrow'   ] },
            { 'Code' => 0x51, 'Name' => [ 'Key Down',         'down', 'downarrow'   ] },
            { 'Code' => 0x52, 'Name' => [ 'Key Up',           'up', 'uparrow'       ] },

            { 'Code' => 0x53, 'Name' => [ 'Key Numlock', 'numlock'             ] },
            { 'Code' => 0x54, 'Name' => [ 'Keypad Slash', 'kpslash', 'kp/'     ] },
            { 'Code' => 0x55, 'Name' => [ 'Keypad Asterisk', 'kpaster', 'kp*'  ] },
            { 'Code' => 0x56, 'Name' => [ 'Keypad Minus', 'kpminus', 'kp-'     ] },
            { 'Code' => 0x57, 'Name' => [ 'Keypad Plus', 'kpplus',  'kp+'      ] },
            { 'Code' => 0x58, 'Name' => [ 'Keypad Enter', 'kpenter', 'kpenter' ] },

            { 'Code' => 0x59, 'Name' => [ 'Keypad 1',   'kp1', 'kpend'    ] },
            { 'Code' => 0x5A, 'Name' => [ 'Keypad 2',   'kp2', 'kpdown'   ] },
            { 'Code' => 0x5B, 'Name' => [ 'Keypad 3',   'kp3', 'kppgdown' ] },
            { 'Code' => 0x5C, 'Name' => [ 'Keypad 4',   'kp4', 'kpleft'   ] },
            { 'Code' => 0x5D, 'Name' => [ 'Keypad 5',   'kp5'             ] },
            { 'Code' => 0x5E, 'Name' => [ 'Keypad 6',   'kp6', 'kpright'  ] },
            { 'Code' => 0x5F, 'Name' => [ 'Keypad 7',   'kp7', 'kphome'   ] },
            { 'Code' => 0x60, 'Name' => [ 'Keypad 8',   'kp8', 'kpup'     ] },
            { 'Code' => 0x61, 'Name' => [ 'Keypad 9',   'kp9', 'kppgup'   ] },
            { 'Code' => 0x62, 'Name' => [ 'Keypad 0',   'kp0', 'kpinsert' ] },
            { 'Code' => 0x63, 'Name' => [ 'Keypad Dot', 'kpdot', 'kp.', 'kpdelete' ] },

            # TODO: Code 0x64 Non-US \\ and |

            { 'Code' => 0x65, 'Name' => [ 'Key Compose',  'compose', 'application' ] },
            { 'Code' => 0x66, 'Name' => [ 'Key Power',    'power' ] },
            { 'Code' => 0x67, 'Name' => [ 'Keypad Equal', 'kpequal', 'kp=' ] },

            { 'Code' => 0x68, 'Name' => [ 'Key F13', 'f13' ] },
            { 'Code' => 0x69, 'Name' => [ 'Key F14', 'f14' ] },
            { 'Code' => 0x6A, 'Name' => [ 'Key F15', 'f15' ] },
            { 'Code' => 0x6B, 'Name' => [ 'Key F16', 'f16' ] },
            { 'Code' => 0x6C, 'Name' => [ 'Key F17', 'f17' ] },
            { 'Code' => 0x6D, 'Name' => [ 'Key F18', 'f18' ] },
            { 'Code' => 0x6E, 'Name' => [ 'Key F19', 'f19' ] },
            { 'Code' => 0x6F, 'Name' => [ 'Key F20', 'f20' ] },
            { 'Code' => 0x70, 'Name' => [ 'Key F21', 'f21' ] },
            { 'Code' => 0x71, 'Name' => [ 'Key F22', 'f22' ] },
            { 'Code' => 0x72, 'Name' => [ 'Key F23', 'f23' ] },
            { 'Code' => 0x73, 'Name' => [ 'Key F24', 'f24' ] }
        ], [
            { 'Language' => 'English', 'Layout' => 'Dvorak' },

            { 'Mod' => 0x01, 'Name' => [ 'Mod Left Control',  'lctrl', 'ctrl' ] },
            { 'Mod' => 0x02, 'Name' => [ 'Mod Left Shift',    'lshift' ] },
            { 'Mod' => 0x04, 'Name' => [ 'Mod Left Alt',      'lalt',  'lopt', 'loption',  'alt' ] },
            { 'Mod' => 0x08, 'Name' => [ 'Mod Left Meta',     'lmeta', 'lgui', 'lcommand', 'meta' ] },

            { 'Mod' => 0x10, 'Name' => [ 'Mod Right Control', 'rctrl' ] },
            { 'Mod' => 0x20, 'Name' => [ 'Mod Right Shift',   'rshift', 'shift' ] },
            { 'Mod' => 0x40, 'Name' => [ 'Mod Right Alt',     'ralt',  'ropt', 'roption' ] },
            { 'Mod' => 0x80, 'Name' => [ 'Mod Right Meta',    'rmeta', 'rgui', 'rcommand' ] },

            { 'Code' => 0x04, 'Name' => 'Key A', 'Plain' => 'a', 'Shift' => 'A' },
            { 'Code' => 0x05, 'Name' => 'Key B', 'Plain' => 'x', 'Shift' => 'X' },
            { 'Code' => 0x06, 'Name' => 'Key C', 'Plain' => 'j', 'Shift' => 'J' },
            { 'Code' => 0x07, 'Name' => 'Key D', 'Plain' => 'e', 'Shift' => 'E' },
            { 'Code' => 0x08, 'Name' => 'Key E', 'Plain' => '.', 'Shift' => '>' },
            { 'Code' => 0x09, 'Name' => 'Key F', 'Plain' => 'u', 'Shift' => 'U' },
            { 'Code' => 0x0A, 'Name' => 'Key G', 'Plain' => 'i', 'Shift' => 'I' },
            { 'Code' => 0x0B, 'Name' => 'Key H', 'Plain' => 'd', 'Shift' => 'D' },
            { 'Code' => 0x0C, 'Name' => 'Key I', 'Plain' => 'c', 'Shift' => 'C' },
            { 'Code' => 0x0D, 'Name' => 'Key J', 'Plain' => 'h', 'Shift' => 'H' },
            { 'Code' => 0x0E, 'Name' => 'Key K', 'Plain' => 't', 'Shift' => 'T' },
            { 'Code' => 0x0F, 'Name' => 'Key L', 'Plain' => 'n', 'Shift' => 'N' },
            { 'Code' => 0x10, 'Name' => 'Key M', 'Plain' => 'm', 'Shift' => 'M' },
            { 'Code' => 0x11, 'Name' => 'Key N', 'Plain' => 'b', 'Shift' => 'B' },
            { 'Code' => 0x12, 'Name' => 'Key O', 'Plain' => 'r', 'Shift' => 'R' },
            { 'Code' => 0x13, 'Name' => 'Key P', 'Plain' => 'l', 'Shift' => 'L' },

            { 'Code' => 0x14, 'Name' => [ 'Key Q', 'apostrophe' ], 'Plain' => '\'', 'preferName' => '<singlequote>' },
            { 'Code' => 0x14, 'Mod' => 0x20, 'Name' => 'Shift + <Key Q>', 'Plain' => '"', 'preferName' => '<doublequote>' },

            { 'Code' => 0x15, 'Name' => 'Key R', 'Plain' => 'p', 'Shift' => 'P' },
            { 'Code' => 0x16, 'Name' => 'Key S', 'Plain' => 'o', 'Shift' => 'O' },
            { 'Code' => 0x17, 'Name' => 'Key T', 'Plain' => 'y', 'Shift' => 'Y' },
            { 'Code' => 0x18, 'Name' => 'Key U', 'Plain' => 'g', 'Shift' => 'G' },
            { 'Code' => 0x19, 'Name' => 'Key V', 'Plain' => 'k', 'Shift' => 'K' },

            { 'Code' => 0x1A, 'Name' => [ 'Key W', 'comma' ], 'Plain' => ',' },
            { 'Code' => 0x1A, 'Name' => [ 'Shift + <Key W>', 'less than' ], 'Plain' => '\\<', 'preferName' => '<lt>' },

            { 'Code' => 0x1B, 'Name' => 'Key X', 'Plain' => 'q', 'Shift' => 'Q' },
            { 'Code' => 0x1C, 'Name' => 'Key Y', 'Plain' => 'f', 'Shift' => 'F' },
            { 'Code' => 0x1D, 'Name' => 'Key Z', 'Plain' => ';', 'Shift' => ':' },
            { 'Code' => 0x1E, 'Name' => 'Key 1', 'Plain' => '1', 'Shift' => '!' },
            { 'Code' => 0x1F, 'Name' => 'Key 2', 'Plain' => '2', 'Shift' => '@' },
            { 'Code' => 0x20, 'Name' => 'Key 3', 'Plain' => '3', 'Shift' => '#' },
            { 'Code' => 0x21, 'Name' => 'Key 4', 'Plain' => '4', 'Shift' => '$' },
            { 'Code' => 0x22, 'Name' => 'Key 5', 'Plain' => '5', 'Shift' => '%' },
            { 'Code' => 0x23, 'Name' => 'Key 6', 'Plain' => '6', 'Shift' => '^' },
            { 'Code' => 0x24, 'Name' => 'Key 7', 'Plain' => '7', 'Shift' => '&' },
            { 'Code' => 0x25, 'Name' => 'Key 8', 'Plain' => '8', 'Shift' => '*' },
            { 'Code' => 0x26, 'Name' => 'Key 9', 'Plain' => '9', 'Shift' => '(' },
            { 'Code' => 0x27, 'Name' => 'Key 0', 'Plain' => '0', 'Shift' => ')' },

            { 'Code' => 0x28, 'Name' => [ 'Key Enter',     'enter'     ], 'Plain' => '\\n', 'preferName' => '<return>' },
            { 'Code' => 0x29, 'Name' => [ 'Key Escape',    'escape'    ], 'Plain' => '\\e', 'preferName' => '<esc>' },
            { 'Code' => 0x2A, 'Name' => [ 'Key Backspace', 'backspace' ], 'Plain' => '\\b', 'preferName' => '<bsp>' },
            { 'Code' => 0x2B, 'Name' =>   'Key Tab',                      'Plain' => '\\t', 'preferName' => '<tab>' },

            { 'Code' => 0x2C, 'Name' => [ 'Key Space', 'space' ], 'Plain' => ' ' },
            { 'Code' => 0x2D, 'Name' => 'Key Minus',       'Plain' => '[',    'Shift' => '{' },
            { 'Code' => 0x2E, 'Name' => 'Key Equal',       'Plain' => ']',    'Shift' => '}' },
            { 'Code' => 0x2F, 'Name' => 'Key Left Brace',  'Plain' => '/',    'Shift' => '?' },
            { 'Code' => 0x30, 'Name' => 'Key Right Brace', 'Plain' => '=',    'Shift' => '+' },

            { 'Code' => 0x31, 'Name' => [ 'Key Backslash', 'backslash' ], 'Plain' => '\\\\', 'preferName' => '<bslash>' },
            { 'Code' => 0x31, 'Mod' => 0x20, 'Name' => [ 'Key Vertical Bar', 'vertical bar', 'bar', 'vbar' ], 'Plain' => '|' },

            # TODO: Code 0x32 Non-US # and ~

            { 'Code' => 0x33, 'Name' => 'Key Semicolon',  'Plain' => 's', 'Shift' => 'S' },
            { 'Code' => 0x34, 'Name' => 'Key Apostrophe', 'Plain' => '-', 'Shift' => '_' },
            { 'Code' => 0x35, 'Name' => 'Key Grave',      'Plain' => '`', 'Shift' => '~' },
            { 'Code' => 0x36, 'Name' => 'Key Comma',      'Plain' => 'w', 'Shift' => 'W' },
            { 'Code' => 0x37, 'Name' => 'Key Dot',        'Plain' => 'v', 'Shift' => 'V' },
            { 'Code' => 0x38, 'Name' => 'Key Slash',      'Plain' => 'z', 'Shift' => 'Z' },

            { 'Code' => 0x39, 'Name' => [ 'Key Capslock', 'capslock', 'caps' ] },
            { 'Code' => 0x3A, 'Name' => [ 'Key F1',  'f1'  ] },
            { 'Code' => 0x3B, 'Name' => [ 'Key F2',  'f2'  ] },
            { 'Code' => 0x3C, 'Name' => [ 'Key F3',  'f3'  ] },
            { 'Code' => 0x3D, 'Name' => [ 'Key F4',  'f4'  ] },
            { 'Code' => 0x3E, 'Name' => [ 'Key F5',  'f5'  ] },
            { 'Code' => 0x3F, 'Name' => [ 'Key F6',  'f6'  ] },
            { 'Code' => 0x40, 'Name' => [ 'Key F7',  'f7'  ] },
            { 'Code' => 0x41, 'Name' => [ 'Key F8',  'f8'  ] },
            { 'Code' => 0x42, 'Name' => [ 'Key F9',  'f9'  ] },
            { 'Code' => 0x43, 'Name' => [ 'Key F10', 'f10' ] },
            { 'Code' => 0x44, 'Name' => [ 'Key F11', 'f11' ] },
            { 'Code' => 0x45, 'Name' => [ 'Key F12', 'f12' ] },

            { 'Code' => 0x46, 'Name' => [ 'Key Print Screen', 'printscreen'   ] },
            { 'Code' => 0x47, 'Name' => [ 'Key Scroll Lock', 'scrolllock' ] },
            { 'Code' => 0x48, 'Name' => [ 'Key Pause', 'pause' ] },
            { 'Code' => 0x49, 'Name' => [ 'Key Insert', 'insert', 'ins' ] },
            { 'Code' => 0x4A, 'Name' => [ 'Key Home', 'home' ] },
            { 'Code' => 0x4B, 'Name' => [ 'Key Page Up', 'pageup' ] },
            { 'Code' => 0x4C, 'Name' => [ 'Key Delete', 'delete', 'del' ] },
            { 'Code' => 0x4D, 'Name' => [ 'Key End', 'end' ] },
            { 'Code' => 0x4E, 'Name' => [ 'Key Page Down', 'pagedown' ] },
            { 'Code' => 0x4F, 'Name' => [ 'Key Right', 'right', 'rightarrow' ] },
            { 'Code' => 0x50, 'Name' => [ 'Key Left', 'left', 'leftarrow' ] },
            { 'Code' => 0x51, 'Name' => [ 'Key Down', 'down', 'downarrow' ] },
            { 'Code' => 0x52, 'Name' => [ 'Key Up', 'up', 'uparrow' ] },

            { 'Code' => 0x53, 'Name' => [ 'Key Numlock',     'numlock' ] },
            { 'Code' => 0x54, 'Name' => [ 'Keypad Slash',    'kpslash', 'kp/' ] },
            { 'Code' => 0x55, 'Name' => [ 'Keypad Asterisk', 'kpaster', 'kp*' ] },
            { 'Code' => 0x56, 'Name' => [ 'Keypad Minus',    'kpminus', 'kp-' ] },
            { 'Code' => 0x57, 'Name' => [ 'Keypad Plus',     'kpplus',  'kp+' ] },
            { 'Code' => 0x58, 'Name' => [ 'Keypad Enter',    'kpenter' ] },

            { 'Code' => 0x59, 'Name' => [ 'Keypad 1',   'kp1', 'kpend'    ] },
            { 'Code' => 0x5A, 'Name' => [ 'Keypad 2',   'kp2', 'kpdown'   ] },
            { 'Code' => 0x5B, 'Name' => [ 'Keypad 3',   'kp3', 'kppgdown' ] },
            { 'Code' => 0x5C, 'Name' => [ 'Keypad 4',   'kp4', 'kpleft'   ] },
            { 'Code' => 0x5D, 'Name' => [ 'Keypad 5',   'kp5'               ] },
            { 'Code' => 0x5E, 'Name' => [ 'Keypad 6',   'kp6', 'kpright'  ] },
            { 'Code' => 0x5F, 'Name' => [ 'Keypad 7',   'kp7', 'kphome'   ] },
            { 'Code' => 0x60, 'Name' => [ 'Keypad 8',   'kp8', 'kpup'     ] },
            { 'Code' => 0x61, 'Name' => [ 'Keypad 9',   'kp9', 'kppgup'   ] },
            { 'Code' => 0x62, 'Name' => [ 'Keypad 0',   'kp0', 'kpinsert' ] },
            { 'Code' => 0x63, 'Name' => [ 'Keypad Dot', 'kp.', 'kpdot', 'kpdelete' ] },

            # TODO: Code 0x64 Non-US \\ and |

            { 'Code' => 0x65, 'Name' => [ 'Key Compose',  'compose', 'application' ] },
            { 'Code' => 0x66, 'Name' => [ 'Key Power',    'power' ] },
            { 'Code' => 0x67, 'Name' => [ 'Keypad Equal', 'kpequal', 'kp=' ] },

            { 'Code' => 0x68, 'Name' => [ 'Key F13', 'f13' ] },
            { 'Code' => 0x69, 'Name' => [ 'Key F14', 'f14' ] },
            { 'Code' => 0x6A, 'Name' => [ 'Key F15', 'f15' ] },
            { 'Code' => 0x6B, 'Name' => [ 'Key F16', 'f16' ] },
            { 'Code' => 0x6C, 'Name' => [ 'Key F17', 'f17' ] },
            { 'Code' => 0x6D, 'Name' => [ 'Key F18', 'f18' ] },
            { 'Code' => 0x6E, 'Name' => [ 'Key F19', 'f19' ] },
            { 'Code' => 0x6F, 'Name' => [ 'Key F20', 'f20' ] },
            { 'Code' => 0x70, 'Name' => [ 'Key F21', 'f21' ] },
            { 'Code' => 0x71, 'Name' => [ 'Key F22', 'f22' ] },
            { 'Code' => 0x72, 'Name' => [ 'Key F23', 'f23' ] },
            { 'Code' => 0x73, 'Name' => [ 'Key F24', 'f24' ] }
        ]

        @@layouts = {}

        @@mappings.each do |mapping|
            kb = KeyboardLayout.new mapping
            @@layouts[kb.name] = kb
        end

        allNames = Set.new
        @@layouts.each do |_, layout|
            layout.allKeys.each do |key|
                allNames.add key.plain
                key.names.each { |name| allNames.add name.downcase }
            end
        end

        foundNames = Set.new
        @@layouts.each do |_, layout|
            foundNames.clear

            layout.allKeys.each do |key|
                foundNames.add key.plain
                key.names.each { |name| foundNames.add name.downcase }
            end

            missing = allNames - foundNames
            missing.each { |name| puts "Missing key parse name '#{name}' from layout '#{layout.name}'" }
        end

        @@layouts
    end
end
