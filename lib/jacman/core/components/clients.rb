#!/usr/bin/env ruby
# encoding: utf-8

# File: clients.rb
# Refactored 6/10/13 from sage.rb Created: 24/07/13
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  module Core
    # methods to export Clients to Sage (Gescom)
    module Clients
      # Transfer directory for 'ClientSage'
      TRANSFERT_CLIENT_SAGE_DIR = File.join(TRANSFERT_DIR, 'ClientSage')

      # count and return the number of new clients
      # @return [Integer] number of new clients
      def self.clients_to_export_number
        qry = 'select count(*) from client_sage where client_sage_a_exporter = 1;'
        Sql.answer_to_query(JACINTHE_MODE, qry)[1].to_i
      end

      # export new clients from JacintheD to 'client_sage-DATE.txt'
      def self.export_client_sage
        number = clients_to_export_number
        if number > 0
          puts "<b>#{number} nouveau(x) client(s)</b>"
          build_and_push_the_client_file
        else
          puts 'Pas de nouveau client'
        end
      end

      # export new clients from JacintheD to 'client_sage-DATE.txt'
      def self.build_and_push_the_client_file
        sage_file = sage_file_from(the_utf8_client_file)
        Utils.archive(TRANSFERT_CLIENT_SAGE_DIR, sage_file)
        push_file(sage_file)
      end

      # push a file to the Aspaway server
      # @param [Path] sage_file full path of file to push
      def self.push_file(sage_file)
        error = Transmission.push_to_aspaway(sage_file)
        if error
          fail "Fichier non transmis #{sage_file}\nERREUR : #{error}"
        else
          puts 'Fichier transmis'
        end
      end

      # build the formatted client file for Sage
      # @param [Path] file the utf8 client file to be formatted
      # @return [Path] file constructed
      def self.sage_file_from(file)
        client_file =
            File.join(TRANSFERT_CLIENT_SAGE_DIR, "client_sage-#{Utils.my_date}.txt")
        WinFile.convert_from_unicode(file, client_file)
        puts "File #{client_file} written"
        client_file
      end

      # @return [Path] temporary utf-8 file to be formatted
      def self.the_utf8_client_file
        # WARNING: SQL needs a public directory to be able to write
        file = File.join(SQL_DUMP_DIR, 'client_sage_utf8.txt')
        Utils.delete_if_exists(file)
        puts 'Dumping clients...This might take a while if many. Be patient...'
        qry = "SET NAMES 'utf8'; call export_client_sage('#{file}');"
        Sql.query(JACINTHE_MODE, qry)
        file
      end

      ### CommandWatcher for client file

      # @return [Integer] number of pending client files
      def self.pending_client_files_number
        clean_read_files
        pending_files.size
      end

      # show the client files directory
      def self.show_client_files
        JacintheManagement::Utils.open_file(Core::Clients::TRANSFERT_CLIENT_SAGE_DIR)
      end

      # send again pending client files
      # WARNING: do not inline 'pending_files' because sending may fail again
      #  and the file will stay in the directory
      def self.resend_pending_files
        pending_files.each { |file| push_file(file) }
      end

      # @return [Array<String>] path of client files left in directory
      def self.pending_files
        Dir.glob("#{TRANSFERT_CLIENT_SAGE_DIR}/client_sage*.txt")
      end

      # delete client files with copy returned from Aspaway
      def self.clean_read_files
        pending_files.each do |file|
          path = File.join('ClientSage', File.basename(file))
          # TODO: delete also the file in aspaway's dir
          File.delete(file) if AspawayImporter.new(path).returned
        end
      end
    end
  end
end
if __FILE__ == $PROGRAM_NAME

  require_relative 'aspaway_importer.rb'
  include JacintheManagement

end
