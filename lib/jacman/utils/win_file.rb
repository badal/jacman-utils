#!/usr/bin/env ruby
# encoding: utf-8
#
# File: win_file.rb
# Created: 8/11/13 by conversion of sage_file.rb
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  # subclass of File to manage Windows files on Mac
  #
  # File : utf-8 and \n
  # WinFile : Windows-1252 and \r\n
  #
  # WARNING: this works only on Unix systems, due to terminators
  class WinFile < ::File
    # attribute value
    DATA = "54 45 58 54 74 74 78 74 00 50 00 00 00 00 00 00\n00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n" # rubocop:disable LineLength
    # OSX xattr command
    CMD = '/usr/bin/xattr -wx com.apple.FinderInfo'

    # ad-hoc utility for Mac server files
    # @param [Path] file full path of file
    def self.ch_attr(file)
      command = CMD + ' "' + DATA + '" "' + file + '"'
      system(command)
    end

    # @return [Encoding] encoding of Windows files
    def self.win_encoding
      'windows-1252'
    end

    # @return [String] line terminator for Windows files
    def self.win_terminator
      Utils.on_mac? ? "\r\n" : "\n"
    end

    # convert a sylk WinFile to a csv regular File
    # @param [Path] slk_path path to WinFile sylk file
    # @param [Path] csv_path path to csv regular file
    def self.convert_from_sylk(slk_path, csv_path)
      stream = readlines(slk_path).to_enum(:each)
      table = Sylk::Table.new(stream).to_csv
      File.open(csv_path, mode: 'w') do |csv_file|
        table.each { |line| csv_file.puts line }
      end
    end

    # override the `File#readlines` method
    # read sage encoded lines separated by the win terminator
    # @return [Array] read lines
    def self.readlines(slk_path)
      lines = super(slk_path, win_terminator)
      lines.map { |line| line.encode('utf-8', win_encoding).chomp }
    end

    # override the `File#puts` method
    # print a string sage encoded with win terminator
    # @param [String] line string to be printed
    def puts(line)
      print line.encode(WinFile.win_encoding, 'utf-8', undef: :replace).chomp
      print(WinFile.win_terminator)
    end

    # convert from utf-8
    # @param [Path] utf8_file utf-8 file to be converted
    # @param [Path] converted_file converted Windows encoded
    def self.convert_from_unicode(utf8_file, converted_file)
      WinFile.open(converted_file, mode: "w:#{WinFile.win_encoding}") do |file|
        File.readlines(utf8_file).each do |line|
          file.puts line
        end
      end
    end

    # pattern for fixing numbers with more than two decimals
    PAT = Regexp.new('(\d+),(\d\d)0*')

    # convert to utf-8
    # and normalize decimal numbers to <=2 decimals
    # @param [Path] utf8_file converted utf-8 file
    # @param [Path] win_file Windows encoded file to be converted
    def self.convert_to_unicode(win_file, utf8_file)
      File.open(utf8_file, 'w:utf-8') do |file|
        WinFile.readlines(win_file).each do |line|
          file.puts line.gsub(PAT, '\1.\2')
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME

  require_relative('../utils.rb')
  include JacintheManagement
  sylk_file = File.join(TRANSFERT_DIR, 'DocVente', 'Test-export-vente.slk')
  csv_file = File.join(TRANSFERT_DIR, 'DocVente', 'Test-export.csv')
  WinFile.convert_from_sylk(sylk_file, csv_file)

end
__END__

utf8_file = File.join(HEAD_DIRECTORY, 'spec/test_files', 'Test_utf8_n.txt')
win_converted = File.join(HEAD_DIRECTORY, 'spec/test_files', 'Test_win_prod.txt')
utf8_converted = File.join(HEAD_DIRECTORY, 'spec/test_files', 'Test_utf8_prod.txt')
win_file = File.join(HEAD_DIRECTORY, 'spec/test_files', 'Test_win_r_n.txt')
WinFile.convert_from_unicode(utf8_file, win_converted)
puts FileUtils.compare_file(win_converted, win_file)

WinFile.convert_to_unicode(win_file, utf8_converted)
puts FileUtils.compare_file(utf8_converted, utf8_file)

end
