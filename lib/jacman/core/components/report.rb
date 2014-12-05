#!/usr/bin/env ruby
# encoding: utf-8

# File: report.rb
# Created: 25/08/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Core
    # building executive report and mailing it
    module Report
      MESSAGE = [
        'Message automatique.',
        'Informations concernant la situation des ventes.',
        'Se renseigner auprès du personnel pour des informations additionnelles.'
      ].join("\n")

      # @return [Array<String>] addresses to send to
      def self.default_addresses
        Defaults.defaults[:report]
      end

      # WARNING: calling j2r-core gem
      # @return [Path] pdf report file
      def self.dashboard
        connect_mode = 'exploitation'
        dir = File.join(DATADIR, 'Archives')
        include JacintheReports
        JacintheReports::Dashboard.build(connect_mode, dir)
      end

      # build, write and send report
      # @param [Array<String>] dest destination addresses
      def self.mail_dashboard(dest = default_addresses)
        file = dashboard
        date = file.match(/.*_(.*)\.pdf/)[1]
        subject = "Tableau de bord SMF au #{date}"
        mail = Mail.new(dest, subject, MESSAGE)
        mail.attach_file(file)
        mail.send
        puts "#{file} sent to #{dest.join(', ')}"
      end
    end
  end
end
