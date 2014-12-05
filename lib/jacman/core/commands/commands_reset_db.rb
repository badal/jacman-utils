#!/usr/bin/env ruby
# encoding: utf-8

# File: commands_reset_db.rb
# Created: 27/08/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Core
    # command : interface between scripts and GUI
    class Command
      RLD_HELP = <<END_RLD_HELP
Cette commande permet de restaurer le schéma
de la base et toutes ses données, en les
reconstruisant à partir du dernier dump.
END_RLD_HELP

      # @return [Command] total reset command
      def self.jtr
        new('jtr', 'Reset total de la base',
            ['Restaurer le schéma de la base',
             'et toutes ses données',
             'à partir du dernier dump total'],
            -> { ResetDb.reset_and_load_data },
            RLD_HELP)
      end

      RWD_HELP = <<END_RWD_HELP
Cette commande permet de restaurer le schéma
de la base et les données de configuration.
END_RWD_HELP

      # @return [Command] partial reset command
      def self.jpr
        new('jpr', 'Reset structurel de la base',
            ['Restaurer le schéma de la base',
             'et ses données de configuration',
             'à partir du dernier dump partiel'],
            -> { ResetDb.reset_without_data },
            RWD_HELP)
      end

      CRON_HELP = <<END_CRON_HELP
Cette commande permet de lancer le cron dans
la base.
END_CRON_HELP

      # @return [Command] start the database cron
      def self.cron
        new('cron', 'Lancement du cron de JacintheD',
            ['Lancement du cron de JacintheD'],
            -> { ResetDb.start_cron },
            CRON_HELP)
      end

      CATA_HELP = <<END_CATA_HELP
Cette commande permet de restaurer le schéma
de la base catalogue et ses données de configuration.
END_CATA_HELP

      # @return [Command] partial reset command
      def self.crb
        new('crb', 'Reset structurel du catalogue',
            ['Recréer de zéro',
             'la base catalogue vide'],
            -> { ResetCatalog.build_base },
            CATA_HELP)
      end
    end
  end
end
