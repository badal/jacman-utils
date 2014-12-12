SELECT
  adhesion_locale_id        aid,
  client_final.tiers_drupal uid,
  adhesion_locale_annee     annee
INTO OUTFILE "::DUMP_FILE::" ::SQL_DUMP_OPTIONS::
FROM jacinthed.adhesion_locale
LEFT JOIN jacinthed.client_sage ON adhesion_locale_client_sage = client_sage_id
LEFT JOIN jacinthed.tiers client_final ON client_final.tiers_id = client_sage_client_final
WHERE client_final.tiers_drupal IS NOT NULL
AND adhesion_locale_ignorer = 0
AND adhesion_locale_annee > YEAR(curdate()) - ::YEARS::;
