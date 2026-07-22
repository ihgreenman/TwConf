#! /usr/bin/env ruby
# Copyright 2020-2025 Ian Greenhoe
unitdir = File.dirname(File.absolute_path __FILE__)
sourcedir = File.join File.dirname(unitdir), 'ruby'

$LOAD_PATH.unshift unitdir
$LOAD_PATH.unshift sourcedir

files1 = Dir.glob File.join(unitdir, "mod_*.rb")
files1.each { |file| require file }

files2 = Dir.glob File.join(unitdir, "test_*.rb")
files2.each { |file| require file }

#require File.join(unitdir, "test_mult.rb")
