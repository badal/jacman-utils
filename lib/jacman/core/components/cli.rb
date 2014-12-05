#!/usr/bin/env ruby
# encoding: utf-8

# File: cli.rb
# Created: 29/08/13, modified for 'info' 9/12/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Core
    # to execute commands without GUI
    class Cli
      # commands for batman
      USER_COMMAND_NAMES = %w(gi ge gr di de ca cn ca cs ce ep ea en ei tb)

      # commands for jacdev
      DEV_COMMAND_NAMES = %w(jpd jtd jpr jtr cron crb)

      # name of defaults configuration subcommand
      CONFIG_CMD_NAME = 'conf'

      # start a User Manager
      def self.user
        commands = USER_COMMAND_NAMES.map { |name| Command.send(name) }
        new(commands)
      end

      # start a Developer Manager
      def self.developer
        commands = DEV_COMMAND_NAMES.map { |name| Command.send(name) }
        new(commands)
      end

      # @param [Array<Command>] commands commands covered
      def initialize(commands)
        @commands = commands
      end

      # Execute command if known, else call 'simple_command'
      # @param [String] call_name call name of command
      def execute(call_name)
        command = Command.send(call_name)
        puts "executing '#{command.title}'"
        command.execute
        puts 'end of execution'
      rescue NoMethodError
        puts simple_command(call_name)
      end

      # @return [String] global help text
      def help_text
        @help_text ||=
            (['Liste des commandes disponibles :', '',
              '<vide> ou <erreur> : cette réponse',
              'help               : cette réponse',
              'help <commande>    : aide sur <commande>', ''] +
                @commands.map do |command|
                  "#{command.call_name} : #{command.long_title.join(' ')}"
                end +
                ['', 'info : Opérations pendantes',
                 "#{CONFIG_CMD_NAME} : Configuration du manageur",
                 'vers : versions des composantes'])
      end

      # @param [String] cmd call name of command
      # @return [String] help text for command
      def help_for(cmd)
        if  @commands.map(&:call_name).include?(cmd)
          command = Command.send(cmd)
          "Commande : #{command.title}\n#{command.help_text}"
        else
          puts simple_command(cmd)
        end
      end

      # @return [Array<String>] versions of the three base gems
      def versions
        ["j2r-jaccess : #{J2R::Jaccess::VERSION}",
         "j2r-core    : #{J2R::Core::VERSION}",
         "jacman-core : #{JacintheManagement::Core::VERSION}"]
      end

      # @param [String] cmd command
      # @return [String] answer for this command
      def simple_command(cmd)
        case cmd
        when CONFIG_CMD_NAME
          Defaults.help_conf
        when 'info'
          Info.report.join("\n")
        when 'help'
          help_text.join("\n")
        when 'vers'
          versions.join("\n")
        else
          unknown_command(cmd)
        end
      end

      # @param [String] cmd call name not recognized
      # @return [String] help text
      def unknown_command(cmd)
        "Commande inconnue : #{cmd}\n\n#{help_text.join("\n")}"
      end

      # process the call
      # @param [Array<String>] args call arguments
      def run(args)
        size = args.size
        first_arg = args.shift
        case
        when size == 1
          execute(first_arg)
        when size == 2 && first_arg == 'help'
          puts help_for(args.first)
        when size >= 2 && first_arg == CONFIG_CMD_NAME
          Defaults.configure(args)
        else
          puts help_text
        end
      end
    end
  end
end
