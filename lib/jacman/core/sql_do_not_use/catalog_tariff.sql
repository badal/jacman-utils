-- sql fragment for tariff
--

INTO TABLE tarif
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(tarif_article_sage, tarif_public, tarif_membre);
