#!/usr/bin/env ruby

require "bundler/setup"
require "thor"
require 'net/ssh'
require "ruby_installer"

RubyInstaller::CLI.start(ARGV)
