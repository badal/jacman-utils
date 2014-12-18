#!/usr/bin/env ruby
# encoding: utf-8

# File: config.rb
# Created: 11/05/2014
#
# (c) Michel Demazure <michel@demazure.com>

require 'yaml'

# reopening core class
class Hash
  # symbolize keys
  # @return [Hash] new Hash with symbolized keys
  def symbolize
    {}.tap do |hsh|
      each_pair do |key, value|
        hsh[key.to_sym] = value
      end
    end
  end
end

module JacintheManagement
  # path of configuration yaml file
  CONFIG_FILE = ENV['JACMAN_CONFIG']
  fail "Le fichier de configuration n'existe pas" unless CONFIG_FILE

  # configuration methods
  # Conf methods are only used only in utils.rb
  #    to build JacintheManagement::Core constants
  module Conf
    # fetch and cache configuration
    # @return [Hash] configuration hash
    def self.config
      @config ||= fetch_config
    end

    # @return [Hash] configuration hash
    def self.fetch_config
      Psych.load_file(CONFIG_FILE)
    end

    # @return [Hash] mysql part of configuration
    def self.mysql
      config['mysql']
    end

    # @return [Hash] admin sql connection mode
    def self.admin_mode
      mysql['admin'].symbolize
    end

    # @return [Hash] root sql connection mode
    def self.root_mode
      mysql['root'].symbolize
    end

    # @return [Hash] mailer configuration
    def self.mail_mode
      config['mail'].symbolize
    end
  end
end
