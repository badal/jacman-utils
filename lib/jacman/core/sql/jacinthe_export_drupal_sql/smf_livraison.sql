SELECT
  livraison_id                                                            lid,
  client_final.tiers_drupal                                               uid,
  routage_jour                                                            date,
  revue_nom                                                               revue,
  concat('vol. ', trim(LEADING '0' FROM substring(fascicule_nom, 3, 4)),
         if(substring(fascicule_nom, 7, 2), ' fasc. ', ''),
         trim(LEADING '0' FROM substring(fascicule_nom, 7, 2)))           fascicule,
  livraison_nbre                                                          nbre,
  if(payeur.tiers_id != client_final.tiers_id, payeur.tiers_nom, null)    payeur,
  replace(livraison_adresse, "[importation 4D]\n\n", '')                  adresse,
  abonnement_reference_commande                                           reference,
  concat(etat_routage_nom, ' LE ', DATE_FORMAT(routage_jour, '%d/%m/%Y')) etat
INTO OUTFILE "::DUMP_FILE::" ::SQL_DUMP_OPTIONS::
FROM jacinthed.livraison
LEFT JOIN jacinthed.abonnement ON abonnement_id = livraison_abonnement
LEFT JOIN jacinthed.routage ON routage_id = livraison_routage
LEFT JOIN jacinthed.etat_routage ON routage_etat = etat_routage_id
LEFT JOIN jacinthed.fascicule ON fascicule_id = livraison_fascicule
LEFT JOIN jacinthed.revue ON fascicule_revue = revue_id
LEFT JOIN jacinthed.client_sage ON abonnement_client_sage = client_sage_id
LEFT JOIN jacinthed.tiers client_final ON client_sage_client_final = client_final.tiers_id
LEFT JOIN jacinthed.tiers payeur ON client_sage_paiement_chez = payeur.tiers_id
WHERE client_final.tiers_drupal IS NOT NULL
AND routage_etat = 1
AND routage_jour > date_sub(curdate(), INTERVAL IF(1 > ::YEARS::, 1, ::YEARS:: ) YEAR);
