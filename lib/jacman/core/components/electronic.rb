#!/usr/bin/env ruby
# encoding: utf-8

# File: electronic.rb
# Created: 27/07/13
#
# (c) Michel Demazure & Kenji Lefevre

require_relative('electronic/octet_range.rb')
require_relative('electronic/ip_range.rb')
require_relative('electronic/subscription.rb')

module JacintheManagement
  module Core
    # methods for managing electronic subscriptions
    module Electronic
      # @return [String] limit of extra time given for following year, format 'MM-DD'
      def self.default_bonus
        Defaults.defaults[:bonus]
      end

      ## managing subscriptions

      # sql command to get electronic subscriptions for processing
      SQL_DUMP_IP = SqlScriptFile.new('dump_ip_ranges').script

      # get from DB all electronic subscriptions for this year or year past
      # @param [String] bonus extra time on next year, format 'MM-DD'
      # @return [Array<Subscription>] array of subscriptions
      def self.subscriptions(bonus = default_bonus)
        subs = Sql.answer_to_query(JACINTHE_MODE, SQL_DUMP_IP)
        subs.shift
        res = subs.map { |line| line.chomp.split(TAB) }
        res.reject! { |line| line.last == 'NULL' }
        res.map { |line| Subscription.new(*line, bonus) }
      end

      # return all valid ranges for electronic subscriptions
      # @param [String] bonus extra time on next year, format 'MM-DD'
      # @return [Array<String>] array of ranges for csv file
      def self.valid_ranges(bonus = default_bonus)
        subscriptions(bonus).map(&:valid_ranges).flatten.uniq
      end

      # return all invalid ranges for electronic subscriptions
      # @return [Array<String>] array of ranges for csv file
      def self.invalid_ranges
        subscriptions.map(&:invalid_ranges).flatten.uniq
      end

      # sql command to get electronic subscriptions for exporting
      ABO_ELEC_EXPORT_SQL = SqlScriptFile.new('dump_electronic_subscriptions').script

      ## exporting subscriptions

      # get from DB electronic subscriptions formatted for smf4
      # @param [String] bonus extra time on next year, format 'MM-DD'
      # @return [Array<Subscription>] array of subscriptions
      def self.subscriptions_to_export(bonus = default_bonus)
        sql = ABO_ELEC_EXPORT_SQL.sub('::bonus::', bonus)
        Sql.answer_to_query(JACINTHE_MODE, sql)
      end

      ## building files

      # build 'plage_ip_valid' file to be scp'ed to smf4
      # @param [String] bonus extra time on next year, format 'MM-DD'
      def self.build_valid_ranges_file(bonus = default_bonus)
        puts 'Building valid ranges file'
        path = File.join(DATADIR, 'plage_ip_valid.csv')
        File.open(path, 'w') do |file|
          valid_ranges(bonus).each { |rng| file.puts rng }
        end
      end

      # CHECK: have a wrong case to check
      # build 'plage_ip_non_valid' file
      # @return [Path] file to open
      def self.invalid_ranges_file
        path = File.join(DATADIR, 'plage_ip_invalid.txt')
        File.open(path, 'w') do |file|
          invalid_ranges.each { |rng| file.puts rng }
        end
        path
      end

      # build 'abo_elec' file to be scp'ed to smf4
      # @param [String] bonus extra time on next year, format 'MM-DD'
      def self.build_subscriptions_file(bonus = default_bonus)
        puts 'Building electronic subscription file'
        path = File.join(DATADIR, 'abo_elec.csv')
        File.open(path, 'w') do |file|
          subscriptions_to_export(bonus).each { |line| file.puts line.chomp }
        end
      end

      # build file and push it to smf4
      # @param [String] bonus extra time on next year, format 'MM-DD'
      def self.push_abo_elec_to_smf4server(bonus = default_bonus)
        build_subscriptions_file(bonus)
        Transmission.push_subscriptions
      end

      # build file and push it to smf4
      # @param [String] bonus extra time on next year, format 'MM-DD'
      def self.push_ip_to_smf4server(bonus = default_bonus)
        build_valid_ranges_file(bonus)
        Transmission.push_ranges
      end

      # open in editor invalid ranges file
      def self.show_invalid_ranges
        Utils.open_in_editor(invalid_ranges_file)
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__

  include JacintheManagement
  Electronic.show_invalid_ranges

end
