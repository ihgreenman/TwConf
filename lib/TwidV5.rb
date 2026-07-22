# Copyright 2020-2025 Ian Greenhoe

require 'json'
require 'Spreadsheet'

# Twiddler binary version 5 file reader
class TwidV5
    attr_reader :filename
    attr_reader :binary
    attr_reader :header
    attr_reader :chords

    # Header bytes for config file
    class Header
        # Byte 0, version, currently only version 5 supported
        attr_accessor :version

        # Byte 1, bit field
        # Bit 0
        attr_accessor :enableKeyRepeat
        # Bit 1
        attr_accessor :enableDirectKeyMode
        # Bit 2, false = right click, true = left click
        attr_accessor :joystickMouseClick
        # Bit 3
        attr_accessor :disableBluetooth
        # Bit 4
        attr_accessor :enableStickNumKey
        # Bit 7
        attr_accessor :enableStickShiftKey

        # Byte 2-3, number of chords, range 1-1020
        attr_accessor :numChords

        # Byte 4-5, sleep timeout in secords, default 1500
        attr_accessor :sleepTimeout

        # Byte 6-7, mouse left click or chord mapping, nil means "do mouse click"
        attr_accessor :leftClick

        # Byte 8-9, mouse middle click or chord mapping, nil means "do mouse click"
        attr_accessor :middleClick

        # Byte 10-11, mouse right click or chord mapping, nil means "do mouse click"
        attr_accessor :rightClick

        # Byte 12, mouse acceleration, default 10
        attr_accessor :mouseAcceleration

        # Byte 13, Key Repeat Delay, default 100
        attr_accessor :keyRepeatDelay

        # Byte 14, future expansion

        # Byte 15, bit field
        # Bit 0
        attr_reader :hapticFeedbackEnable

        def initialize()
            @version = 5

            @enableKeyRepeat = true
            @enableDirectKeyMode = false
            @joystickMouseClick = true
            @disableBluetooth = true
            @enableStickNumKey = false
            @enableStickShiftKey = false

            @numChords = 0
            @sleepTimeout = 1500

            @leftClick = nil
            @middleClick = nil
            @rightClick = nil

            @mouseAcceleration = 10
            @keyRepeatDelay = 100

            @hapticFeedbackEnable = false
        end

        def load(binary, keyboard, strings)
            unless binary.loaded
                return
            end

            @version = binary.getU8(0)
            puts "Bad version #{version}" if version != 5

            @enableKeyRepeat     = binary.getBit(1, 0) == 1
            @enableDirectKeyMode = binary.getBit(1, 1) == 1
            @joystickMouseClick  = binary.getBit(1, 2) == 1
            @disableBluetooth    = binary.getBit(1, 3) == 1
            @enableStickNumKey   = binary.getBit(1, 4) == 1
            @enableStickShiftKey = binary.getBit(1, 7) == 1

            @numChords = binary.getU16(2)
            @sleepTimeout = binary.getU16(4)
            @leftClick = getHIDOrNil(binary, 6, keyboard, strings)
            @middleClick = getHIDOrNil(binary, 8, keyboard, strings)
            @rightClick = getHIDOrNil(binary, 10, keyboard, strings)

            @mouseAcceleration = binary.getU8(12)
            @keyRepeatDelay = binary.getU8(13)

            @hapticFeedbackEnable = binary.getBit(15, 0) == 1
        end

        def save(binary, strings)
            binary.setU8(0, @version)

            binary.setBit(1, 0, @enableKeyRepeat)
            binary.setBit(1, 1, @enableDirectKeyMode)
            binary.setBit(1, 2, @joystickMouseClick)
            binary.setBit(1, 3, @disableBluetooth)
            binary.setBit(1, 4, @enableStickNumKey)
            binary.setBit(1, 7, @enableStickShiftKey)

            binary.setU16(2, @numChords)
            binary.setU16(4, @sleepTimeout)

            leftClick = @leftClick
            binary.setU16(6, leftClick ? leftClick.encode(strings) : 0)

            middleClick = @middleClick
            binary.setU16(8, middleClick ? middleClick.encode(strings) : 0)

            rightClick = @rightClick
            binary.setU16(10, rightClick ? rightClick.encode(strings) : 0)

            binary.setU8(12, @mouseAcceleration)
            binary.setU8(13, @keyRepeatDelay)

            binary.setBit(15, 0, @hapticFeedbackEnable)
        end

        def to_map
            toUse = Set.new(methods.grep(/[a-zA-Z]+=/).map { |k| k.to_s[0..-2] })
            toUse.delete 'numChords'

            result = {}
            toUse.each do |k|
                result[k] = send(k.to_sym) if k
            end
            result
        end

        def extractValue(value)
            return value unless value.is_a? String
            case value
            when /^true$/i
                true
            when /^false$/i
                false
            when /^[0-9]+$/
                value.to_i
            else
                throw "Bad value for header: '#{value}'"
            end
        end

        def from_map(map)
            toUse = Set.new(methods.grep(/[a-zA-Z]+=/).map { |k| k.to_s[0..-2] })
            toUse.delete 'numChords'

            map.each do |k, v|
                key = "#{k}="
                send(key.to_sym, extractValue(v)) if toUse.member? k
            end
        end

        private

        def getHIDOrNil(binary, offset, keyboard, strings)
            value = binary.getU16(offset)
            return nil if value == 0

            HID.decode(keyboard, value, strings)
        end
    end

    # This class represents a chord and HID code string pairing
    class ChordHIDPair
        attr_reader :chord
        attr_reader :hid

        # index (taken from the chord)
        attr_reader :index

        def initialize(chord, hid)
            @chord = chord
            @hid = hid
            @index = chord.raw
        end
    end

    # Class to contain the strings more than one HID code point long
    class HIDStrings
        def initialize(binary, header, keyboard)
            @binary = binary
            @header = header
            @keyboard = keyboard

            @strings = []
        end

        def getString(index)
            return @strings[index] unless @strings[index].nil?

            indirect = 16 + 4 * @header.numChords + 4 * index
            offset = @binary.getU32(indirect)
            stop = offset + @binary.getU16(offset)
            results = []

            offset += 2
            while offset < stop
                results.push HIDComposite.extract(@keyboard, @binary.getU16(offset))
                offset += 2
            end

            # unparse = (results.map(&:unparse)).join('')

            @strings[index] = results
        end

        def addString(hid)
            hid = hid.hidKeys if hid.is_a? HID
            index = @strings.length
            @strings.push hid
            index
        end

        def write
            offset = 16 + 4 * @header.numChords + 4 * @strings.length
            @strings.each_with_index do |str, index|
                indirect = 16 + 4 * @header.numChords + 4 * index
                @binary.setU32(indirect, offset)
                @binary.setU16(offset, 2 + str.length * 2)
                offset += 2

                str.each do |hid|
                    @binary.setU16(offset, hid.code)
                    offset += 2
                end
            end
        end
    end

    def initialize(keyboard, filename = nil)
        @keyboard = keyboard
        @filename = filename
        @binary = Binary.new(filename)
        @header = Header.new()
        @hidStrings = HIDStrings.new(@binary, @header, @keyboard)
        @header.load(@binary, @keyboard, @hidStrings)

        @chords = {}
        return unless @binary.loaded

        (0...@header.numChords).each do |index|
            offset = 16 + 4 * index

            chord = Chord.new(@binary.getU16(offset))
            chord2 = Chord.new(chord.to_s(true))
            throw "Bad reparse for '#{chord}'" if chord.raw != chord2.raw or chord.chord != chord2.chord

            hid = HID.decode(@keyboard, @binary.getU16(offset + 2), @hidStrings)

            pair = ChordHIDPair.new(chord, hid)
            @chords[pair.index] = pair
        end
    end

    def to_binary
        binary = Binary.new
        binary.autoResize = true
        strings = HIDStrings.new(binary, @header, @keyboard)

        @header.numChords = @chords.length
        @header.save(binary, strings)

        offset = 16
        indexes = @chords.keys.sort
        indexes.each do |index|
            pair = @chords[index]
            binary.setU16(offset, pair.chord.raw)
            binary.setU16(offset + 2, pair.hid.encode(strings))
            offset += 4
        end

        strings.write

        binary
    end

    def to_json(*args)
        chords = {}
        @chords.each do |_, pair|
            chords[pair.chord.to_s(true)] = pair.hid.unparse
        end

        { 'header' => @header.to_map, 'chords' => chords }.to_json(*args)
    end

    def to_csv(compact = false)
        sheet = Spreadsheet.new

        header = @header.to_map
        header.keys.sort.each do |key|
            value = header[key].to_s
            sheet.setRow 0, 0, [ 'config', key, value ]
            sheet.dy += 1
        end

        if compact
            map = {}
            @chords.each do |_, pair|
                chord = pair.chord
                hid = pair.hid
                if chord.complex or hid.unparse.length > 25
                    sheet.setRow 0, 0, [ 'chord', chord.chord, hid.unparse ]
                    sheet.dy += 1
                    next
                end

                array = map.fetch(chord.compactPrefix) { |k| map[k] = [ 'chords', k ] }
                array[chord.compactOffset] = hid.unparse
            end

            sheet.setRow 0, 0, [ '', 'prefix', 'XXX0', 'XXXL', 'XXXM', 'XXXR' ]
            sheet.dy += 1

            map.keys.sort.each do |k|
                sheet.setRow 0, 0, map[k]
                sheet.dy += 1
            end
        else
            keys = @chords.keys.sort
            keys.each do |key|
                pair = @chords[key]
                sheet.setRow 0, 0, [ 'chord', pair.chord.to_s(true), pair.hid.unparse ]
                sheet.dy += 1
            end
        end

        sheet.to_csv
    end

    def load(filename)
        if filename.upcase.end_with? '.JSON'
            load_json filename
            return
        end

        if filename.upcase.end_with? '.CSV'
            load_csv filename
            return
        end

        throw "Unrecognized file extention for #{filename}"
    end

    def parse_json(filename)
        if !File.exist? filename
            throw "File not found: #{filename}"
        end

        File.open(filename, 'r') do |file|
            return JSON.parse(file.read)
        end
    end

    def load_json(filename)
        conf = parse_json(filename)
        @header.from_map conf['header'] if conf.member? 'header'

        return unless conf.member? 'chords'

        chords = conf['chords']

        chords.each do |ch, str|
            chord = Chord.new ch
            hid = HID.parse(@keyboard, str)

            pair = ChordHIDPair.new(chord, hid)
            @chords[pair.index] = pair
        end
    end

    def load_csv(filename)
        conf = Spreadsheet.new
        if File.exist? filename
            File.open(filename, 'r') do |file|
                conf.from_csv(file.read)
            end
        else
            conf.from_csv(filename)
        end

        headers = {}
        chords = {}
        length = conf.length

        (0...length).each do |index|
            conf.dy = index
            case conf.get(0, 0)
            when 'config'
                headers[conf.get(1, 0)] = conf.get(2, 0)
            when 'chord'
                width = conf.width(index)
                (1...width).step(2) do |i|
                    chord = conf.get(i, 0)
                    hid = conf.get(i + 1, 0)
                    chords[chord] = hid unless chord.nil? or chord.empty?
                end
            end
        end

        @header.from_map(headers)
        chords.each do |k, v|
            chord = Chord.new k
            hid = HID.parse @keyboard, v
            pair = ChordHIDPair.new chord, hid
            @chords[pair.index] = pair
        end
    end

    def warn(level)
        return if level < 1

        found = Set.new
        dups = Set.new
        @chords.each_value do |pair|
            c = pair.hid.unparse
            dups.add c if found.member? c
            found.add c
        end

        alpha = 'abcdefghijklmnopqrstuvwxyz'
        chars = ' !,#$%&()*+-./0123456789:;=>?@[]^_`{|}~'
        extra = [
            '<Key Capslock>',
            '<Key Delete>',
            '<Key Down>',
            '<Key End>',
            '<Key Home>',
            '<Key Insert>',
            '<Key Left>',
            '<Key Numlock>',
            '<Key Page Down>',
            '<Key Page Up>',
            '<Key Right>',
            '<Key Scroll Lock>',
            '<Key Up>',
            '<bslash>',
            '<bsp>',
            '<doublequote>',
            '<esc>',
            '<lt>',
            '<return>',
            '<singlequote>',
            '<tab>'
        ]

        alpha.split(//).each { |c| puts "Missing hid code for '#{c}'" unless found.member? c }
        chars.split(//).each { |c| puts "Missing hid code for '#{c}'" unless found.member? c }
        extra.each { |c| puts "Missing hid code for '#{c}'" unless found.member? c }

        return if level < 2

        dups.each do |c|
            which = @chords.values.filter { |pair| pair.hid.unparse == c }
            which.map! { |pair| pair.chord.chord }
            puts "duplicate hid code '#{c}' found in #{which.join ','}"
        end

        return if level < 3

        fnKeys = [
            '<Key F1>',
            '<Key F2>',
            '<Key F3>',
            '<Key F4>',
            '<Key F5>',
            '<Key F6>',
            '<Key F7>',
            '<Key F8>',
            '<Key F9>',
            '<Key F10>',
            '<Key F11>',
            '<Key F12>',
        ]

        fnKeys.each { |c| puts "Missing hid code for '#{c}'" unless found.member? c }
    end
end
