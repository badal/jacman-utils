#!/usr/bin/env ruby
# encoding: utf-8
#
# File: reset_db.rb
# Created: 28/06/13
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  module Core
    # methods for (re)building Jacinthe database
    module ResetDb
      DB_SOURCE_DIR = File.join(SMF_SERVEUR,
                                'Jacinthe', 'Tools', 'Library', 'JacintheDatabase')
      SQL_MODULE_DIR = File.join(DB_SOURCE_DIR, 'Modules')

      # build database, with schema, tables, views, libraries...
      def self.reset_without_data
        Sql.reset_loaded_files_list
        reset_db_schema
        reset_db_post
      end

      # build database, with everything, including dumped data
      def self.reset_and_load_data
        Sql.reset_loaded_files_list
        reset_db_schema
        puts "Loading #{JACINTHE_DATABASE} db data..."
        Data.import_data
        puts 'Loading drupal db data...'
        Drupal.import_drupal
        reset_db_post
      end

      # build database, with schema and tables
      def self.reset_db_schema
        puts 'SCHEMA'
        recreate_database(JACINTHE_DATABASE)
        create_tables
        puts 'MODULES'
        load_tables_in_modules
      end

      # drop and recreate databose
      # @param [STRING] database name of base to recreate
      def self.recreate_database(database)
        puts "Drop db #{database}"
        Sql.query(ROOT_MODE, "drop database #{database}")
        puts "Create db #{database}"
        qry = "CREATE DATABASE #{database} " \
            'CHARACTER SET utf8 COLLATE utf8_general_ci;'
        Sql.query(ROOT_MODE, qry)
      end

      # load main tables
      def self.create_tables
        puts "Creating tables of #{JACINTHE_DATABASE} db"
        Sql.pipe_files_in_directory(JACINTHE_MODE, DB_SOURCE_DIR,
                                    'Database/Tables/**/*.sql')
      end

      # load tables in modules
      def self.load_tables_in_modules
        Sql.pipe_files_in_directory(JACINTHE_MODE, SQL_MODULE_DIR, '*/Tables/**/*.sql')
      end

      # load libraries and views
      def self.reset_db_post
        load_db_lib
        load_db_modules
        start_cron
      end

      # start sql cron
      def self.start_cron
        puts "Run cron on #{JACINTHE_DATABASE} db"
        Sql.query(JACINTHE_MODE, 'CALL CRON();')
      end

      # load main libraries and views
      def self.load_db_lib
        puts 'Loading libraries'
        Sql.pipe_files_in_directory(JACINTHE_MODE, DB_SOURCE_DIR, 'Database/Library/*/*.sql')
        puts 'Loading views'
        Sql.pipe_files_in_directory(JACINTHE_MODE, DB_SOURCE_DIR, 'Database/Views/*.sql')
      end

      # load library and views in modules
      def self.load_db_modules
        puts 'Loading modules'
        Sql.pipe_files_in_directory(JACINTHE_MODE, SQL_MODULE_DIR, '**/*.sql', /Views/)
        Sql.pipe_files_in_directory(JACINTHE_MODE, SQL_MODULE_DIR, '**/Views/*.sql')
        puts 'Reloading /Sage/export_client_sage.sql with special rights'
        Dir.chdir(File.join(SQL_MODULE_DIR, 'Sage'))
        Sql.pipe_sql_file(JACINTHE_ROOT_MODE, 'export_client_sage.sql')
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__

  include JacintheManagement
  JacintheManagement::ResetDb.reset_and_load_data

end
