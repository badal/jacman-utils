-- requete de plages ip et des emails de notification des tiers valide
--
-- returns :
-- identifiant du tiers
-- son nom
-- son prenom
-- ses plages ip
-- les emails auxquels il faut envoyer la notification
--

SELECT
  tiers_id,
  tiers_nom,
  tiers_prenom,
  tiers_ip_plage,
  tiers_ip_mails
FROM
  tiers
  LEFT JOIN etat_tiers ON tiers_etat = etat_tiers_id
WHERE
  etat_tiers_nom LIKE 'valide';
