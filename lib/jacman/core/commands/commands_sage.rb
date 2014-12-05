#!/usr/bin/env ruby
# encoding: utf-8

# File: commands_catalog.rb
# Created: 18/08/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Core
    # command : interface between scripts and GUI
    class Command
      DEC_HELP = <<END_DEC_HELP
Cette commande permet d'extraire de Jacinthe les nouveaux clients
et d'en faire la liste dans un fichier à lire par GESCOM.
Ce fichier daté est transmis à Aspaway et aussi archivé.
END_DEC_HELP

      # @return [Command] export clients to GESCOM
      def self.ge
        new('ge', 'Exporter les clients',
            ['Extraire de JacintheD',
             'la liste des nouveaux clients',
             'et l\'envoyer'],
            -> { Clients.export_client_sage },
            DEC_HELP)
      end

      DIS_HELP = <<END_DIS_HELP
Cette commande permet de fournir à Jacinthe les renseignements
sur les ventes, extraits de GESCOM.

Elle utilise un fichier produit par GESCOM,
intitulé 'Ventes.slk', qu'elle trouve dans le dossier d'importation d'Aspaway.

Les ventes non importées sont recensées, le cas échéant dans le fichier
#{Sales::REMAINING_SALES_FILE}.

END_DIS_HELP

      # @return [Command] import sales from GESCOM
      def self.gi
        new('gi', 'Importer les ventes',
            ['Importer dans Jacinthe',
             'les nouvelles ventes à partir',
             'd\'un fichier reçu d\'Aspaway'],
            -> { Sales.import_sales },
            DIS_HELP)
      end

      DIR_HELP = <<END_DIR_HELP
Cette commande permet d'envoyer à Aspaway
les fichiers clients construits antérieurement
et pour lesquels l'accusé de réception
n'a pas été reçu.
END_DIR_HELP

      # @return [Command] import sales from GESCOM
      def self.gr
        new('gr', 'Ré-exporter clients',
            ['Envoyer à nouveau',
             'les fichiers clients construits',
             'précédemment et non reçus'],
            -> { Clients.resend_pending_files },
            DIR_HELP)
      end
    end
  end
end
