SELECT
  tiers_drupal           uid,
  type_particularite_nom particularite
INTO OUTFILE "::DUMP_FILE::" ::SQL_DUMP_OPTIONS::
FROM jacinthed.tiers
LEFT JOIN jacinthed.particularite ON particularite_tiers = tiers_id
LEFT JOIN jacinthed.type_particularite ON type_particularite_id = particularite_type
WHERE type_particularite_public = 1 AND tiers_drupal IS NOT NULL;
