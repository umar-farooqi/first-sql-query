DECLARE
  v_com_id NUMBER;
  v_com_idS NUMBER;
  v_com_idSS NUMBER;
BEGIN
  CASE :APEX$ROW_STATUS
    WHEN 'C' THEN -- Insert operation
      INSERT INTO AB_FACILITIES_LETTER_DET 
      (MAST_ID, FACILITIES_ID, MATURITY_TYPE, AMOUNT, CASH_MARGIN, ISSUE_DATE, EXP_DATE, SERVICE_CHARGES, BG_SECURITY, FACILITIES_TYPE, STATUS)
      VALUES 
      (:P594_ID , :FACILITIES_ID, :MATURITY_TYPE, :AMOUNT, :CASH_MARGIN,TO_DATE(:ISSUE_DATE, 'DD-MON-YYYY'),TO_DATE(:EXP_DATE, 'DD-MON-YYYY'), :SERVICE_CHARGES, :BG_SECURITY, 'FACILITIES DET', 'Y')
      RETURNING ID INTO :ID;

      SELECT MAX(ID) INTO v_com_id FROM AB_FACILITIES_LETTER_DET;
      SELECT MAX(ID) INTO v_com_idS FROM AB_FACILITIES_LETTER_DET;
      SELECT MAX(ID) INTO v_com_idSS FROM AB_FACILITIES_LETTER_DET;

      -- Insert Company ]Names
      FOR i IN (
        SELECT 
          TRIM(REGEXP_SUBSTR(:COMPANY_NAME, '[^:]+', 1, LEVEL)) AS V_level_1
        FROM dual
        CONNECT BY LEVEL <= REGEXP_COUNT(:COMPANY_NAME, ':') + 1
      )
      LOOP
        IF i.V_level_1 IS NOT NULL THEN
          INSERT INTO AB_FACILITIES_LETTER_DET (
            IDS,
            COMPANY_NAME,
            IMAGE_TYPE,
            STATUS
          ) 
          VALUES (
            v_com_id,
            i.V_level_1,
            'FACILITIES COMPANY',
            'Y'
          );
        END IF;
      END LOOP;

    --   -- Insert Intitled Companies
      FOR i IN (
        SELECT 
          TRIM(REGEXP_SUBSTR(:INTITLED_COMPANY, '[^:]+', 1, LEVEL)) AS V_level_1
        FROM dual
        CONNECT BY LEVEL <= REGEXP_COUNT(:INTITLED_COMPANY, ':') + 1
      )
      LOOP
        IF i.V_level_1 IS NOT NULL THEN
          INSERT INTO AB_FACILITIES_LETTER_DET (
            IDS,
            INTITLED_COMPANY,
            IMAGE_TYPE,
            STATUS
          ) 
          VALUES (
            v_com_idS,
            i.V_level_1,
            'FACILITIES COMPANY INTITLED',
            'Y'
          );
        END IF;
      END LOOP;
 -----------------------------------------------------------------------------
FOR acn IN (
        SELECT 
            TRIM(REGEXP_SUBSTR(TO_CHAR(:ACCOUNT_NO), '[^:]+', 1, LEVEL)) AS v_level_2 FROM dual CONNECT BY LEVEL <= REGEXP_COUNT(TO_CHAR(:ACCOUNT_NO), ':') + 1
)
LOOP    
   IF acn.V_level_2 IS NOT NULL THEN
        INSERT INTO AB_FACILITIES_LETTER_DET (
            IDS,
            ACCOUNT_NO,
            IMAGE_TYPE,
            STATUS
        ) 
        VALUES (
            v_com_idSS,                     
            acn.V_level_2 ,   
            'FACILITIES ACCOUNT NUMBER',
            'Y'
        );
    END IF;
END LOOP;
----------------------------UPDATE ------------------------------------------
  END CASE;
END;
