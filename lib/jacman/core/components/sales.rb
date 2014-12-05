#!/usr/bin/env ruby
# encoding: utf-8

# File: sales.rb
# Created: 6/10/13 from sage.rb created 24/07/13
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  module Core
    # methods to import sales from Sage (Gescom)
    module Sales
      # import in JacintheD sales extracted from Sage
      def self.import_sales
        fetch_aspaway_file
        build_global_csv_file
        run_patch
        extract_and_load_csv_files
        inject_in_database
        check_remaining_sales
      end

      # Transfer directory for Sage sales
      TRANSFERT_DOC_VENTE_DIR = File.join(TRANSFERT_DIR, 'DocVente')

      # File for not imported sales
      REMAINING_SALES_FILE = File.join(TRANSFERT_DOC_VENTE_DIR, 'ventes_non_importees.txt')

      # slk sales file
      VENTES_SLK = File.join(TRANSFERT_DOC_VENTE_DIR, 'Ventes.slk')

      # CSV format of Sage sales data
      VENTES_CSV = File.join(TRANSFERT_DOC_VENTE_DIR, 'Ventes.csv')

      # sql fragment to import document
      DOCUMENT_SQL = SqlScriptFile.new('import_document').script

      # sql command to list non imported sales
      SHOW_SQL = SqlScriptFile.new('show_non_imported').script

      # FIXME: SMELL: constant coupling
      # fetch SYLK file from smf-2
      def self.fetch_aspaway_file
        AspawayImporter.new('DocVente/Ventes.slk').fetch
      end

      # convert Sylk sales file to CSV
      def self.build_global_csv_file
        puts "Generating #{VENTES_CSV} from #{VENTES_SLK}"
        WinFile.convert_from_sylk(VENTES_SLK, VENTES_CSV)
      end

      # PATCH to fix wrong article name
      def self.run_patch
        lines = File.readlines(VENTES_CSV, encoding: 'utf-8')
        lines.each do |line|
          line.sub!(/NCTEXASI/, 'NVAU0099')
          line.sub!(/KCTEXASI/, 'KCAU0099')
        end
        File.open(VENTES_CSV, 'w:utf-8') do |file|
          lines.each { |line| file.puts(line) }
        end
      end

      # Extract and load three extracted files
      def self.extract_and_load_csv_files
        # Traitement Abonnement, Adhesion_locale, Adhesion_tierce :
        #   ils commencent tous par NC, NE, NP
        extract_and_load(/^N(C|E|P)/, 'abo_adh')
        # Traitement dons : ils commencent tous par KD
        extract_and_load(/^KD/, 'Don')
        # Traitement monographies : ils commencent tous par NV
        extract_and_load(/^NV/, 'Monographie')
      end

      # Extract sales according to 'regexp', write them to 'filename',
      #    and load them in JacintheD
      # @param [Regexp] regexp regexp to select lines
      # @param [String] filename name of filtered file
      def self.extract_and_load(regexp, filename)
        in_file = VENTES_CSV
        out_file = File.join(TRANSFERT_DOC_VENTE_DIR, "#{filename}-#{Utils.my_date}.csv")
        Sql.filter_and_load(in_file, out_file, JACINTHE_MODE, regexp, DOCUMENT_SQL)
        Utils.archive(TRANSFERT_DOC_VENTE_DIR, out_file)
        File.delete(out_file)
      end

      # call SQL command 'import sage document'
      def self.inject_in_database
        puts "Launch import_sage_document() in DB #{JACINTHE_DATABASE}"
        command = 'call import_sage_document();'
        Sql.query(JACINTHE_MODE, command)
      end

      # report non imported sales lines
      # find non imported lines
      def self.check_remaining_sales
        sales = remaining_sales
        size = sales.size
        if size > 0
          write_remaining_sales_file(sales)
          puts "<b>#{size} vente(s) non importée(s)</b>"
          puts sales
        end
      end

      # @return [Array<String>] lines reporting non imported sales
      def self.remaining_sales
        lines = Sql.answer_to_query(JACINTHE_MODE, SHOW_SQL)
        lines.each_slice(4).map do |slice|
          slice[1..-1].map(&:chomp).join(', ')
        end
      end

      # @return [Integer] number of remaining sales
      def self.remaining_sales_number
        lines = Sql.answer_to_query(JACINTHE_MODE, SHOW_SQL)
        lines.size / 4
      end

      # build file with non imported sales
      # @param [Array<String>] sales description of non imported sales
      # @return [Path] path of file
      def self.write_remaining_sales_file(sales)
        File.open(REMAINING_SALES_FILE, 'w:utf-8') do |file|
          sales.each { |sale| file.puts sale }
        end
      end

      # show remaining sales in editor
      def self.show_remaining_sales
        JacintheManagement::Utils.open_in_editor(REMAINING_SALES_FILE)
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME

  require_relative('../../../lib/my_config.rb')
  require_relative('../../../lib/jacman/core.rb')
  include JacintheManagement
  puts Sales.remaining sales

end
