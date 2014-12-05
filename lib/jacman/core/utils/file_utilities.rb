#!/usr/bin/env ruby
# encoding: utf-8

# File: file_utilities.rb
# Created: 24/07/13
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  module Core
    # File utilities
    module Utils
      HOUR = 60 * 60

      # @return [Numeric|nil] age of file in hours | nil if file does not exist
      # @param [Path] file path of file
      def self.age(file)
        return nil unless File.exist?(file)
        delay(File.mtime(file))
      end

      # @param [Time] time time of event
      # @return [Numeric] delay in hours
      def self.delay(time)
        (Time.now - time) / HOUR
      end

      # Delete a file (if it exists)
      # @param [Path] file file to be deleted
      def self.delete_if_exists(file)
        File.delete(file) if File.exist?(file)
      end

      # Create a directory if non existent
      # @param [Path] dir path of directory to be created
      # @param [Integer] permissions
      def self.make_dir_if_necessary(dir, permissions = 0733)
        Dir.mkdir(dir, permissions) unless File.directory?(dir)
      end

      # Backup a file (if existing)
      # @param [Path] file path of file
      def self.backup(file)
        File.rename(file, "#{file}.old") if File.exist?(file)
      end

      # Copy a file to Archives subdirectory
      # @param [Path] file file to be archives
      # @param [Path] directory directory where the Archives directory is
      def self.archive(directory, file)
        dir = File.join(directory, 'Archives')
        Utils.make_dir_if_necessary(dir, 0733)
        FileUtils.cp(file, dir)
      end

      # Get the date for file stamping
      # @return [String] date of now
      def self.my_date
        Time.now.strftime('%Y%m%d-%H%M%S')
      end

      # @return [Bool] true if running on OSX
      def self.on_mac?
        RUBY_PLATFORM =~ /darwin/
      end

      # System command to open a text file
      # @return [String] system command to open a text file
      def self.open_in_editor_command
        case RUBY_PLATFORM
        when /darwin/
          'open -a /Applications/TextEdit.app'
        when /mswin|mingw/
          'start'
        else # linux
          'xdg-open'
        end
      end

      # Open a text file
      # @param [Path] filename file to open
      def self.open_in_editor(filename)
        system "#{Utils.open_in_editor_command} #{filename}"
      end

      # System open command
      # @return [String] system command to open a directory/file
      def self.open_command
        case RUBY_PLATFORM
        when /darwin/
          'open'
        when /mswin|mingw/
          'start'
        else # linux
          'xdg-open'
        end
      end

      # Open a file or directory
      # @param [Path] path full path of file/directory to open
      def self.open_file(path)
        system "#{Utils.open_command} #{path}"
      end

      # Utility to build a file by extracting (and processing) lines from another file
      # - without block, just extract the lines
      # - with block, build the lines from the MatchcData yielded to the block
      # @param [Path] in_file file to extract lines from
      # @param [Path] out_file file to write the extracted lines in
      # @param [Regexp] regexp regexp to select the lines
      # @yield [MatchData] Gives the MatchDate to the block
      # @yieldreturn [String] line to be written
      def self.extract_lines(in_file, out_file, regexp)
        File.open(out_file, 'w:utf-8') do |output|
          File.readlines(in_file, mode: 'r:utf-8').each do |line|
            match_data = regexp.match(line)
            next unless match_data
            output_line = block_given? ? yield(match_data) : line
            output.puts output_line
          end
        end
      end
    end
  end
end
