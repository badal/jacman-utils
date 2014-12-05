#!/usr/bin/env ruby
# encoding: utf-8

# File: info
# Created: 9/12/2013
#
# (c) Michel Demazure

module JacintheManagement
  module Core
    # Information on pending actions
    module Info
      class << self
        attr_reader :values

        CAPTIONS = [
          'ventes non importées',
          'fichiers clients en cours',
          'clients à exporter',
          'notifications à faire',
          'plages ip invalides',
          'abonnés électroniques sans mail'
        ]

        # fetch values and refresh the variables
        def refresh_values
          @values = [
            Core::Sales.remaining_sales_number,
            Clients.pending_client_files_number,
            Clients.clients_to_export_number,
            Notification.notifications_number,
            Electronic.invalid_ranges.size,
            Notification.tiers_without_mail
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
  puts Info.report

end
