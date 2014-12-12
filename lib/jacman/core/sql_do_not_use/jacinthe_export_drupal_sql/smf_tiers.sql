SELECT
  tiers_drupal   uid,
  tiers_id       tid,
  type_tiers_nom type
INTO OUTFILE "::DUMP_FILE::" ::SQL_DUMP_OPTIONS::
FROM jacinthed.tiers
LEFT JOIN jacinthed.type_tiers ON type_tiers_id = tiers_type
WHERE tiers_drupal IS NOT NULL;
