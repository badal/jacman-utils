# encoding: utf-8

# File: octet_range.rb
# Created: 29/02/12 by KL
# Modified: 15/08/13 by MD
#
# (c) Kenji Lefevre and Michel Demazure

module JacintheManagement
  module Core
    module Electronic
      # reopening
      class IPRange
        # Class of octet range translation
        class OctetRange
          # value returned by :min and :max for none valid OctetRange
          NON_VALID_OCTET = 'xxx'

          # @param [String] str string to be tested
          # @return [Boolean] true when str represents an integer between 0 and 255
          def self.good_value?(str)
            str =~ /^\d+$/ && str.to_i < 256 && str.to_i > -1
          end

          # @param [String] cpl string to be tested
          # @return [Boolean] true when cpl represents a couple of good integers
          #   separated by a '-' sign
          def self.good_couple?(cpl)
            match_data = /^(\d+)-(\d+)$/.match(cpl)
            match_data && good_value?(match_data[1]) && good_value?(match_data[2])
          end

          attr_reader :string, :valid, :max, :min
          alias_method :valid?, :valid

          # @param [String] string octet range input
          def initialize(string)
            @string = (string || '*').strip
            build_values
          end

          # build parameters according to type
          def build_values
            case
            when @string == '*'
              build_full_range
              # number between 0 and 255
            when OctetRange.good_value?(@string)
              build_single_address
              # two numbers between 0 and 255 separated with a minus sign
            when OctetRange.good_couple?(@string)
              build_range
            else
              build_invalid
            end
          end

          # build when invalid
          def build_invalid
            @valid = false
            @min = NON_VALID_OCTET
            @max = NON_VALID_OCTET
          end

          # build when full_range
          def build_full_range
            @valid = true
            @min = 0
            @max = 255
          end

          # build when single address
          def build_single_address
            @valid = true
            @min = @string.to_i
            @max = @min
          end

          # build when real range
          def build_range
            @valid = true
            match_data = /^(\d+)-(\d+)$/.match(@string)
            @min = match_data[1]
            @max = match_data[2]
          end
        end
      end
    end
  end
end
