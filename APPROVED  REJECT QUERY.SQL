DECLARE
    V_ID      NUMBER;
    V_EXISTS  NUMBER;
BEGIN
    IF apex_application.g_f01.COUNT > 0 THEN
        FOR i IN 1 .. apex_application.g_f01.COUNT LOOP
            V_ID := TO_NUMBER(NVL(apex_application.g_f01(i), 0));

           -- Check if approval record already exists
            SELECT COUNT(1)
            INTO V_EXISTS
            FROM AB_USER_ACTION_APPROVAL
            WHERE APP_IDS   = V_ID
              AND APP_TYPE  = '819'
              AND ORG_ID    = :GV_ORG_ID
              AND STATUS    = 'Y';

            IF V_EXISTS = 0 THEN
                -- Insert approval record
                INSERT INTO AB_USER_ACTION_APPROVAL
                       (APP_IDS, STATUS, APP_TYPE, APPROVAL_STATUS)
                VALUES (V_ID, 'Y', '819', 'APPROVED');

                AB_FINANCE_VOUCHER_PKG.GENERATE_PURCHASE_SHIPMENT_VOUCHER(:GV_ORG_ID,V_ID);
                
            END IF;
        END LOOP;

        COMMIT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002,
           'Error in Voucher Approval & Generation: ' || SQLERRM);
END;



//=====================================================================

DECLARE
    V_ID        NUMBER;
    V_EXISTS    NUMBER;
    V_DR_EXISTS NUMBER;
    V_CR_EXISTS NUMBER;
BEGIN
    IF apex_application.g_f01.COUNT > 0 THEN
        FOR i IN 1 .. apex_application.g_f01.COUNT 
   LOOP
            V_ID := TO_NUMBER(NVL(apex_application.g_f01(i), 0));
          SELECT COUNT(1)
                      INTO V_EXISTS
                      FROM AB_USER_ACTION_APPROVAL
                     WHERE APP_IDS = V_ID
                       AND APPROVAL_STATUS = '819'
                       AND ORG_ID=:GV_ORG_ID
                       AND STATUS='Y';
               
            IF  V_EXISTS = 0 THEN 
                INSERT INTO AB_USER_ACTION_APPROVAL(APP_IDS, STATUS, APP_TYPE, APPROVAL_STATUS)
                VALUES(V_ID, 'Y', '819', 'REJECTED');
            END IF;

        END LOOP;
        COMMIT;
    END IF;
    EXCEPTION 
    WHEN OTHERS THEN 
        NULL;
END;
