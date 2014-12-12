-- sql fragment for nomenclature
--

INTO TABLE nomenclature
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(nomenclature_article_sage, nomenclature_id, nomenclature_quantite);
