#!/usr/bin/env ruby
# encoding: utf-8

# File: sylk2csv.rb
# Created: 03/08/13
# Extracted from original KL file of the same name and modified by MD
# Original KL file: created by MD 15/05/12, completed by KL 16/06/12
#
# (c) Michel Demazure & Kenji Lefevre

# conversion from Sylk to CSV
module Sylk
  # 2D-table for CSV output
  class Table < Array
    # separator for CSV file
    DEFAULT_SEPARATOR = "\t"

    # possible patterns for sylk file lines
    # model C;X10;Y1;K99.2900 ou C;X1;Y8;K"NVAS00HS"
    PATTERN_STANDARD = /^C;X(\d*);Y(\d*);K(.*)$/
    # model F;P0;FG0G;X112;Y109 (this means next line is a date value)
    PATTERN_DATE_COORDINATES = /^F;P0;FG0G;X(\d*);Y(\d*)/
    # model C;K39451 (39451 is the number of days since 1904-01-01)
    PATTERN_DATE_VALUE = /^C;K(\d*)/

    # constants for date computing from sylk format to yyyy-mm-dd format
    date_zero_excel = Date.new(1904)
    date_zero_unix = Date.new(1970)
    GAP_IN_DAYS = date_zero_unix - date_zero_excel
    SECONDS_PER_DAY = 60 * 60 * 24

    # @param [String] val Sylk date value
    # @return [String] CSV date value
    def self.date_value(val)
      val.chomp!
      timestamp = (val.to_i - GAP_IN_DAYS) * SECONDS_PER_DAY + 1
      # get date of format YYYY-MM-DD
      Time.at(timestamp).to_date.to_s
    end

    # To find numeric strings
    NUM_REGEXP = /^\d*(\.\d*)?$/

    # @param [String] val Sylk value
    # @return [String] CSV value
    def self.standard_value(val)
      val.chomp!
      NUM_REGEXP =~ val ? Float(val) : val.delete('"')
    end

    # @param [Enumerator] enum enumerator of Sylk lines
    # @return [Sylk::Table] converted 2D file for output
    def initialize(enum)
      loop do
        line = enum.next
        # noinspection RubyParenthesesAroundConditionInspection
        if (match = PATTERN_STANDARD.match(line))
          item = Table.standard_value(match[3])
        elsif (match = PATTERN_DATE_COORDINATES.match(line))
          val = PATTERN_DATE_VALUE.match(enum.next)[1]
          item = Table.date_value(val)
        else
          next
        end
        fill(*match[1..2], item)
      end
    end

    # write in table CSV value 'val', for Sylk coordinates 'x' and 'y'
    # @param [Integer] col x coordinate
    # @param [Integer] row y coordinate
    # @param [String] val value to fill in this box
    def fill(col, row, val)
      (self[row.to_i - 1] ||= [])[col.to_i - 1] = val
    end

    # @param [String] separator item separator for CSV file
    # @return [Array<String>] lines of CSV file
    def to_csv(separator = DEFAULT_SEPARATOR)
      compact.map do |line|
        new_line = line.map { |item| (item || '').to_s.chomp }
        new_line.join(separator)
      end
    end
  end
end
