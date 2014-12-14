#!/usr/bin/env ruby
# encoding: utf-8
#
# File: version.rb
# Created: 28 June 2013
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  module Core
    MAJOR = 2
    MINOR = 1
    TINY  = 1

    VERSION = [MAJOR, MINOR, TINY].join('.').freeze
  end
end

if __FILE__ == $PROGRAM_NAME

  puts JacintheManagement::Core::VERSION

end
