#!/usr/bin/env ruby
# encoding: utf-8

# File: win_file_spec.rb
# Created: 11/11/13
#
# (c) Michel Demazure <michel@demazure.com>

require_relative 'spec_helper.rb'
require_relative '../lib/jacman/utils/win_file.rb'

include JacintheManagement

describe WinFile do
  TEST_FILES = File.join(__FILE__, '..', 'test_files')

  it 'should be a WinFile' do
    WinFile.open('test', 'w') do |file|
      file.must_be_instance_of(WinFile)
    end
    File.delete('test')
  end

  it 'puts should write the good separator' do
    WinFile.open('test.txt', 'w') do |file|
      file.puts('abc')
      file.puts('def')
    end
    WinFile.open('test.txt', 'r') do |file|
      content = file.read
      term = WinFile.win_terminator
      content.must_equal "abc#{term}def#{term}"
    end
    File.delete('test.txt')
  end

  it 'readlines should split the good separator' do
    WinFile.open('test2.txt', 'w') do |file|
      term = WinFile.win_terminator
      file.print "abc#{term}def"
    end
    WinFile.readlines('test2.txt').size.must_equal 2
    File.delete('test2.txt')
  end

  it 'should convert from win to utf-8' do
    win_file = File.join(TEST_FILES, 'Test_win_r_n.txt')
    utf8_converted = File.join(TEST_FILES, 'Test_utf8_prod.txt')
    WinFile.convert_to_unicode(win_file, utf8_converted)
    size_diff = File.size(utf8_converted) - File.size(win_file)
    size_diff.must_equal 33
  end

  it 'should convert to utf-8 and normalize numbers' do
    win_file = File.join(TEST_FILES, 'Tarifs.csv')
    utf8_converted = File.join(TEST_FILES, 'Tarifs_converted.csv')
    utf8_correct = File.join(TEST_FILES, 'Tarifs_utf8_correct.csv')
    WinFile.convert_to_unicode(win_file, utf8_converted)
    File.read(utf8_converted).must_equal(File.read(utf8_correct))
  end


  it 'should convert from utf_8 to win' do
    utf8_file = File.join(TEST_FILES, 'Test_utf8_n.txt')
    win_converted = File.join(TEST_FILES, 'Test_win_prod.txt')
    WinFile.convert_from_unicode(utf8_file, win_converted)
    size_diff = File.size(utf8_file) - File.size(win_converted)
    size_diff.must_equal 11
  end
end
