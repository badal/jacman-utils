-- requete de recuperation des abonnement a notifier
--
-- returns :
-- identifiant interne à la SMF de l'abonnement
-- le nom de la revue
-- l'année d'abonnement souscrit
-- la reference de la commande cote cote client
-- le numéro de la facture cote SMF
-- l'identifiant du tiers ayant souscrit
--
-- NB : un client ayant resouscrit deux années successives donne lieu à deux lignes
-- distinctes
--


SELECT
  abonnement_id,
  revue_nom,
  abonnement_annee,
  abonnement_reference_commande,
  abonnement_facture,
  tiers_id
FROM
  abonnement
  LEFT JOIN type_abonnement ON abonnement_type = type_abonnement_id
  LEFT JOIN client_sage ON abonnement_client_sage = client_sage_id
  LEFT JOIN tiers ON client_sage_client_final = tiers_id
  LEFT JOIN revue ON abonnement_revue = revue_id
WHERE
  type_abonnement_code = 'E'
  AND abonnement_ignorer = 0
  AND abonnement_ip_a_notifier = 1
  AND abonnement_annee >= YEAR(NOW());
