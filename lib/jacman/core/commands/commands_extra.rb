#!/usr/bin/env ruby
# encoding: utf-8

# File: commands_extra.rb
# Created: 31/08/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Core
    # command : interface between scripts and GUI
    class Command
      TB_HELP = <<END_TB_HELP
Cette commande permet de produire et d'envoyer le tableau de bord
à la liste des destinataires donnée dans le fichier de configuration.

Le tableau de bord construit est enregistré dans le dossier
#{File.join(DATADIR, 'Archives')}.
END_TB_HELP

      # @return [Command] produce and send the executive report
      def self.tb
        new('tb', 'Envoyer le tableau de bord',
            ['Construire le tableau de bord',
             'du jour et l\'envoyer aux',
             'destinataires fixés'],
            -> { Report.mail_dashboard },
            TB_HELP)
      end
    end
  end
end
