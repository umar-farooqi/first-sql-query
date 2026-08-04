DECLARE
    v_com_id NUMBER;
BEGIN

    INSERT INTO CREDIT_LIMIT_REGISTRATION
    (
        SUPPLIER_ID,
        LIMIT_CREDIT,
        ISSUE_DATE,
        STATUS
    )
    VALUES
    (
        :P1339_SUPPLIER_ID,
        :P1339_LIMIT_CREDIT,
        TO_DATE(:P1339_ISSUE_DATE,'DD-MON-YYYY'),
        'Y'
    )
    RETURNING ID INTO v_com_id;

    FOR i IN
    (
        SELECT TRIM(REGEXP_SUBSTR(:P1339_AGENCY_ID,'[^:]+',1,LEVEL)) AGENCY_ID
        FROM DUAL
        CONNECT BY LEVEL <= REGEXP_COUNT(:P1339_AGENCY_ID,':') + 1
    )
    LOOP
        IF i.AGENCY_ID IS NOT NULL THEN
            INSERT INTO CREDIT_LIMIT_REGISTRATION
            (
                IDS,
                AGENCY_ID,
                REGISTRATION_TYPE,
                STATUS
            )
            VALUES
            (
                v_com_id,
                i.AGENCY_ID,
                'CREDIT LIMIT REGISTRATION',
                'Y'
            );
        END IF;
    END LOOP;

END;




--REPORT FATCH DATA 


 WITH ACCOUNT_TYPE AS(
    SELECT 
            REG_NAME ACCOUNT_TYPE,
            SR_ID ACCOUNT_ID
    FROM 
                AB_SETUP_REGISTRATION
    WHERE 
                REG_TYPE = 'ACCOUNT TYPE'
       AND REG_STATUS = 'Y'
       AND SR_ID=4929
)
,CHART_OF_ACCOUNT AS(
        SELECT
                 COA.COA_ID,
                 COA.SUB_ACCOUNT_TYPE,
                 COA.ACCOUNT_TITLE
        FROM
                        AB_FIN_COA COA 
             JOIN  ACCOUNT_TYPE AP ON AP.ACCOUNT_ID=COA.ACCOUNT_TYPE
        WHERE COA.STATUS = 'Y'
) , AGENCY_NAMES AS (
        SELECT 
                        ACCOUNT_TITLE AGENY_NAME,
                        COA_ID AGENY_ID
        FROM
                     AB_SETUP_REGISTRATION ASR 
            JOIN CHART_OF_ACCOUNT COA ON COA.SUB_ACCOUNT_TYPE=ASR.SR_ID
        WHERE 
                       ASR.REG_STATUS='Y'
         

), REGISTRATION AS(
                SELECT  SR_ID, REG_NAME, PARTY_NAME,REG_CODE
                FROM AB_SETUP_REGISTRATION WHERE REG_STATUS='Y'
),

AGENCY_NAME_MULTIPLE AS (
    SELECT
                IDS ,
                MAX(FLD.AGENCY_ID),
               LISTAGG(DISTINCT AGENY_NAME, ', ') WITHIN GROUP (ORDER BY AGENY_NAME) AS AGENY_NAME
        FROM
                      CREDIT_LIMIT_REGISTRATION FLD
            LEFT JOIN AGENCY_NAMES AG ON AG.AGENY_ID=FLD.AGENCY_ID
        WHERE
                  REGISTRATION_TYPE='CREDIT LIMIT REGISTRATION'
        AND FLD.ORG_ID=:GV_ORG_ID
    GROUP BY
                 IDS--,
                -- FLD.AGENCY_ID
)
select 
       CLR.ID,
       CLR.SUPPLIER_ID,
       CLR.AGENCY_ID,
       CLR.LIMIT_CREDIT,
       CLR.ISSUE_DATE,
       CLR.CREATED_BY,
       CLR.CREATED_ON,
       CLR.UPDATED_BY,
       CLR.UPDATED_ON,
       CLR.ORG_ID,
       NVL(VN.REG_NAME,VN.PARTY_NAME) Supplier_Name,
       ANM.AGENY_NAME
       
  from CREDIT_LIMIT_REGISTRATION CLR
  LEFT JOIN REGISTRATION VN ON VN.SR_ID=CLR.SUPPLIER_ID
  LEFT JOIN AGENCY_NAME_MULTIPLE ANM ON ANM.IDS = CLR.ID
  where ORG_ID = :GV_ORG_ID
  AND CLR.IDS IS NULL
  AND STATUS = 'Y'
  ORDER BY ID DESC
  
