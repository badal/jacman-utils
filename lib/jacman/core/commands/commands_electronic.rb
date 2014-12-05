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

      EPN_HELP = <<END_EPN_HELP
Cette commande permet d'envoyer aux nouveaux abonnés un mail
de confirmation.

Les modèles de mails se trouvent dans des fichiers
'french_model_mail.txt' et 'english_model_mail.txt'.
Ces fichiers se trouvent dans le dossier
#{MODEL_DIR}.

Les abonnés sans adresse mail sont enregstrés dans le fichier
"#{File.join(DATADIR, 'tiers_sans_mail.csv')}".
END_EPN_HELP

      # @return [Command] notification new subscription by mail
      def self.en
        new('en', 'Notifier les abonnements',
            ['Notifier par courriel',
             'aux tiers concernés',
             'leurs abonnements électroniques'],
            -> { Notification.notify_all },
            EPN_HELP)
      end

      ESI_HELP = <<END_ESI_HELP
Cette commande permet d'ouvrir dans un éditeur
la liste des plages ip invalides.
END_ESI_HELP

      # @return [Command] show invalid ip ranges
      def self.ei
        new('ei', 'Plages invalides',
            ['Ouvrir dans un éditeur',
             'la liste des plages invalides'],
            -> { Electronic.show_invalid_ranges },
            ESI_HELP)
      end
    end
  end
end
