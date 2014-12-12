SELECT
  abonnement_id                                                      aid,
  client_final.tiers_drupal                                          uid,
  abonnement_annee                                                   annee,
  revue_nom                                                          revue,
  abonnement_nbre                                                    nbre,
  type_abonnement_nom                                                type,
  if(payeur.tiers_id != client_final.tiers_id, payeur.tiers_nom, '') payeur,
  abonnement_reference_commande                                      reference
INTO OUTFILE "::DUMP_FILE::" ::SQL_DUMP_OPTIONS::
FROM jacinthed.abonnement
LEFT JOIN jacinthed.client_sage ON abonnement_client_sage = client_sage_id
LEFT JOIN jacinthed.tiers client_final ON client_final.tiers_id = client_sage_client_final
LEFT JOIN jacinthed.tiers payeur ON payeur.tiers_id = client_sage_paiement_chez
LEFT JOIN jacinthed.revue ON revue_id = abonnement_revue
LEFT JOIN jacinthed.type_abonnement ON type_abonnement_id = abonnement_type
WHERE client_final.tiers_drupal IS NOT NULL
AND abonnement_ignorer = 0
AND abonnement_annee > YEAR(curdate()) - ::YEARS::;
