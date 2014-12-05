#!/usr/bin/env ruby
# encoding: utf-8

# File: transmission.rb
# Created: 19/08/13
#
# (c) Michel Demazure & Kenji Lefevre

# script methods for JacintheManagement
module JacintheManagement
  module Core
    KEYS = ['/Users/gestion/.ssh/id_rsa', '/Users/gestion/.ssh/id_rsa_save']

    DRUPAL_MODE = {
      host: 'drupal.mathrice.fr',
      user: 'gestionsmf'
    }
    SMF4_MODE = {
      host: 'smf4.emath.fr',
      user: 'www-data'
    }
    ASPAWAY_MODE = {
      host: '185.7.39.70',
      user: 'SMF_SFTP'
    }

    # transmission methods
    module Transmission
      # report whether ssh remote command was executed
      # @param [Boolean] result result of remote command
      def self.ssh_report(result, command_name)
        puts result ? "remote command '#{command_name}' executed :...\n#{result}" :
                 "error executing remote command '#{command_name}'"
      end

      # report errors from remote scp command
      # @param [String] result error report of remote command
      # @param [String] command_name name of command
      def self.scp_report(result, command_name)
        if result
          puts "ERROR executing '#{command_name}'"
          puts result
        else
          puts "remote command '#{command_name}' executed"
        end
      end

      # fetch drupal files from Mathrice server
      def self.fetch_from_drupal
        puts 'Fetching data from drupal'
        Net::SSH.start(DRUPAL_MODE[:host], DRUPAL_MODE[:user]) do |ssh|
          ssh_report(ssh.exec!(' ./bin/Jacinthe/dump_data_for_jacinthe.sh'),
                     'dump_data_for_Jacinthe')
          ssh_report(ssh.scp.download!('Drupal2Jacinthe', DATADIR, recursive: true),
                     'downloading Drupal2Jacinthe directory')
        end
      end

      #  push drupal files to Mathrice server
      def self.push_to_drupal
        puts 'Pushing data to drupal'
        Net::SSH.start(DRUPAL_MODE[:host], DRUPAL_MODE[:user]) do |ssh|
          File.readlines(Drupal::DUMP_FILES_STACK).each do |line|
            file = line.chomp
            dest = File.join('Jacinthe2Drupal', File.basename(file))
            scp_report(ssh.scp.upload!(file, dest), "uploading #{file} to #{dest}")
          end
          ssh_report(ssh.exec!(' ./bin/Jacinthe/load_data_from_jacinthe.sh'),
                     'load_data_from_jacinthe')
        end
        File.delete(Drupal::DUMP_FILES_STACK)
      end

      # scp local file in DATADIR to remote file in postgres
      # @param [String] local filename
      # @param [String] remote filename
      def self.push_to_smf4_server(local, remote)
        puts "Pushing #{local} to smf4"
        Net::SCP.start(SMF4_MODE[:host], SMF4_MODE[:user], keys: KEYS) do |scp|
          scp_report(scp.upload!(File.join(DATADIR, local), File.join('postgres', remote)),
                     "uploading #{local} to #{remote}")
        end
      end

      # push subscription file to smf4
      def self.push_subscriptions
        push_to_smf4_server('abo_elec.csv', 'acces_edit_elec_tiers.csv')
      end

      # push valid ranges file to smf4
      def self.push_ranges
        push_to_smf4_server('plage_ip_valid.csv', 'acces_edit_elec_ip.csv')
      end

      # push file to Aspaway server
      # @param [Path] path full path of file to push
      # @return [String, nil] message if error, nil if OK
      def self.push_to_aspaway(path)
        puts "pushing #{path} to aspaway"
        remote = File.join('ClientSage', File.basename(path))
        Net::SFTP.start(ASPAWAY_MODE[:host], ASPAWAY_MODE[:user], keys: KEYS) do |sftp|
          sftp.upload!(path, remote)
        end
      rescue Errno::ETIMEDOUT
        'Timeout'
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME

  puts 'transmission to aspaway'
  dir = File.join(TRANSFERT_DIR, 'ClientSage')
  files = Dir.glob("#{dir}/client_sage*.txt")
  puts files.last
  Transmission.push_to_aspaway(files.last)

end
