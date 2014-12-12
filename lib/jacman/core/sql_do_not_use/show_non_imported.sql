SELECT
  sage_document_article                                         article,
  CONCAT(client_sage_intitule, ' #', sage_document_client_sage) client,
  sage_document_numero_piece                                    facture
FROM
  sage_document
  LEFT JOIN client_sage
    ON sage_document_client_sage = client_sage_id
WHERE sage_document_a_traiter = 1\G
