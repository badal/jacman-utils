#!/usr/bin/env ruby
# encoding: utf-8

# File: sql_tools.rb
# Created: 25/9/14 by extraction from sql.rb (21/07/13)
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  # encapsulating mysql client methods
  module Sql
    # Options for mysqldump
    SQL_DUMP_OPTIONS = '--no-create-info --lock-all-tables --skip-comments ' \
      ' --opt --complete-insert --skip-triggers --default-character-set=utf8 '

    # Reset the list of loaded sql files
    def self.reset_loaded_files_list
      @loaded_sql_files = Set.new
    end

    # Pipe the given file to the MySQL client
    # @param [Hash] mode connecting mode
    # @param [Path] file full path of file to be piped
    def self.pipe_sql_file(mode, file)
      Dir.chdir(File.dirname(file))
      system "#{sql(mode)} < #{File.basename(file)}"
      @loaded_sql_files << file if @loaded_sql_files && !file.is_a?(::Tempfile)
    end

    # pipe all selected file to the MySQL client
    # @param [Hash] mode connecting mode
    # @param [Path] dir directory to search
    # @param [String] pattern Dir.glob pattern of files to be piped
    # @param [Regexp] exclude_pattern filenames to be excluded
    def self.pipe_files_in_directory(mode, dir, pattern, exclude_pattern = nil)
      Dir.chdir(dir)
      Dir.glob(pattern).each do |filename|
        file = File.join(dir, filename)
        next if @loaded_sql_files.include?(file) || file =~ exclude_pattern
        puts file
        pipe_sql_file(mode, file)
      end
    end

    # Dump the database
    # @param [Hash] mode connecting mode
    # @param [String] tables list of tables to be dumped, separated by spaces
    # @return [Array<String>] lines produced by the MYSQLDUMP command
    def self.dump(mode, tables)
      temp_file = File.join(Core::DATADIR, 'dump.temp')
      Utils.delete_if_exists(temp_file)
      command = "#{MYSQLDUMP} #{SQL_DUMP_OPTIONS} -u#{mode[:user]} -p#{mode[:password]} \
      #{mode[:database]} #{tables} > #{temp_file} "
      system command
      File.readlines(temp_file)
    end

    # Utility to build an extracted file and load it in sql
    # @param [Hash] mode connecting mode
    # @param [Path] in_file file to extract lines from
    # @param [Path] out_file file to be filled by extracted line and then loaded
    # @param [String] sql end of sql command "INTO ..."
    # @param [Regexp] regexp regexp to select lines
    # @param [Block] blok block to be given to Utils.extract_lines
    def self.filter_and_load(in_file, out_file, mode, regexp, sql, &blok)
      puts "Extracting lines from #{in_file} matching #{regexp}"
      Utils.extract_lines(in_file, out_file, regexp, &blok)
      puts "Loading #{out_file} in DB #{mode[:database]}"
      Sql.load_file(mode, out_file, sql)
    end

    # Utility to "LOAD DATA LOCAL INFILE" lines extracted from a file
    # @param [Hash] mode connecting mode
    # @param [Path] in_file file to extract lines from
    # @param [String] sql end of sql command "INTO ..."
    # @param [Regexp] regexp regexp to select lines
    # @param [Block] blok block to be given to Utils.extract_lines
    def self.extract_file_and_load(in_file, mode, regexp, sql, &blok)
      dir, name = File.split(in_file)
      extracted_file = File.join(dir, "extracted-#{name}")
      Utils.delete_if_exists(extracted_file)
      filter_and_load(in_file, extracted_file, mode, regexp, sql, &blok)
    end

    # Utility to "LOAD DATA LOCAL INFILE"
    # @param [Hash] mode connecting mode
    # @param [Path] file file to load
    # @param [String] sql end of sql command "INTO ..."
    def self.load_file(mode, file, sql)
      command = "LOAD DATA LOCAL INFILE '#{file}' IGNORE " + sql
      Sql.pipe_command(mode, command)
    end
  end
end
