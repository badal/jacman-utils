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
      # transfer top directory for catalog
      TRANSFERT_CATALOGUE_DIR = File.join(TRANSFERT_DIR, 'Catalogue')
      # transfer directory for articles
      TRANSFERT_ARTICLE_DIR = File.join(TRANSFERT_CATALOGUE_DIR, 'Articles')
      # transfer directory for nomenclature
      TRANSFERT_NOMENCLATURE_DIR = File.join(TRANSFERT_CATALOGUE_DIR, 'Nomenclatures')
      # transfer directory for tariffs
      TRANSFERT_TARIFF_DIR = File.join(TRANSFERT_CATALOGUE_DIR, 'Tarifs')
      # transfer directory for stocks
      TRANSFERT_STOCK_DIR = File.join(TRANSFERT_CATALOGUE_DIR, 'Stocks')

      CE_HELP = <<END_CE_HELP
Cette commande permet d'extraire de Jacinthe
de quoi fabriquer le catalogue.

Les renseignements extraits sont enregistrés dans le fichier 'catalog.csv'
qui se trouve dans le dossier #{DATADIR}.
END_CE_HELP

      # @return [Command] catalog export
      def self.ce
        new('ce', 'Exporter le catalogue',
            ['Récupérer dans un fichier',
             'les éléments du catalogue',
             'extraits de Jacinthe'],
            -> { Catalog.export_catalogue },
            CE_HELP)
      end

      CIA_HELP = <<END_CIA_HELP
Cette commande permet de fournir à Jacinthe la liste des articles.

Cette liste est fournie par le fichier ' articles.slk '
produit par GESCOM, qui se trouve dans le dossier
#{TRANSFERT_ARTICLE_DIR}.
END_CIA_HELP

      # @return [Command] catalog import articles
      def self.ca
        new('ca', 'Importer les articles',
            ['Importer dans Jacinthe',
             'la liste des articles',
             'fournie par Gescom'],
            -> { Catalog.import_articles },
            CIA_HELP)
      end

      CIN_HELP = <<END_CIN_HELP
Cette commande permet de fournir à Jacinthe la nomenclature.

Cette liste est fournie par le fichier ' Nomenclatures.slk '
produit par GESCOM, qui se trouve dans le dossier
#{TRANSFERT_NOMENCLATURE_DIR}.
END_CIN_HELP

      # @return [Command] catalog import nomenclature
      def self.cn
        new('cn', 'Importer la nomenclature',
            ['Importer dans Jacinthe',
             'la nomenclature',
             'fournie par Gescom'],
            -> { Catalog.import_nomenclature },
            CIN_HELP)
      end

      CIT_HELP = <<END_CIT_HELP
Cette commande permet de fournir à Jacinthe la liste des tarifs.

Cette liste est fournie par le fichier ' Articles.slk '
produit par GESCOM, qui se trouve dans le dossier
#{TRANSFERT_TARIFF_DIR}.
END_CIT_HELP

      # @return [Command] catalog import tariffs
      def self.ct
        new('ct', 'Importer les tarifs',
            ['Importer dans Jacinthe',
             'la liste des tarifs',
             'fournie par Gescom'],
            -> { Catalog.import_tariffs },
            CIT_HELP)
      end

      CIS_HELP = <<END_CIS_HELP
Cette commande permet de fournir à Jacinthe l' état des stocks.

Cet état est fournie par le fichier 'Stock.txt'
produit par GESCOM, et qui se trouve dans le dossier
#{TRANSFERT_STOCK_DIR}.
END_CIS_HELP

      # @return [Command] catalog import stock
      def self.cs
        new('cs', 'Importer les stocks',
            ['Importer dans Jacinthe',
             'l\'état des stocks',
             'fourni par Gescom'],
            -> { Catalog.import_stock },
            CIS_HELP)
      end
    end
  end
end
