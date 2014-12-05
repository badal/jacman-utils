#!/usr/bin/env ruby
# encoding: utf-8

# File: notification.rb
# Created: 21/08/13
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  module Core
    # Methods for e-subscriptions notification
    module Notification
      # list to register Tiers with subscriptions but without mail
      @register = [['Id', 'Nom', 'Nombre', 'Plages ?'].join(TAB)]
      # will be built and cached
      @tiers_list = nil
      # will be built and cached
      @all_jacinthe_tiers = nil

      # Register a line
      # @param [String] line line to be registered
      def self.register(line)
        @register << line
      end

      # tiers for notification
      Tiers = Struct.new(:tiers_id, :name, :ranges, :mails, :drupal)

      # subscription parameters to be notified
      # noinspection RubyConstantNamingConvention
      ToBeNotified = Struct.new(:id, :revue, :year, :ref, :billing)

      # reopening class
      class ToBeNotified
        # @return [String] report for mail
        def report
          "#{revue} (#{year}) ref:#{ref}"
        end
      end

      # sql to extract tiers
      SQL_TIERS = SqlScriptFile.new('tiers_ip_infos').script

      # sql to count electronic subscriptions to be notified
      SQL_SUBSCRIPTION_NUMBER = SqlScriptFile.new('subscriptions_number_to_notify').script

      # sql to extract electronic subscriptions to be notified
      SQL_SUBSCRIPTIONS = SqlScriptFile.new('subscriptions_to_notify').script

      # sql to update base after notification
      SQL_UPDATE = SqlScriptFile.new('update_subscription_notified').script

      # count and return number of notifications to be done
      # @return [Integer] number of notifications to be done
      def self.notifications_number
        Sql.answer_to_query(JACINTHE_MODE, SQL_SUBSCRIPTION_NUMBER)[1].to_i
      end

      # build @to_be_notified_for and @tiers_list
      def self.extract_subscriptions_and_tiers
        @to_be_notified_for = []
        tiers_list = []
        Sql.answer_to_query(JACINTHE_MODE, SQL_SUBSCRIPTIONS).drop(1).each do |line|
          items = line.chomp.split(TAB)
          tiers_id = items.pop.to_i
          (@to_be_notified_for[tiers_id] ||= []) << ToBeNotified.new(*items)
          tiers_list << tiers_id
        end
        @tiers_list = tiers_list.sort.uniq
      end

      # @param [Integer|#to_i] tiers_id tiers identification
      # @return [Array<ToBeNotified] all subscriptions for this tiers
      def self.to_be_notified_for(tiers_id)
        extract_subscriptions_and_tiers unless @to_be_notified_for
        @to_be_notified_for[tiers_id.to_i]
      end

      # @return [Array<Integer>] list of tiers_id appearing in subscriptions
      def self.tiers_list
        extract_subscriptions_and_tiers unless @tiers_list
        @tiers_list
      end

      # @return [Array<Tiers>] list of all Jacinthe Tiers
      def self.build_jacinthe_tiers_list
        @all_jacinthe_tiers = []
        Sql.answer_to_query(JACINTHE_MODE, SQL_TIERS).drop(1).each do |line|
          items = line.split(TAB)
          parameters = format_items(items)
          @all_jacinthe_tiers[parameters[0]] = Tiers.new(*parameters)
        end
      end

      # @param [Integer|#to_i] tiers_id tiers identification
      # @return [Tiers] this Tiers
      def self.find_tiers(tiers_id)
        build_jacinthe_tiers_list unless @all_jacinthe_tiers
        @all_jacinthe_tiers[tiers_id.to_i]
      end

      # @param [Array<String>] items split line form sql answer
      # @return [Array] parameters for Tiers struct
      def self.format_items(items)
        number = items[0].to_i
        name = items[2] == 'NULL' ? items[1] : items[2] + ' ' + items[1]
        ranges = clean_split('\\n', items[3])
        mails = clean_split(',', items[4].chomp)
        [number, name, ranges, mails]
      end

      # @param [String] sep separator
      # @param [String] string string to be split
      # @return [Array<String|nil>] formatted splitting of string
      def self.clean_split(sep, string)
        string.split(sep).delete_if { |item| item == 'NULL' }
      end

      # @return [String] time stamp for files
      def self.time_stamp
        Time.now.strftime('%Y-%m-%d')
      end

      # tell JacintheD that subscription is notified
      # @param [STRING] subs_id subscription identity
      def self.update(subs_id)
        query = SQL_UPDATE
                .sub(/::abonnement_id::/, subs_id)
                .sub(/::time_stamp::/, time_stamp)
        if REAL
          Sql.query(JACINTHE_MODE, query) # this is real mode
        else
          puts "SQL : #{query}" # this is  demo mode
        end
      end

      # command to notify all subscriptions
      def self.notify_all
        number = notifications_number
        if number > 0
          puts "#{number} notifications à faire"
          do_notify_all
          report_without_mail
        else
          puts 'Pas de notification à faire'
        end
      end

      # WARNING: HACK here to protect for invalid tiers
      # Notify all subscriptions
      def self.do_notify_all
        number = tiers_list.size
        tiers_list.each do |tiers_id|
          done = Notify.new(tiers_id).notify
          next if done
          number -= 1
          puts "notification impossible pour le tiers #{tiers_id}"
        end
        puts "#{number} mails(s) de notification envoyé(s)"
      end

      # Report how many users w/o mail
      def self.report_without_mail
        number = @register.size - 1
        save_register
        puts "<b>#{number} abonné(s) dépourvu(s) d'adresse mail</b>" if number > 0
      end

      NO_MAIL_FILE = File.join(DATADIR, 'tiers_sans_mail.txt')

      # save the list of registered Tiers in a csv file
      def self.save_register
        File.open(NO_MAIL_FILE, 'w:utf-8') do |file|
          sum = 0
          @register.each do |line|
            file.puts(line)
            sum += line[2].to_i
          end
          file.puts(['','', sum, ''].join(TAB))
        end
        puts "File #{NO_MAIL_FILE} saved"
      end

      # open in editor tiers without mail file
      def self.show_tiers_without_mail
        Utils.open_in_editor(NO_MAIL_FILE)
      end

      # @return [String] number of tiers without mail and number of subscriptions
      def self.tiers_without_mail
        lines = File.open(NO_MAIL_FILE, 'r:utf-8').readlines
        "#{lines.size - 2}/#{lines.last.split(TAB)[2]}"
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME

  include JacintheManagement
  puts Notification.notifications_number

end
