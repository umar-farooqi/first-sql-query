        SELECT
                   INITCAP(PO.PURCHASING_TYPE) || ' - ' || POD.PO_ID ||'- Party Name: ' || SR.REG_NAME||'-'||REG_AREA AS D,
                   PO.PO_ID AS R
        FROM
                               AB_ITEMS_MASTER ITM          
                    JOIN  AB_PO_PURCHASE_ORDER_DET POD ON POD.ITEM_ID=ITM.ITEM_ID
                    JOIN  AB_PO_PURCHASE_ORDER PO ON PO.PO_ID=POD.PO_ID
           LEFT JOIN  AB_SETUP_REGISTRATION SR ON  SR.SR_ID = PO.CUSTOMER_ID AND SR.REG_TYPE = 'CUSTOMER REGISTRATION'
        WHERE
                          PO_TYPE IN ('DUMPING','642')
                AND  PO.ORG_ID=:GV_ORG_ID
                AND  PO.STATUS = 'Y'
               --- AND  NVL(POD.CHANGE_BAGS, 0) - NVL(SOD.D_BAGS,0) -NVL(INV.INV_BAGS,0) >0
        GROUP BY 
                   PO.PO_ID,
                    INITCAP(PO.PURCHASING_TYPE) || ' - ' || POD.PO_ID ||'- Party Name: ' || SR.REG_NAME||'-'||REG_AREA 
        ORDER BY 
                   PO.PO_ID DESC
