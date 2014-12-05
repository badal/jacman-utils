#!/usr/bin/env ruby
# encoding: utf-8

# File: drupal.rb
# Created: 24/07/13
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  module Core
    # Methods to import and export to drupal server
    #   "local" parts are here
    #   "transmission" parts are in transmission.rb
    module Drupal
      ## Exporting

      # Directory for dumping drupal files
      DRUPAL_DUMP_DIR = File.join(SQL_DUMP_DIR, 'Drupal')

      # List of dumped files
      DUMP_FILES_STACK = File.join(DRUPAL_DUMP_DIR, 'DUMPED_FILES.txt')

      # Escaped SQL options for dumping
      ESCAPED_DRUPAL_DUMP_OPTIONS =
          'FIELDS TERMINATED BY "\t" OPTIONALLY ENCLOSED BY \'"\'' \
              ' ESCAPED BY "\\\\\\\\" LINES TERMINATED BY "\n" '

      # Drupal export pattern
      EXPORT_FILES_PATTERN = File.join(Core::SqlScriptFile::SQL_SCRIPT_DIR,
                                       'jacinthe_export_drupal_sql', '*.sql')

      # @return [Integer] default number of years to be exported
      def self.default_years
        Defaults.defaults[:years]
      end

      # Export from JacintheD to drupal
      # @param [Integer] years number of years to be exported
      def self.export_drupal(years = default_years)
        local_export_drupal(years)
        Transmission.push_to_drupal
        # FIXME: here delete files listed in DUMP_FILES_STACK
        # FIXME: or archive them ??? in Data, parallel to importation
      end

      # Export to local files (to be later scp'ed to drupal server)
      # @param [Integer] years number of years to be exported
      def self.local_export_drupal(years)
        Utils.make_dir_if_necessary(DRUPAL_DUMP_DIR, 0733)
        Utils.delete_if_exists(DUMP_FILES_STACK)
        File.open(DUMP_FILES_STACK, 'w:utf-8') do |file_stack|
          Dir.glob(EXPORT_FILES_PATTERN).each do |sql_file|
            dump_file = dump_drupal_file(sql_file, years)
            file_stack.puts dump_file
            puts "#{dump_file} written"
          end
        end
      end

      # Execute the +sql_file+ to build the corresponding '.data' file
      # @param [Integer] years number of years to be exported (default 4)
      # @param [Path] sql_file file containing the sql export command
      # @return [Path] exported file
      def self.dump_drupal_file(sql_file, years)
        model_command = File.readlines(sql_file).map(&:chomp).join(' ')
        dump_file = File.join(DRUPAL_DUMP_DIR, File.basename(sql_file).sub('.sql', '.data'))
        Utils.delete_if_exists(dump_file)
        command = parameterize(model_command, dump_file, years)
        Sql.pipe_command(JACINTHE_ROOT_MODE, command)
        dump_file
      end

      # @param [String] model sql model command
      # @param [String] dump_file name of dump file
      # @param [Integer] years number of years
      # @return [String] actual sql command, with real values substituted
      def self.parameterize(model, dump_file, years)
        model
          .gsub('::DUMP_FILE::', dump_file)
          .gsub('::SQL_DUMP_OPTIONS::', ESCAPED_DRUPAL_DUMP_OPTIONS)
          .gsub('::YEARS::', years.to_s)
      end

      ## Importing

      # SQL options for loading
      DRUPAL_LOAD_OPTIONS =
          'CHARACTER SET UTF8 FIELDS TERMINATED BY "\t"' \
              ' OPTIONALLY ENCLOSED BY \'"\' ESCAPED BY "\\\\"' \
              ' LINES TERMINATED BY "\n" '

      # @param [String] file path of file
      # @param [String] table name of table
      # @return [String] Sql query to import file into table
      def self.import_query(file, table)
        "LOAD DATA LOCAL INFILE '#{file}'" \
            " REPLACE INTO TABLE #{table} " +
          DRUPAL_LOAD_OPTIONS
      end

      # Import in JacintheD from drupal
      def self.import_drupal
        Transmission.fetch_from_drupal if REAL
        local_import_drupal
      end

      # Import in JacintheD the content of the local file 'drupal_account.data'
      def self.local_import_drupal
        puts 'Loading data in Jacinthe'
        table = 'drupal_raw'
        file = File.join(DATADIR, 'Drupal2Jacinthe', 'drupal_account.data')
        Sql.query(JACINTHE_MODE, "TRUNCATE #{table}")
        Sql.pipe_command(JACINTHE_MODE, import_query(file, table))
        res = Sql.answer_to_query(JACINTHE_MODE, "select count(*) nb from #{table}")
        puts "#{res[1].chomp} elements loaded"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__

  include JacintheManagement::Core
  Drupal.local_export_drupal(4)

end
