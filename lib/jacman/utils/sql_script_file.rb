#!/usr/bin/env ruby
# encoding: utf-8

# File: sql_script_file.rb
# Created: 13/08/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  # subclass of File to manage sql sources
  class SqlScriptFile < ::File
    # pattern to be ignored
    SQL_SCRIPT_IGNORE_PATTERN = /^--|^\s*$/

    # @param [String] name base name of file (without .sql)
    def initialize(name)
      file_name = File.join(Core::SQL_SCRIPT_DIR, "#{name}.sql")
      super(file_name, 'r:utf-8')
    end

    # @return [String] sql fragment contained in file
    def script
      File.readlines(self)
        .reject { |line| SQL_SCRIPT_IGNORE_PATTERN.match(line) } # comments and empty lines
        .map(&:chomp)
        .join(' ')
        .gsub(/\s+/, ' ')
    end
  end
end
