#!/usr/bin/env ruby
# encoding: utf-8

# File: commands_data.rb
# Created: 18/08/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Core
    # command : interface between scripts and GUI
    class Command
      JED_HELP = <<END_JED_HELP
Cette commande permet de faire un dump total
du schéma, des données de configuration et
du contenu de la base Jacinthe.

Ce dump est contenu dans le fichier 'dumped_data.sql'
du dossier #{DATADIR}.

Le dump précédent est sauvegardé dans le dossier
#{File.join(DATADIR, 'Archives')}
END_JED_HELP

      # @return [Command] total dump command
      def self.jtd
        new('jtd', 'Dump total des données',
            ['Ecrire dans un fichier le schéma,',
             'la configuration et toutes les données',
             'de la base JacintheD'],
            -> { Data.dump_all_data },
            JED_HELP)
      end

      JES_HELP = <<END_JES_HELP
Cette commande permet de faire un dump
du schéma et des données de configuration
de la base Jacinthe.

Ce dump est contenu dans le fichier 'dumped_settings.sql'
du dossier #{DATADIR}.

Le dump précédent est sauvegardé dans le dossier
#{File.join(DATADIR, 'Archives')}
END_JES_HELP

      # @return [Command] partial dump command
      def self.jpd
        new('jpd', 'Dump partiel des données',
            ['Ecrire dans un fichier le schéma',
             'et les données de configuration',
             'de la base JacintheD'],
            -> { Data.dump_settings_tables },
            JES_HELP)
      end
    end
  end
end
