#!/usr/bin/env ruby
# encoding: utf-8

# File: commands_drupal.rb
# Created: 18/08/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Core
    # command : interface between scripts and GUI
    class Command
      DID_HELP = <<END_DID_HELP
Cette commande permet de fournir à Jacinthe
les renseignements sur les tiers, récupérés sur le
serveur smf.

Ils sont obtenus par connexion au serveur Drupal.
END_DID_HELP

      # @return [Command] import from drupal (smf)
      def self.di
        new('di', 'Importer depuis drupal',
            ['Importer dans Jacinthe',
             'les données contenues',
             'dans le serveur smf'],
            -> { Drupal.import_drupal },
            DID_HELP)
      end

      DED_HELP = <<END_DED_HELP
Cette commande permet de fournir au serveur smf
les renseignements extraits de Jacinthe.

Il sont transmis par connexion au serveur Drupal.

La liste des fichiers transmis est enregistrée
dans le fichier #{Drupal::DUMP_FILES_STACK}.
END_DED_HELP

      # @return [Command] export to drupal (smf)
      def self.de
        new('de', 'Exporter vers drupal',
            ['Transférer les données',
             'depuis JacintheD',
             'vers le serveur smf'],
            -> { Drupal.export_drupal },
            DED_HELP)
      end
    end
  end
end
