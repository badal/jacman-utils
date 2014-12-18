#!/usr/bin/env ruby
# encoding: utf-8
#
# File: spec_helper.rb
# Created: 28 June 2013
#
# (c) Michel Demazure <michel@demazure.com>

gem 'minitest'
require 'minitest/autorun'

require_relative '../lib/jacman/utils.rb'

include JacintheManagement

if __FILE__ == $PROGRAM_NAME

  Dir.glob('*_spec.rb') { |f| require_relative f }

end
