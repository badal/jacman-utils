#!/usr/bin/env ruby
# encoding: utf-8

# File: commands_electronic.rb
# Created: 18/08/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Core
    # command : interface between scripts and GUI
    class Command
      EPA_HELP = <<END_EPA_HELP
Cette commande permet de transmettre à smf4 les plages ip valides.

Elle utilise le fichier 'abo_elec.csv' rangé dabs le dossier
#{DATADIR}.
END_EPA_HELP

      # @return [Command] export subscriptions to smf4
      def self.ea
        new('ea', 'Exporter les abonnements',
            ['Envoyer au serveur smf4',
             'les abonnements électroniques'],
            -> { Electronic.push_abo_elec_to_smf4server },
            EPA_HELP)
      end

      EPR_HELP = <<END_EPR_HELP
Cette commande permet de transmettre à smf4 les plages ip valides.

Elle utilise le fichier 'plage_ip_valid_csv' rangé dabs le dossier
#{DATADIR}.
END_EPR_HELP

      # @return [Command] import ip ranges to smf4
      def self.ep
        new('ep', 'Exporter les plages ip',
            ['Envoyer au serveur smf4',
             'les plages IP valides'],
            -> { Electronic.push_ip_to_smf4server },
            EPR_HELP)
      end
    end
  end
end
