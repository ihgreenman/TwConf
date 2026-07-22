# Copyright 2020-2025 Ian Greenhoe
require 'optparse'

# Command line options parser class
class Options
    attr_reader :createTemplate
    attr_reader :loadFiles
    attr_reader :output
    attr_reader :compact
    attr_reader :force
    attr_reader :layout
    attr_reader :warn
    attr_reader :verbosity

    def initialize
        @typePostfix = /\.(JSON|CSV|CFG)$/

        OptionParser.new do |opts|
            opts.banner = 'Usage: TwConf.rb [options] FILES'

            opts.on('-t', '--template', 'Create template(s)') do
                @createTemplate = true
            end
            @createTemplate = false

            opts.on('-l', '--load=FILE', 'Load configuration file') do |value|
                checkFileType value
                @loadFiles.push value
            end
            @loadFiles = []

            opts.on('-L', '--layout=LAYOUT', 'Use specific keyboard layout') do |value|
                @layout = KeyboardLayout.layouts[value]
                listLayoutsAndExit if @layout.nil?
            end
            @layout = KeyboardLayout.layouts['English_QWERTY']

            opts.on('--list', '--list-layout', 'Show available layouts') do
                listLayoutsAndExit
            end

            opts.on('-o', '--output=FILE', 'Create twiddler configuration') do |value|
                checkFileType value
                @output = value
            end
            @output = nil

            # opts.on('-C', '--compact-chord', 'Use compact chord lines when creating CSV file') do
            #    @compact = true
            # end
            @compact = false

            opts.on('-w', '--warn[=LEVEL]', 'Warn against missing codepoints') do |level|
                @warn = (level || 1).to_i
            end
            @warn = 0

            opts.on('-f', '--[no-]force', 'Force overwrite') do |value|
                @force = value
            end
            @force = false

            opts.on('-v', '--[no-]verbose', 'Run verbosely') do |value|
                @verbosity += value ? 1 : -1
            end
            @verbosity = 0

            opts.on('-h', '-?', '--help', 'Print this help') do
                puts opts
                exit
            end
        end.parse(ARGV)
    end

    def listLayoutsAndExit
        puts 'Available layouts:'
        KeyboardLayout.layouts.each { |name, _| puts name }
        exit
    end

    def checkFileType(file)
        return if @typePostfix.match file.upcase

        puts "Bad file name #{file}"
        puts 'File types can only be .json, .csv, or .cfg'
        puts 'See --help or -h for details'
        exit
    end

    def verbose
        @verbosity.positive? == true
    end
end
