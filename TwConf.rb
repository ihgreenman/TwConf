#!/usr/bin/env ruby
# Copyright 2020-2025 Ian Greenhoe

sourcedir = File.dirname(File.absolute_path(__FILE__))
$LOAD_PATH.unshift sourcedir
$LOAD_PATH.unshift "#{sourcedir}/ruby"

require 'json'
require 'csv'
require 'Options'
require 'Binary'
require 'Chord'
require 'HIDKey'
require 'HIDComposite'
require 'KeyboardLayout'
require 'HID'
require 'TwidV5'

opts = Options.new

if opts.output and File.exist?(opts.output) and not opts.force
    puts 'Cowardly refusing to overwrite file, use --force to override'
    exit
end

config = nil

opts.loadFiles.each do |file|
    if file.end_with?('.cfg')
        throw 'Binary file must be first file specified' unless config.nil?
        config = TwidV5.new(opts.layout, file)
        next
    end

    config = TwidV5.new(opts.layout, nil) if config.nil?
    config.load(file)
end

config.warn opts.warn if opts.warn > 0

exit unless opts.output

if opts.output.downcase.end_with? '.cfg'
    binary = config.to_binary
    binary.save opts.output
end

if opts.output.downcase.end_with? '.json'
    File.open(opts.output, 'w') do |file|
        file << config.to_json
    end
end

if opts.output.downcase.end_with? '.csv'
    File.open(opts.output, 'w') do |file|
        file << config.to_csv(opts.compact)
    end
end
