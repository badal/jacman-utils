-- sql command to get electronic subscriptions for exporting
--
-- with a token
--
SELECT
  client_sage_client_final                   tiers_id,
  tiers_drupal                               drupal_id,
  revue_code                                 revue,
  CONCAT(abonnement_annee, '-01-01')         debut,
  CONCAT(abonnement_annee + 1, '-::bonus::') fin
FROM
  abonnement
  LEFT JOIN revue ON revue_id = abonnement_revue
  LEFT JOIN client_sage ON client_sage_id = abonnement_client_sage
  LEFT JOIN tiers ON client_sage_client_final = tiers_id
WHERE abonnement_type = 2
      AND abonnement_annee >= year(now()) - 1
      AND tiers_drupal IS NOT null
      AND abonnement_ignorer = 0;
