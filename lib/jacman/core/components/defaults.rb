#!/usr/bin/env ruby
# encoding: utf-8

# File: defaults.rb
# Created: 01/09/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Core
    # to manage configuration command
    module Defaults
      # defaults file
      FILE = Core::DEFAULTS_FILE

      USAGE = [
        'Commande commune à batman et jacdev. Usage:',
        '<cmd> désigne batman ou jacdev indifféremment.'
      ]

      # @return [Hash] the defaults, memoized
      def self.defaults
        @defaults ||= load_defaults
      end

      # @return [Hash] the defaults, read from the file
      def self.load_defaults
        YAML.load_file(FILE)
      end

      # save the defaults in the file
      def self.save_defaults
        File.open(FILE, 'w:utf-8') do |file|
          file.puts Psych.dump(@defaults)
        end
      end

      # @return [Array<String>] help for 'years' sub-command
      def self.help_years
        ['<cmd> conf years N : nombre d\'années d\'activité à transférer à drupal',
         "                   : actuellement #{defaults[:years]}"]
      end

      # @return [Array<String>] help for 'bonus' sub-command
      def self.help_bonus
        ['<cmd> conf bonus MM-JJ : bonus d\'abonnement électronique l\'année suivante',
         '                       : modèle MM-JJ, exemple 04-01 (premier avril)',
         "                       : actuellement #{defaults[:bonus]}"]
      end

      # @return [Array<String>] help for 'report_from' sub-command
      def self.help_from
        ['<cmd> conf from ADR : adresse de l\'expéditeur des notifications',
         "                    : actuellement #{defaults[:from]}"]
      end

      # @return [Array<String>] help for 'report' sub-command
      def self.help_report
        ['<cmd> conf report ADR[ ADR ...] : adresse(s) d\'envoi du tableau de bord',
         "                                : actuellement #{defaults[:report].join(', ')}"]
      end

      # @return [Array<String>] help for defaults command
      def self.help_conf
        ['Fixe les valeurs des variables de configuration'] + USAGE +
          help_years + help_bonus + help_from + help_report
      end

      # pattern for email addresses
      MAIL_PATTERN = /\w+@.+\..+/

      # Process the defaults command
      # @param [Array<Strings>] args arguments to the defaults command
      def self.configure(args)
        load_defaults
        command = "modify_#{args.shift}_default"
        send(command, args)
      rescue NoMethodError
        puts help_conf
      end

      # process the 'years' sub-command
      # @param [Array<String>] args arguments for the 'years' sub-command
      def self.modify_years_default(args)
        if args.size == 1 && args[0].to_i > 0
          modify_default(:years, args[0].to_i)
        else
          puts USAGE + help_years
        end
      end

      # process the 'bonus' sub-command
      # @param [Array<String>] args arguments for the 'bonus' sub-command
      def self.modify_bonus_default(args)
        if args.size == 1 && valid_bonus(args[0])
          modify_default(:bonus, args[0])
        else
          puts ['Pas de valeur ou valeur invalide. Usage :'] + help_bonus
        end
      end

      # @param [String] val argument of the 'bonus' sub-command
      # @return [Boolean] whether argument is valid
      def self.valid_bonus(val)
        require 'date'
        match_data = /^(\d\d)\-(\d\d)$/.match(val)
        match_data && Date.valid_date?(2001, match_data[1].to_i, match_data[2].to_i)
      end

      # process the 'from' sub-command
      # @param [Array<String>] args arguments for the 'from' sub-command
      def self.modify_from_default(args)
        if args.size == 1 && valid_mail(args[0])
          modify_default(:from, args[0])
        else
          puts USAGE + help_from
        end
      end

      # process the 'report' sub-command
      # @param [Array<String>] list arguments for the 'report' sub-command
      def self.modify_report_default(list)
        if !list.empty? && list.all? { |item| valid_mail(item) }
          modify_default(:report, list)
        else
          puts USAGE + help_report
        end
      end

      # Dialog for confirmation of proposed entry
      # @param [Symbol] key defaults key
      # @param [String] val defaults value
      def self.modify_default(key, val)
        if val == defaults[key]
          puts "même valeur que l'actuelle"
        else
          puts "nouvelle valeur #{val} ; confirmez-vous ? [YyOo]"
          if STDIN.gets =~ /[YyOo]/
            puts "nouvelle valeur #{val}"
            defaults[key] = val
            save_defaults
          else
            puts 'Abandon'
          end
        end
      end

      # @param [String] str argument of the 'report' sub-command
      # @return [Boolean] whether argument is valid
      def self.valid_mail(str)
        match = MAIL_PATTERN.match(str)
        puts "'#{str}' n'a pas l'apparence d'une adresse mail correcte" unless match
        match
      end
    end
  end
end
