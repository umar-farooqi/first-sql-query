DECLARE
    V_TR_ID         AB_FIN_TRANSACTION.TR_ID%TYPE;
    V_VOUCHER_ID    NUMBER;
    V_VOUCHER_NAME  VARCHAR2(100);
    V_VOUCHER_TYPE  VARCHAR2(100);
    V_ACCOUNT_HEAD  VARCHAR2(500);
    V_VOUCHER_COUNT NUMBER;
BEGIN
      SELECT COUNT(*) + 1 INTO V_VOUCHER_COUNT FROM AB_FIN_TRANSACTION TR
      WHERE TR.ORG_ID= :GV_ORG_ID AND TR.VOUCHER_TYPE_ID = :P813_VOUCHER_TYPE
       AND TR.STATUS= 'Y' AND TR.CREATED_ON>= TRUNC(SYSDATE, 'YYYY');

    SELECT DESCRIPTION INTO V_VOUCHER_TYPE  FROM AB_LOOKUP_DETAIL WHERE STATUS = 'Y' AND MAST_ID = 39 AND DET_ID  = :P813_VOUCHER_TYPE;
    -- Generate Voucher Name: e.g. "GENERAL VOUCHER - 25 - 7"
    V_VOUCHER_NAME := V_VOUCHER_TYPE 
                      || ' - ' 
                      || TO_CHAR(SYSDATE, 'YY') 
                      || ' - ' 
                      || V_VOUCHER_COUNT;
    -- Insert header record and get TR_ID
    INSERT INTO AB_FIN_TRANSACTION (
                 TR_TYPE, TR_DATE, STATUS, VOUCHER_TYPE_ID,VOUCHER_NAME) 
    VALUES (
             801, TO_DATE(:P813_TRANSCATION_DATE, 'DD-MON-YYYY'), 'Y', :P813_VOUCHER_TYPE,V_VOUCHER_NAME)
    RETURNING TR_ID INTO V_TR_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        APEX_ERROR.ADD_ERROR (
            p_message => 'Voucher type not found or invalid.',
            p_display_location => apex_error.c_inline_in_notification
        );
    WHEN OTHERS THEN
        APEX_ERROR.ADD_ERROR (
            p_message => 'An unexpected error occurred: ' || SQLERRM,
            p_display_location => apex_error.c_inline_in_notification
        );
END;
