-- sql fragment for articles
--

INTO TABLE article_sage
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(article_sage_id, article_sage_designation, article_sage_famille, article_sage_nomenclature);
