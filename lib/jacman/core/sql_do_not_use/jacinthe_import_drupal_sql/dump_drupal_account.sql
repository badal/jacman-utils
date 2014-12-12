-- ==========================================================
-- = THIS FILE IS FOR INFO ONLY !! ITS CODE IS NOT USE HERE =
-- ==========================================================
-- This file is a template and it content reflectS the one on drupal server
SELECT
  smf_profile.uid                                                              drupal_id,
  IF(LENGTH(smf_profile.civilite) > 0, smf_profile.civilite, NULL)             drupal_civilite,
  IF(LENGTH(smf_profile.nom) > 0, smf_profile.nom, NULL)                       drupal_nom,
  IF(LENGTH(smf_profile.prenom) > 0, smf_profile.prenom, NULL)                 drupal_prenom,
  IF(LENGTH(smf_profile.date_naissance) > 0, smf_profile.date_naissance, NULL) drupal_date_naissance,
  IF(LENGTH(smf_profile.url) > 0, smf_profile.url, NULL)                       drupal_url,
  IF(LENGTH(smf_adresse.ligne1) > 0, smf_adresse.ligne1, NULL)                 drupal_adresse_ligne1,
  IF(LENGTH(smf_adresse.ligne2) > 0, smf_adresse.ligne2, NULL)                 drupal_adresse_ligne2,
  IF(LENGTH(smf_adresse.ligne3) > 0, smf_adresse.ligne3, NULL)                 drupal_adresse_ligne3,
  IF(LENGTH(smf_adresse.ligne4) > 0, smf_adresse.ligne4, NULL)                 drupal_adresse_ligne4,
  IF(LENGTH(smf_adresse.code_postal) > 0, smf_adresse.code_postal, NULL)       drupal_adresse_code_postal,
  IF(LENGTH(smf_adresse.ville) > 0, smf_adresse.ville, NULL)                   drupal_adresse_ville,
  IF(LENGTH(smf_adresse.pays) > 0, smf_adresse.pays, NULL)                     drupal_adresse_pays,
  IF(LENGTH(smf_adresse.tel) > 0, smf_adresse.tel, NULL)                       drupal_adresse_tel,
  IF(LENGTH(smf_adresse.fax) > 0, smf_adresse.fax, NULL)                       drupal_adresse_fax,
  smf_profile.type                                                             drupal_type,
  users.mail                                                                   drupal_email,
  smf_profile.retraite                                                         drupal_retraite,
  IF(LENGTH(smf_profile.conjoint) > 0, smf_profile.conjoint, NULL)             drupal_conjoint
INTO OUTFILE '/Users/kenji/Public/drupal_account.txt'
  CHARACTER SET UTF8 FIELDS TERMINATED BY "\t" OPTIONALLY ENCLOSED BY '"' ESCAPED BY "\\" LINES TERMINATED BY "\n"
FROM smf_profile
LEFT JOIN smf_routage ON smf_profile.uid = smf_routage.uid
LEFT JOIN smf_adresse ON smf_adresse.aid = smf_routage.adresse
LEFT JOIN users ON users.uid = smf_profile.uid;
