   SETUP_REG AS(
        SELECT 
                    SO.SO_ID,
                    USER_NAME SALE_OFFER,
                    MAX(CASE WHEN ASR.SR_ID=SO.CUSTOMER_ID THEN ASR.REG_NAME END) AS PARTY_NAME,
                    MAX(CASE WHEN ASR.SR_ID=SO.FROM_WAREHOUSE_ID THEN ASR.REG_NAME END) AS FROM_WAREHOUSE,
                    MAX(CASE WHEN LD.DET_ID = SO.FREIGHT_TYPE_ID THEN LD.LOOKUP_DET_NAME END) AS FREIGHT_TYPE,
                    MAX(CASE WHEN LD.DET_ID = SO.STOCK_TYPE_ID THEN LD.LOOKUP_DET_NAME END) AS STOCK_TYPE,
                    MAX(CASE WHEN LD.DET_ID = SO.DELIVERY_STATUS THEN LD.LOOKUP_DET_NAME END) AS DELIVERY_STATUS,
                    MAX(CASE WHEN LD.DET_ID = SO.STOCK_WISE_ID THEN LD.LOOKUP_DET_NAME END) AS STOCK_WISE,
                    MAX(CASE WHEN LD.DET_ID = SO.PAYMENT_ID THEN LD.LOOKUP_DET_NAME END) AS PAYMENT_MODE
        FROM
                            AB_SO_ORDER_HEAD SO
        LEFT JOIN  AB_LOOKUP_DETAIL LD   ON (LD.DET_ID = SO.FREIGHT_TYPE_ID  OR LD.DET_ID = SO.STOCK_TYPE_ID  OR LD.DET_ID = SO.DELIVERY_STATUS  OR LD.DET_ID = SO.STOCK_WISE_ID  OR LD.DET_ID = SO.PAYMENT_ID)
        LEFT JOIN  AB_SETUP_REGISTRATION ASR ON (ASR.SR_ID=SO.FROM_WAREHOUSE_ID  OR ASR.SR_ID=SO.CUSTOMER_ID)
        LEFT JOIN  AB_UM_APPLICATION_USERS UM  ON UM.USER_ID=SO.SALE_OFFER_ID
       
        WHERE
                     -- SO.SO_TYPE = '645'
            --AND 
            SO.ORG_ID = :GV_ORG_ID
        GROUP BY
            SO.SO_ID,
            USER_NAME
 )    

------------------------------- IS QUEYR ME AB_SETUP_REGISTRATION ME SY SARY VALUE LI HOI HA IN DONO QUERY MAY -------------
  WITH LOV_DATE AS(
                              SELECT
                                    PO.PO_ID,
                                    PO.PURCHASING_TYPE,
                                    MAX(CASE WHEN SR.REG_TYPE = 'CUSTOMER REGISTRATION' AND SR.SR_ID = PO.CUSTOMER_ID THEN SR.REG_NAME END) AS CUSTOMER_NAME,
                                    MAX(CASE WHEN SR.REG_TYPE = 'COMPANY' AND SR.SR_ID = PO.COMPANY_ID THEN SR.REG_NAME END) AS COMPANY_NAME,
                                    MAX(CASE WHEN LD.DET_ID = PO.PAYMENT_MODE_ID THEN LD.LOOKUP_DET_NAME END) AS PAYMENT_MODE,
                                    MAX(CASE WHEN SR.REG_TYPE = 'VENDOR' AND SR.SR_ID = PO.VENDOR_ID THEN SR.PARTY_NAME END) AS VENDOR_NAME,
                                    MAX(CASE WHEN SR.REG_TYPE = 'CUSTOMER REGISTRATION' AND SR.SR_ID = PO.FREIGHT_PARTY_ID THEN SR.REG_NAME END) AS FREIGHT_PARTY,
                                    AU.USER_NAME,
                                        TO_CHAR(PO.CREATED_ON, 'DD-MON-YYYY') AS CREATED_ON
                              FROM
                                              AB_PO_PURCHASE_ORDER PO
                                     JOIN   AB_PO_PURCHASE_ORDER_DET POD ON POD.PO_ID=PO.PO_ID
                                     JOIN   AB_LOOKUP_DETAIL LD ON LD.DET_ID = PO.PAYMENT_MODE_ID
                                LEFT JOIN   AB_UM_APPLICATION_USERS AU ON AU.USER_ID = PO.SALE_OFFICER_ID 
                                     JOIN AB_SETUP_REGISTRATION SR ON SR.SR_ID = PO.VENDOR_ID 
                                                                   OR SR.SR_ID = PO.CUSTOMER_ID 
                                                                   OR SR.SR_ID = PO.COMPANY_ID
                                                                   OR SR.SR_ID = PO.FREIGHT_PARTY_ID

               GROUP BY
                            PO.PO_ID,
                            PO.PURCHASING_TYPE,
                            AU.USER_NAME,
                            PO.CREATED_ON
)
