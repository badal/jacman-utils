#!/usr/bin/env ruby
# encoding: utf-8

# File: server_directories.rb
# Created: 18/12/14
#
# (c) Michel Demazure

# script methods for Jacinthe Management
module JacintheManagement
  # core methods for Jacinthe manager
  module Core
    # tab character for csv files
    TAB = "\t"

    # are we on real server ?
    REAL = Conf.config['real']
    # to be used for aspaway_importer when REAL is false
    SMF2_PASSWORD = Conf.config['smf2_password']

    # paths
    # # free access directory
    SQL_DUMP_DIR = Conf.config['paths']['dump']
    # top path
    SMF_SERVEUR = Conf.config['paths']['server']
    # second level paths
    TRANSFERT_DIR = File.join(SMF_SERVEUR, 'Transfert')
    DATADIR = File.join(SMF_SERVEUR, 'Data')

    # defaults_file
    DEFAULTS_FILE = Conf.config['paths']['defaults']

    # SQL script files
    SQL_SCRIPT_DIR = File.join(SMF_SERVEUR, 'Jacinthe', 'Tools', 'Library', 'SqlFiles')

    # help files for tools
    HELP_DIR = File.join(SMF_SERVEUR, 'Jacinthe', 'Tools', 'Library', 'HelpFiles')

    # model mail files
    MODEL_DIR = File.join(SMF_SERVEUR, 'Jacinthe', 'Tools', 'Templates', 'Mail')
    # mail smtp server
    MAIL_MODE = Conf.mail_mode

    # defaults for batman
    module Defaults
      # @return [Hash] the defaults, memoized
      def self.defaults
        @defaults ||= load_defaults
      end

      # @return [Hash] the defaults, read from the file
      def self.load_defaults
        YAML.load_file(Core::DEFAULTS_FILE)
      end
    end
  end
end
