#!/usr/bin/env ruby
# encoding: utf-8

# File: log.rb
# Created: 25/08/13
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  # Open a logger
  # @param [String] name of log file
  def self.open_log(name = 'jacman.log')
    Dir.chdir(Core::DATADIR)
    log_dir = File.join(Core::DATADIR, 'jacman_logs')
    Utils.make_dir_if_necessary(log_dir, 0773)
    log_file = File.expand_path(name, log_dir)
    @logger = Logger.new(log_file, 'monthly')
    @logger.level = Logger::INFO
  end

  # Log the text (cleaned from HTML decoration)
  # @param [String] text to be logged
  def self.log(text)
    log_text = text.gsub(/<[^>]*>/, '').sub(/-+ /, '--').force_encoding('utf-8')
    @logger.info { log_text } unless log_text.empty?
  end

  # Log the erro message and backtrace
  # @param [Exception] error
  def self.err(error)
    @logger.error(error.message)
    @logger.error(error.backtrace.join("\n"))
  end
end
