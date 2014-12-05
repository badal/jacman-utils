#!/usr/bin/env ruby
# encoding: utf-8

# File: command.rb
# Created: 17/08/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Core
    # Command : interface between scripts and GUI
    class Command
      # directory where cron_execute writes his files
      CRON_DIR = File.join(DATADIR, 'Cron')

      # run the named command with cron reports
      # @param [String] call_name name of the command to be 'cron_executed'
      def self.cron_run(call_name)
        fetch(call_name).cron_execute
      end

      # FIXME: add protection and error management
      # fetch the named command
      # @param [String] call_name name of the command
      def self.fetch(call_name)
        send(call_name)
      end

      attr_reader :call_name, :title, :long_title, :proc, :help_text

      # @param [String] title title for GUI
      # @param [Proc] proc proc to execute
      # @param [String] help_text text to show in help dialog
      # @param [String] call_name for batch manager
      def initialize(call_name, title, long_title, proc, help_text)
        @call_name = call_name
        @title = title
        @long_title = Array(long_title)
        @proc = proc
        @help_text = help_text
      end

      # Execute the proc, managing success/failure reporting
      # @return [Boolean] true if success / false if failure
      def execute
        default_proc = -> { puts "commande #{title} non installée" }
        (@proc ||= default_proc).call
        true
      rescue StandardError => err
        puts "<b>---- ERROR : #{err.class}</b>"
        puts err.message
        # WARNING: this for debugging
        STDERR.puts err.message
        STDERR.puts err.backtrace
        false
      end

      # Execute the proc, managing success/error reporting in files
      def cron_execute
        File.open(stdout_file, 'w') do |std|
          $stdout = std
          @proc.call
        end
      rescue StandardError => error
        File.open(stderr_file, 'w') do |err_file|
          err_file.puts [error.class, error.message, error.backtrace]
        end
      ensure
        $stdout = STDOUT
      end

      # @return [Path] file where stdout is written
      def stdout_file
        File.join(CRON_DIR, "stdout_#{@call_name}.txt")
      end

      # @return [Path] file where stderr is written
      def stderr_file
        File.join(CRON_DIR, "stderr_#{@call_name}.txt")
      end
    end
  end
end
