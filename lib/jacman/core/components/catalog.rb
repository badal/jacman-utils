#!/usr/bin/env ruby
# encoding: utf-8

# File: catalog.rb
# Created: 27/07/13
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  module Core
    # Catalogue methods
    module Catalog
      ### exportation
      # sql command for catalog exporting
      EXPORT_SQL = SqlScriptFile.new('catalog_export').script

      # export catalogue to file +catalogue.csv+
      def self.export_catalogue
        dump_file = File.join(DATADIR, 'catalogue.csv')
        puts "Dumping catalog data into file #{dump_file}"
        lines = Sql.answer_to_query(CATALOG_MODE, EXPORT_SQL)
        File.open(dump_file, 'w') do |file|
          # TODO: here encode if necessary # .encode(Encoding.default_external) }
          lines.each { |line| file.puts line.force_encoding('utf-8') }
        end
      end

      ### importation of articles, nomenclature, tariffs

      # importer for articles, nomenclature and tariffs
      class CatalogImporter
        # @param [String] subdirectory path of subdir of TRANSFERT dir
        # @param [String] initial_file file to fetch from Aspaway
        # @param [String] converted_file converted file
        # @param [String] sql_fragment sql fragment for DB importation
        # @param [Symbon] conversion WinFile method to use
        def initialize(subdirectory, initial_file, converted_file, sql_fragment, conversion)
          @initial_path = File.join('Catalogue', subdirectory, initial_file)
          @full_initial_path = File.join(TRANSFERT_DIR, @initial_path)
          @full_converted_path = File.join(TRANSFERT_DIR, 'Catalogue',
                                           subdirectory, converted_file)
          @sql_fragment = sql_fragment
          @conversion = conversion
        end

        # fetch initial from Aspaway
        def fetch
          AspawayImporter.fetch(@initial_path)
        end

        # convert initial to converted
        def convert
          WinFile.send(@conversion, @full_initial_path, @full_converted_path)
        end

        # extract from converted and inject in DB
        def load
          Sql.extract_file_and_load(@full_converted_path,
                                    CATALOG_MODE, KN_REGEXP, @sql_fragment)
        end

        # fetch, convert and inject
        def import
          fetch
          convert
          load
        end
      end

      ## sql fragments

      # sql fragment for articles
      ARTICLE_SQL = SqlScriptFile.new('catalog_article').script

      # sql fragment for nomenclature
      NOMENCLATURE_SQL = SqlScriptFile.new('catalog_nomenclature').script

      # sql fragment for tariff
      TARIFF_SQL = SqlScriptFile.new('catalog_tariff').script

      # Regexp to select lines
      KN_REGEXP = /^(K|N)/

      # import in catalog DB articles from Sage
      def self.import_articles
        CatalogImporter.new('Articles', 'Articles.slk', 'Articles.csv',
                            ARTICLE_SQL, :convert_from_sylk)
          .import
      end

      # import in catalog DB nomenclature from Sage
      def self.import_nomenclature
        CatalogImporter.new('Nomenclatures', 'Nomenclatures.slk', 'Nomenclatures.csv',
                            NOMENCLATURE_SQL, :convert_from_sylk)
          .import
      end

      # import in catalog DB tariffs from Sage
      def self.import_tariffs
        CatalogImporter.new('Tarifs', 'Tarifs.csv', 'Tarifs-utf8.csv',
                            TARIFF_SQL, :convert_to_unicode)
          .import
      end

      ### importation of stock

      # transfer directory for stock
      TRANSFERT_STOCK_DIR = File.join(TRANSFERT_DIR, 'Catalogue', 'Stock')

      # sql fragment for stock
      STOCK_SQL = SqlScriptFile.new('catalog_tariff').script

      # Regexp to select lines and extract catalog data
      CAT_REGEXP = /^(?<item>N\w*)\t+(?<qty>\d*).*/

      # import in catalog DB stocks from Sage
      def self.import_stock
        csv_file = build_stock_csv_file
        Sql.extract_file_and_load(csv_file, CATALOG_MODE, CAT_REGEXP, STOCK_SQL) do |mtch|
          "#{mtch[:item]}\t#{mtch[:qty]}"
        end
      end

      # build Stock csv file by extracting lines from Stock txt file
      def self.build_stock_csv_file
        AspawayImporter.fetch('Catalogue/Stock/Stock.txt')
        puts 'Building Stock utf-8 file'
        txt_file = File.join(TRANSFERT_STOCK_DIR, 'Stock.txt')
        utf8_file = File.join(TRANSFERT_STOCK_DIR, 'Stock_utf8.txt')
        WinFile.convert_to_unicode(txt_file, utf8_file)
        puts 'Building Stock csv file'
        csv_file = File.join(TRANSFERT_STOCK_DIR, 'Stock.csv')
        Utils.extract_lines(utf8_file, csv_file, /\b{3}/)
        csv_file
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__

  include JacintheManagement
  Core::Catalog.import_articles

end
