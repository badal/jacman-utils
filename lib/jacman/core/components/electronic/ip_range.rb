# encoding: utf-8

# File: range_list.rb
# Created under name ip_range.rb  29/02/12 by KL
# Modified: 15/08/13 by MD
#
# (c) Kenji Lefevre and Michel Demazure

module JacintheManagement
  module Core
    module Electronic
      # Class describing IP ranges for electronic subscriptions
      class IPRange
        # string standing for an ip address range
        # attr_reader :string

        # @param [String] string standing for an ip addresses range
        def initialize(string = '')
          @string = string
          items = (@string.split('.') + [nil, nil]).take(4)
          @ranges = items.map { |item| IPRange::OctetRange.new(item) }
        end

        # @return [Boolean] whether this range list is valid
        def valid?
          # at most three dots
          three = @string.scan(/\./).size < 4
          # first two octets must be written explicitly
          two = @string =~ /^\d+\.\d+/
          # each item is a valid octet range
          valid = @ranges.all?(&:valid?)
          three && two && valid
        end

        # @return [Array] of four octets defining lowest IP in range
        def min
          @ranges.map(&:min)
        end

        # @return [Array] of four octets defining highest IP in range
        def max
          @ranges.map(&:max)
        end

        # @return [Array] of eight octets interleaving lowest and highest IP in range
        def min_and_max
          min.zip(max).flatten
        end
      end
    end
  end
end
