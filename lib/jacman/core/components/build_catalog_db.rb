#!/usr/bin/env ruby
# encoding: utf-8
#
# File: build_catalog_db.rb
# Created: 23/12/13
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  module Core
    # methods for (re)building the catalog database
    module ResetCatalog
      CATALOG_SQL_DIR = File.join(SMF_SERVEUR, 'Catalogue', 'Library', 'CatalogueDatabase')

      # build catalog database, with schema, tables, views
      def self.build_base
        Sql.reset_loaded_files_list
        reset_db_schema
        reset_db_post
      end

      # build database, with schema and tables
      def self.reset_db_schema
        puts 'SCHEMA'
        ResteDb.recreate_database(CATALOG_DATABASE)
        create_tables
      end

      # load main tables
      def self.create_tables
        puts "Creating tables of #{CATALOG_DATABASE} db"
        Sql.pipe_files_in_directory(CATALOG_MODE, CATALOG_SQL_DIR, 'Tables/*.sql')
      end

      # load libraries and views
      def self.reset_db_post
        load_db_lib
      end

      # load main libraries and views
      def self.load_db_lib
        puts 'Loading libraries'
        Sql.pipe_files_in_directory(CATALOG_MODE, CATALOG_SQL_DIR,
                                    'Users/*.sql')
        puts 'Loading views'
        Sql.pipe_files_in_directory(CATALOG_MODE, CATALOG_SQL_DIR,
                                    'Views/create_views.sql')
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__

  include JacintheManagement::Core
  JacintheManagement::Core::ResetCatalog.build_base

end
