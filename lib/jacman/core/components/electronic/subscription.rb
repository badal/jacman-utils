# encoding: utf-8

# File: subscription.rb
# Created: 29/02/12 by KL under name e-abo.rb
# Modified: 15/08/13 by MD
#
# (c) Kenji Lefevre & Michel Demazure

module JacintheManagement
  module Core
    module Electronic
      # Subscription class converts a single subscription with multiple ip ranges
      # into an array of formatted lines describing couples (abo, ip range)
      class Subscription
        # @param [String] tiers tiers ID
        # @param [String] year  year 'YYYY'
        # @param [String] revue revue code
        # @param [String] ranges string of ip ranges
        # @param [String] bonus date of end of bonus time 'MM-DD'
        def initialize(tiers, revue, year, ranges, bonus)
          @tiers = tiers
          @revue = revue
          @ranges = ranges.split('\\n')
          @start = year + '-01-01'
          @end = (year.to_i + 1).to_s + "-#{bonus}"
        end

        # returns valid ranges expressed as an array of string ('\t' separated)
        # @return [Array<String>] items are (abo, ip range, start, end)
        def valid_ranges
          list = @ranges.map { |item| IPRange.new(item) }.select(&:valid?)
          list.map do |range|
            [@tiers, @revue, range.min_and_max, @start, @end].flatten.join(TAB)
          end
        end

        # return invalid ranges expressed as an array of strings ('\t' separated)
        # @return [Array<String>] array of (tiers, range) where range is invalid
        def invalid_ranges
          list = @ranges.reject do |item|
            # do not take blank line or line commented out with a sharp sign
            item =~ /^\s*$/ || item =~ /^\s*#/ || IPRange.new(item).valid?
          end
          list.map { |range| [@tiers, range].flatten.join(TAB) }
        end
      end
    end
  end
end
