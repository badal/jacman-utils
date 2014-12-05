#!/usr/bin/env ruby
# encoding: utf-8

# File: data.rb
# Created: 24/07/13
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  module Core
    # import and export of JacintheD data
    module Data
      # tables category
      # main JacintheD tables
      SETTINGS_TABLES = "\
beneficiaire_don \
categorie_comptable \
champs_tiers_extras \
civilite \
compte_collectif \
etat_adresse \
etat_routage \
etat_tiers \
fascicule \
pays \
revue \
societe_tierce \
type_abonnement \
type_particularite \
type_rapport \
type_tiers \
usage_adresse \
zone_poste_pays \
zone_statistique_pays \
      "
      # other JacintheD tables
      OTHER_TABLES = "\
abonnement \
adhesion_locale \
adhesion_tierce \
adresse \
client_sage \
don \
livraison \
particularite \
rapport \
routage \
sage_document \
tiers \
tiers_extras \
achat_divers \
      "

      # copy file to archive directory
      # @param [Path] filename name of file to be archived
      # @param [Object] add txt to add to file name
      def self.backup_sql_dump_file(filename, add = 'previous')
        if File.exist?(filename)
          basename = File.basename(filename, '.sql')
          archive_dir = File.join(DATADIR, 'Archives')
          Utils.make_dir_if_necessary(archive_dir, 0773)
          archive = File.join(archive_dir, "#{basename}-#{add}.sql")
          FileUtils.copy(filename, archive)
        end
      end

      # dump settings tables to 'dumped_settings.sql'
      def self.dump_settings_tables
        tables = SETTINGS_TABLES
        dump_file = File.join(DATADIR, 'dumped_settings.sql')
        do_dump(tables, dump_file)
      end

      # dump all tables to 'dumped_data.sql'
      def self.dump_all_data
        tables = SETTINGS_TABLES + ' ' + OTHER_TABLES
        dump_file = File.join(DATADIR, 'dumped_data.sql')
        do_dump(tables, dump_file)
      end

      # dump given tables in given file
      # @param [String] tables list of tables, separated by spaces
      # @param [Path] dump_file file to write the dump
      def self.do_dump(tables, dump_file)
        backup_sql_dump_file(dump_file)
        puts 'Dumping database data'
        lines = dumped(tables)
        File.open(dump_file, 'w') { |file| file.puts lines }
        if File.exist?(dump_file)
          puts "File #{dump_file}"
          puts "File size: #{(File.size(dump_file) / 1024).round} K"
          backup_sql_dump_file(dump_file, Utils.my_date)
        end
      end

      # @param [String] tables list of tables, separated by spaces
      # @return [Array<String>] dump of these tables
      def self.dumped(tables)
        raw_dump = Sql.dump(JACINTHE_ROOT_MODE, tables)
        raw_dump.reject { |line| line =~ /^\/\*/ }.map do |line|
          line.sub('INSERT INTO', 'REPLACE INTO')
        end
      end

      #  import dumped data from 'dumped_data.sql'
      def self.import_data
        puts "loading #{DATADIR}/dumped_data.sql in #{JACINTHE_DATABASE} DB"
        Dir.chdir(DATADIR)
        queries = ['SET foreign_key_checks = 0',
                   "source #{DATADIR}/dumped_data.sql",
                   'SET foreign_key_checks = 1;']
        Sql.query(JACINTHE_MODE, queries.join('; '))
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__

  include JacintheManagement
  # JacintheManagement::Data.import_data

end
