#!/usr/bin/env ruby
# encoding: utf-8

# File: sql.rb
# Created: 21/07/13
# Basic methods. Other moved to sql_tools : 25/9/14
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  # MySql command
  MYSQL = "#{Conf.mysql['command']} --host #{Conf.mysql['host']}"
  # MySQL dump command
  MYSQLDUMP = "#{Conf.mysql['dump_command']} --host #{Conf.mysql['host']}"

  # databases
  JACINTHE_DATABASE = Conf.config['databases']['jacinthe']
  CATALOG_DATABASE = Conf.config['databases']['catalog']
  CLONE_DATABASE = 'clone'

  # connection modes
  ADMIN_MODE = Conf.admin_mode
  JACINTHE_MODE = Conf.admin_mode.merge(database: JACINTHE_DATABASE)
  ROOT_MODE = Conf.root_mode
  JACINTHE_ROOT_MODE = Conf.root_mode.merge(database: JACINTHE_DATABASE)
  CATALOG_MODE = Conf.admin_mode.merge(database: CATALOG_DATABASE)
  CLONE_MODE = Conf.admin_mode.merge(database: CLONE_DATABASE)

  # encapsulating mysql client methods
  module Sql
    # Initial text of all sql commands
    # @raise RuntimeError if wrong mode
    # @param [Hash] mode connecting mode
    # @return [String] system command for this mode
    def self.sql(mode)
      fail 'Wrong mode' unless mode[:user] && mode[:password]
      "#{MYSQL}  -u #{mode[:user]} -p#{mode[:password]} #{mode[:database]}"
    end

    # Send the query to the MySQL client, ignoring the answer
    # @param [Hash] mode connecting mode
    # @param [String] query query to be sent
    def self.query(mode, query)
      system "#{sql(mode)} -e \"#{query}\""
    end

    # send the query to the MySQL client, recovering the answer
    # @param [Hash] mode connecting mode
    # @param [String] query query to be sent
    # @return [Array<String>] answer
    def self.answer_to_query(mode, query)
      open "|#{sql(mode)} -e \"#{query}\"" do |pipe|
        pipe.readlines.map { |line| line.force_encoding('utf-8') }
      end
    end

    # WARNING: 'pipe_command' looks like 'query', but is different !
    #    because of commands for the client (like DELIMITER)
    # Pipe the given command to the MySQL client
    # @param [Hash] mode connecting mode
    # @param [String] command command to be piped
    def self.pipe_command(mode, command)
      open("|#{sql(mode)}", 'w') do |pipe|
        pipe.puts(command)
      end
    end
  end
end
