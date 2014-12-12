SELECT
  sage_document_id,
  sage_document_numero_piece
FROM
  sage_document
WHERE
  sage_document_client_sage NOT IN (SELECT
                                      client_sage_id
                                    FROM client_sage)
  AND sage_document_a_traiter = 1;
