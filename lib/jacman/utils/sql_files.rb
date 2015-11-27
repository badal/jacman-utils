#!/usr/bin/env ruby
# encoding: utf-8
#
# File: sql_files.rb
# Created: 01 January 2015
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  # managing sql source files
  module SQLFiles
    # keys ()and french denominations) of json file (except TYPES)

    KEYS = {
      object: 'Objet :',
      security: 'Risques :',
      return_type: 'Type de la réponse :',
      return: 'Contenu de la réponse :',
      token: 'Jeton :',
      remark: 'Remarque :',
      used_in_gem: 'Utilisé dans le gem :',
      used_in_file: 'Utilisé dans le fichier :',
      used_in_method: 'Utilisé dans la méthode :'
    }

    # possible values of type
    TYPES = %w(Inconnu Requête Commande Fragment)

    # pattern for comments and empty lines
    SQL_SCRIPT_IGNORE_PATTERN = /^--|^\s*$/

    # @param [Array<String>] content content of a SQL source file
    # @return [String] query cleaned from comments, empty lines  and extra spaces
    def self.clean(content)
      content.lines
        .reject { |line| /^--/.match(line) }
        .map(&:chomp)
        .join(' ')
        .gsub(/\s+/, ' ')
    end

    # @param [String] name basename of file (without .sql)
    # @return [String] SQL query from file
    def self.script(name)
      Source.new(name).script
    end

    # SQl source files
    class Source
      # @return [Array] base_names (without .sql) of all script files
      def self.all
        Dir.glob(Core::SQL_SCRIPT_DIR + '/**/*.sql').map do |path|
          File.basename(path, '.sql')
        end
      end

      attr_reader :name, :content

      # @param [String] name basename of file (without .sql)
      def initialize(name)
        @name = name
        @path = Dir.glob(Core::SQL_SCRIPT_DIR + "/**/#{name}.sql").first
        @content = File.read(@path, encoding: 'utf-8')
        @json_file = @path.sub('.sql', '.json')
        @info = nil
      end

      # @return [String] SQL query extracted from file
      def script
        SQLFiles.clean(@content)
      end

      # fetch and cache file infos
      # @return [Hash] infos on file
      def info
        @info ||= fetch_json_info
      end

      # @return [Integer] index of type value
      def type_index
        TYPES.index(info[:type]) || 0
      end

      # @return [Bool] whether type is 'requete' or 'commande'
      def executable?
        info[:type] == TYPES[1] || info[:type] == TYPES[2]
      end

      # @return [Bool] whether type is 'requete'
      def query?
        info[:type] == TYPES[1]
      end

      # save new values and modify cache
      # @param [Hash] new_info updated info values
      # @return [Hash] updated info values
      def save_json_info(new_info)
        File.open(@json_file, 'w:utf-8') do |file|
          file.puts(new_info.to_json)
        end
        @info = new_info
      end

      # fetch file infos from JSON file
      # @return [Hash] infos on file
      def fetch_json_info
        return {} unless File.exist?(@json_file)
        content = File.read(@json_file, encoding: 'utf-8')
        JSON.parse(content, symbolize_names: true)
      end
    end
  end
end
