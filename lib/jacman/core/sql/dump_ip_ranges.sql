-- sql command to get electronic subscriptions for processing

SELECT
  client_sage_client_final tiers,
  revue_code               revue,
  abonnement_annee         annee,
  tiers_ip_plage           ips
FROM abonnement
  LEFT JOIN revue ON abonnement.abonnement_revue = revue.revue_id
  LEFT JOIN client_sage ON abonnement_client_sage = client_sage_id
  LEFT JOIN tiers ON tiers_id = client_sage_client_final
WHERE
  (abonnement_annee = year(now()) OR abonnement_annee = year(now()) - 1)
  AND abonnement_type = 2 AND abonnement_ignorer = 0;
