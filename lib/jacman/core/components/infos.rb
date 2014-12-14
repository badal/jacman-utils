#!/usr/bin/env ruby
# encoding: utf-8

# File: info
# Created: 9/12/2013
#
# (c) Michel Demazure

module JacintheManagement
  module Core
    # Information on pending actions
    module Infos
      class << self
        attr_reader :values

        # sql to count electronic subscriptions to be notified
        SQL_SUBSCRIPTION_NUMBER = SqlScriptFile.new('subscriptions_number_to_notify').script

        CAPTIONS = [
          'ventes non importées',
          'fichiers clients en cours',
          'clients à exporter',
          'notifications à faire'
        ]

        # count and return number of notifications to be done
        # @return [Integer] number of notifications to be done
        def notifications_number
          Sql.answer_to_query(JACINTHE_MODE, SQL_SUBSCRIPTION_NUMBER)[1].to_i
        end

        # fetch values and refresh the variables
        def refresh_values
          @values = [
            Core::Sales.remaining_sales_number,
            Clients.pending_client_files_number,
            Clients.clients_to_export_number,
            notifications_number
          ]
        end

        # @return [Array<String>] lines reporting state of things
        def report
          refresh_values
          CAPTIONS.zip(@values).map do |caption, value|
            "#{value} #{caption}"
          end
        end
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__

  include JacintheManagement::Core
  require_relative '../core.rb'
  puts Infos.report

end
