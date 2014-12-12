-- sql fragment for stock
--

INTO TABLE stock
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(stock_article_sage, stock_quantite);
