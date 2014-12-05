#!/usr/bin/env ruby
# encoding: utf-8

# File: aspaway_importer.rb
# Created: 20/11/13
#
# (c) Michel Demazure <michel@demazure.com>

# script methods for JacintheManagement
module JacintheManagement
  # core methods for JacMan
  module Core
    SMF2_MODE = {
      host: 'smf-2.ihp.fr',
      user: 'smf',
      directory: '/home/Aspaway/transfert'
    }

    # in REAL mode, use ssh key, else use password
    SMF2_OPTIONS = REAL ? {} : { password: SMF2_PASSWORD }

    # Methods for accessing and fetching Aspaway files on smf-2
    class AspawayImporter
      # get file from Aspaway 'transfert' directory on smf-2
      #    to Transfert directory on SMF_SERVEUR
      #
      # @param [Path] local_path path of destination file w.r. to transferts directories
      def self.fetch(local_path)
        new(local_path).fetch
      end

      # @param [Path] local_path path of destination file w.r. to transferts directories
      def initialize(local_path)
        @local_path = local_path
        @filename = File.basename(local_path)
        @local = File.join(TRANSFERT_DIR, local_path)
        @remote = File.join(SMF2_MODE[:directory], local_path)
        @remote_dir = File.join(SMF2_MODE[:directory], File.dirname(local_path))
      end

      # get file from Aspaway 'transfert' directory on smf-2
      #    to Transfert directory on SMF_SERVEUR
      def fetch
        Net::SFTP.start(SMF2_MODE[:host], SMF2_MODE[:user], SMF2_OPTIONS) do |sftp|
          entries = sftp.dir.entries(@remote_dir)
          if entries.map(&:name).include?(@filename)
            puts "Fetching #{@remote} from Aspaway transfer directory"
            sftp.download!(@remote, @local)
          end
        end
      end

      # @return [Time] creation time of file (Epoch if file does not exist)
      def time_of_file
        Net::SSH.start(SMF2_MODE[:host], SMF2_MODE[:user], SMF2_OPTIONS) do |ssh|
          ls = ssh.exec!("stat --format=%Y #{@remote}")
          Time.at(ls.to_i)
        end
      rescue RuntimeError
        Time.at(0)
      end

      # used for checking client_sage files
      # @return [Boolean] whether a remote file exists with the same name
      def returned
        time_of_file > Time.at(0)
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME

  require_relative '../core.rb'

  include JacintheManagement
  importer = AspawayImporter.new('DocVente/Ventes.slk')
  puts 'Time of aspaway file'
  before = Time.now
  ttm = importer.time_of_file
  spent = Time.now - before
  puts "File creation date : #{ttm}"
  puts "Time : #{spent}"

  puts 'fetching file'
  path = 'DocVente/Ventes.slk'
  before = Time.now
  importer.fetch
  spent = Time.now - before
  puts "wrote : #{path}"
  puts "Time : #{spent}"

end
