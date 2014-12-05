DELIMITER $$

-- PROCEDURE IMPORTANT LES LIGNES DE LA TABLE sage_document
DROP PROCEDURE IF EXISTS import_sage_document$$
CREATE PROCEDURE import_sage_document()
  BEGIN
    DECLARE my_sage_document_id INT(11);
    DECLARE my_sage_document_article VARCHAR(18);
    DECLARE my_sage_document_client_sage VARCHAR(17);
    DECLARE my_sage_document_date DATE;
    DECLARE my_sage_document_nbre INT(11);
    DECLARE my_sage_document_numero_piece VARCHAR(9);
    DECLARE my_sage_document_reference VARCHAR(17);
    DECLARE my_sage_document_designation VARCHAR(69);
    DECLARE my_sage_document_prix_unitaire INT(11);
    DECLARE my_sage_document_type VARCHAR(2);

-- > ADDED BY MD
    DECLARE wrong_document INT;
-- < ADDED BY MD

    DECLARE no_more_sage_document BOOLEAN;
    DECLARE CR CURSOR FOR
      SELECT
        sage_document_id,
        sage_document_article,
        sage_document_client_sage,
        sage_document_date,
        sage_document_nbre,
        sage_document_numero_piece,
        sage_document_reference,
        sage_document_designation,
        sage_document_prix_unitaire,
        SUBSTRING(sage_document_numero_piece, 1, 2)
      FROM `sage_document`
      WHERE `sage_document_a_traiter` = 1;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_sage_document = 1;

    SET no_more_sage_document = 0;

-- START TRANSACTION;

    OPEN CR;

    sage_document_loop: REPEAT

      FETCH CR
      INTO
        my_sage_document_id,
        my_sage_document_article,
        my_sage_document_client_sage,
        my_sage_document_date,
        my_sage_document_nbre,
        my_sage_document_numero_piece,
        my_sage_document_reference,
        my_sage_document_designation,
        my_sage_document_prix_unitaire,
        my_sage_document_type;

-- On s'arrete lorsqu'il n'y a plus de document sage
      IF no_more_sage_document = 1
      THEN
        LEAVE sage_document_loop;
      END IF;

      IF NOT (my_sage_document_type = 'FA' OR my_sage_document_type = 'RE')
      THEN
        ITERATE sage_document_loop;
      END IF;

-- < ADDED BY MD
      SET wrong_document = 0;
      BEGIN
        DECLARE EXIT HANDLER FOR 1452 SET wrong_document = 1;
-- > ADDED BY MD

-- UTILISATION DE LA NOMENCLATURE
        CASE SUBSTRING(my_sage_document_article, 2, 1)
-- COTISATION NC
          WHEN 'C'
          THEN
            CALL import_adhesion(
                my_sage_document_id,
                my_sage_document_article,
                my_sage_document_client_sage,
                my_sage_document_numero_piece,
                my_sage_document_nbre
            );
-- DON KD
          WHEN 'D'
          THEN
            CALL import_don(
                my_sage_document_id,
                my_sage_document_article,
                my_sage_document_client_sage,
                my_sage_document_numero_piece,
                my_sage_document_prix_unitaire,
                my_sage_document_nbre
            );
-- ABONNEMENT PAPIER
          WHEN 'P'
          THEN
            CALL import_abonnement(
                my_sage_document_id,
                my_sage_document_article,
                my_sage_document_client_sage,
                my_sage_document_numero_piece,
                my_sage_document_nbre,
                my_sage_document_reference
            );
-- ABONNEMENT ELECTRONIQUE
          WHEN 'E'
          THEN
            CALL import_abonnement(
                my_sage_document_id,
                my_sage_document_article,
                my_sage_document_client_sage,
                my_sage_document_numero_piece,
                my_sage_document_nbre,
                my_sage_document_reference
            );
-- MONOGRAPHIE
          WHEN 'V'
          THEN
            CALL import_achat_divers(
                my_sage_document_id,
                my_sage_document_article,
                my_sage_document_client_sage,
                my_sage_document_numero_piece,
                my_sage_document_nbre,
                my_sage_document_reference,
                my_sage_document_date
            );
        ELSE
-- do nothing
          BEGIN
          END;
        END CASE;
-- > ADDED BY MD
      END;
-- < ADDED BY MD

-- select my_sage_document_article;

    UNTIL no_more_sage_document END REPEAT sage_document_loop;

    CLOSE CR;


-- COMMIT;
  END$$

DELIMITER ;
