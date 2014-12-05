SELECT
  tiers_drupal             uid,
  tiers_ip_plage           ip_plage,
  tiers_ip_mails           ip_mails,
  tiers_ip_nb_utilisateurs ip_nb_utilisateurs
INTO OUTFILE "::DUMP_FILE::" ::SQL_DUMP_OPTIONS::
FROM jacinthed.tiers
WHERE tiers_drupal IS NOT NULL;
