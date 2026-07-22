# Copyright 2020-2025 Ian Greenhoe

# Twiddler chord
class Chord
    # Raw chord value
    attr_reader :raw

    # Buttons in chord
    attr_reader :buttons

    # Chord representation
    attr_reader :chord

    # Chord is complex (multiple buttons in same row)
    attr_reader :complex

    # Chord prefix for compact CSV
    attr_reader :compactPrefix

    # Chord offset for compact CSV
    attr_reader :compactOffset

    # Physical device button
    class Button
        attr_reader :name

        # The chord bit (0-15 inclusive)
        attr_reader :bit

        # The chord mask (1 << by bit)
        attr_reader :mask

        # The prefix, used for modifier buttons such as shift, alt, control, num
        attr_reader :prefix

        # The chord side (R for right, M for middle, L for left, blank for modifiers)
        attr_reader :side

        # The chord row. Modifers are row 0, other buttons are 1-4
        attr_reader :row

        # Either the prefix or side
        attr_reader :prefixOrSide

        def initialize(details)
            @name = ''
            @bit = -1
            @mask = -1
            @prefix = ''
            @side = ''
            @row = 0

            details.each do |k, v|
                case k
                when :Name
                    @name = v
                when :bit
                    @bit = checkInt(v, 0, 15)
                    @mask = 1 << @bit
                when :Prefix
                    @prefix = checkString(v.to_s.upcase, %w[N A C S])
                    @prefixOrSide = @prefix
                when :Side
                    @side = checkString(v.to_s.upcase, %w[R M L])
                    @prefixOrSide = @side
                when :Row
                    @row = checkInt(v, 0, 4)
                end
            end

            if @prefix.empty?
                throw "Bad button #{details}, must have one of prefix or side" if @side.empty? or @row == 0
            else
                throw "Bad button #{details}, must have one of prefix or side" unless @side.empty? and @row == 0
            end

            throw 'Missing bit' if @bit == -1
        end

        private

        def checkString(value, possible)
            found = false
            possible.each do |poss|
                if value == poss
                    found = true
                    break
                end
            end

            throw "Bad value '#{value}', should be one of #{possible.join(',')}" unless found
            value
        end

        def checkInt(value, min, max)
            v = value.to_i
            throw "Bad value '#{value}', must be int between #{min} and #{max}" if value.is_a? String and v.to_s != value
            throw "Bad value '#{value}', must be int between #{min} and #{max}" if v < min or v > max
            v
        end
    end

    def initialize(chord)
        initButtons

        if chord.is_a? Integer
            @buttons = parseBits(chord)
            @raw = chord
            @chord = unparse
        end

        if chord.is_a? String
            @buttons = parseCompact(chord)
            @raw = @buttons.inject(0) { |memo, button| memo | button.mask }
            @chord = unparse
        end

        @buttons.sort! { |a, b| a.bit <=> b.bit }

        rowCounts = [ 0 ] * 5

        @buttons.each do |button|
            rowCounts[button.row] += 1
        end

        rowCounts[0] = 0
        @complex = rowCounts.any? { |v| v > 1 }
        @compactPrefix = ''
        @compactOffset = -1

        return if @complex

        prefixButtons = @buttons.filter { |button| button.row < 4 }
        @compactPrefix = unparseButtons(prefixButtons)
        @compactPrefix[-1..-1] = 'X'

        case @chord[-1]
        when '0'
            @compactOffset = 2
        when 'L'
            @compactOffset = 3
        when 'M'
            @compactOffset = 4
        when 'R'
            @compactOffset = 5
        else
            throw "Bad final character for compact #{unparse}"
        end
    end

    def to_s(showOnlyChord = false)
        return @chord if showOnlyChord

        buttons = @buttons.map(&:name)
        "<Chord raw:#{@raw.to_s(16)} buttons:[#{buttons.join(' ')}] chord:#{@chord}>"
    end

    private

    def parseBits(bits)
        throw "Bad chord bits #{bits}, no buttons pressed" if bits <= 0

        results = []

        @@buttons.each do |button|
            results.push button if button.mask & bits != 0
        end

        results
    end

    @@parseCompact = /([NACS+]+)? *([RML0]|\([RML]+\))([RML0]|\([RML]+\))([RML0]|\([RML]+\))([RML0]|\([RML]+\))/

    def parseCompact(compact)
        match = @@parseCompact.match(compact)
        throw "Bad compact form #{compact}" unless match

        buttons = []
        match[1]&.split(//)&.each { |c| buttons.push @@buttonsByRow[0][c] }

        (1..4).each do |i|
            match[i + 1].to_s.split(//).each do |c|
                button = @@buttonsByRow[i][c]
                buttons.push button if button
            end
        end

        buttons
    end

    def unparse
        return @unparse if @unparse
        @unparse = unparseButtons(@buttons)
    end

    def unparseButtons(buttons)
        byRow = [ '', '', '', '', '' ]

        buttons.each { |button| byRow[button.row] += button.prefixOrSide }

        result = !byRow[0].empty? ? "#{byRow[0]} " : ''

        (1..4).each do |i|
            result +=   case byRow[i].length
                        when 0
                            '0'
                        when 1
                            byRow[i]
                        else
                            "(#{byRow[i]})"
                        end
        end

        result
    end

    @@buttons = nil
    @@buttonsByRow = nil
    @@buttonDefinitions = nil

    def initButtons
        return unless @@buttons.nil?

        @@buttonDefinitions = [
            { 'bit':  0, 'Name': 'NUM',  'Prefix': 'N' },
            { 'bit':  4, 'Name': 'ALT',  'Prefix': 'A'  },
            { 'bit':  8, 'Name': 'CTRL', 'Prefix': 'C' },
            { 'bit': 12, 'Name': 'SHFT', 'Prefix': 'S' },

            { 'bit':  1, 'Name': 'A',   'Side': 'R', 'Row': 1 },
            { 'bit':  2, 'Name': 'E',   'Side': 'M', 'Row': 1 },
            { 'bit':  3, 'Name': 'SP',  'Side': 'L', 'Row': 1 },

            { 'bit':  5, 'Name': 'B',   'Side': 'R', 'Row': 2 },
            { 'bit':  6, 'Name': 'F',   'Side': 'M', 'Row': 2 },
            { 'bit':  7, 'Name': 'DEL', 'Side': 'L', 'Row': 2 },

            { 'bit':  9, 'Name': 'C',   'Side': 'R', 'Row': 3 },
            { 'bit': 10, 'Name': 'G',   'Side': 'M', 'Row': 3 },
            { 'bit': 11, 'Name': 'BS',  'Side': 'L', 'Row': 3 },

            { 'bit': 13, 'Name': 'D',   'Side': 'R', 'Row': 4 },
            { 'bit': 14, 'Name': 'H',   'Side': 'M', 'Row': 4 },
            { 'bit': 15, 'Name': 'ENT', 'Side': 'L', 'Row': 4 }
        ]

        @@buttons = @@buttonDefinitions.map { |details| Button.new(details) }

        @@buttonsByRow = [ {}, {}, {}, {}, {} ]

        @@buttons.each { |button| @@buttonsByRow[button.row][button.prefixOrSide] = button }
    end
end
