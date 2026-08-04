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
