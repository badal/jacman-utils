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

    # model mail files
    MODEL_DIR = File.join(SMF_SERVEUR, 'Jacinthe', 'Tools', 'Templates', 'Mail')
    # mail smtp server
    MAIL_MODE = Conf.mail_mode
  end
end
