#!/usr/bin/env ruby
# encoding: utf-8

# File: command_watcher.rb
# Created: 23/09/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Core
    # methods for checking cronman report files
    class CommandWatcher
      # For use in command line or in web_service
      #
      # @example ruby command_watcher.rb gi,ge,de
      # @param [Array<String>] cmds list of call_name of command
      # @param [Numeric] limit limit time for LATE (in hours)
      # @return [String] report for command
      def self.report(cmds, limit = 24)
        cmds.map do |cmd|
          new(cmd).check_command(limit)
        end
      end

      # @param [String] cmd call_name of command
      def initialize(cmd)
        @command = Command.fetch(cmd)
        @stdout_file = @command.stdout_file
        @stderr_file = @command.stderr_file
      end

      # @return [[nil|Integer, nil|String]] age to report, file to show
      def check_files
        stdout_age = Utils.age(@stdout_file)
        stderr_age = Utils.age(@stderr_file)
        if stderr_age && stderr_age < (stdout_age || 0) + 0.1
          [nil, @stderr_file]
        else
          [stdout_age, stdout_age ? @stdout_file : nil]
        end
      end

      # @param [Numeric] limit limit time for LATE (in hours)
      # @return [Array] category, [file], [age]
      def check_command(limit = 24)
        age, file = check_files
        if age && age < limit
          [:OK, file, age.to_i]
        elsif age
          [:LATE, file, age.to_i]
        elsif file
          [:ERROR, file]
        else
          [:NEVER]
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME

  # TODO: fix !
  require '../manager_commands.rb'
  include JacintheManagement
  CommandWatcher.report ARGV

end
