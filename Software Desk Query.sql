SELECT
    ASS.SUPP_ID,
    ASS.ORG_ID,
    UPPER(ASS.REQUEST_TYPE) AS REQUEST_TYPE,
    ASS.GROUP_ID,
    ASS.PAGE_ID,
    UPPER(MAX(PG.PAGE_NAME)) AS PAGE_NAME,
    UPPER(MAX(AAP.APPLICATION_NAME)) AS APPLICATION_NAME,
    UPPER(ASS.REQUEST_TITLE) AS SUBJECT,
    UPPER(ASS.REQUEST_DESCRIPTION) AS REQUEST_DESCRIPTION,
    ASS.ASSIGNED_ON,
    TO_CHAR(TASK_START_TIME, 'DD-MON-YYYY HH:MIPM') AS TASK_START_TIME,
    TO_CHAR(TASK_END_TIME, 'DD-MON-YYYY HH:MIPM') AS TASK_END_TIME,
    ROUND(
        EXTRACT(DAY FROM (TASK_END_TIME - TASK_START_TIME)) * 24 +
        EXTRACT(HOUR FROM (TASK_END_TIME - TASK_START_TIME)) +
        EXTRACT(MINUTE FROM (TASK_END_TIME - TASK_START_TIME)) / 60, 2
    ) AS TASK_COMPLETED_IN_HOURS,
    NVL(TO_DATE(:P201_FROM_DATE, 'DD-MON-YYYY'), TRUNC(SYSDATE)) AS FROM_DATE,
    NVL(TO_DATE(:P201_TO_DATE, 'DD-MON-YYYY'), TRUNC(SYSDATE)) AS TO_DATE,
    UPPER(ASS.STATUS) AS STATUS,
    'UPDATES' AS UPDATES,
   -- CASE WHEN ORG_ID IN ('1001','1004', '1002') THEN 'UPDATE' ELSE NULL END UPDATES,
    UPPER(ASS.CREATED_BY) AS CREATED_BY,
    UPPER(:APP_USER) AS APP_USER,
    ASS.CREATED_ON
FROM AB_SOFTWARE_SUPPORT ASS
JOIN apex_application_pages PG ON PG.PAGE_ID = ASS.PAGE_ID
JOIN apex_applications AAP ON AAP.APPLICATION_ID = ASS.APP_ID
WHERE 
    (:P201_FROM_DATE IS NULL OR TRUNC(ASS.CREATED_ON) >= TO_DATE(:P201_FROM_DATE, 'DD-MON-YYYY')) AND
    (:P201_TO_DATE IS NULL OR TRUNC(ASS.CREATED_ON) <= TO_DATE(:P201_TO_DATE, 'DD-MON-YYYY')) --AND
--    (:GV_ORG_ID IS NULL OR ORG_ID = :GV_ORG_ID) AND
--     ORG_ID IN ('1004', '1001', '1002')
GROUP BY 
    ASS.SUPP_ID,
    ASS.ORG_ID,
    ASS.REQUEST_TYPE,
    ASS.GROUP_ID,
    ASS.PAGE_ID,
    ASS.REQUEST_TITLE,
    ASS.REQUEST_DESCRIPTION,
    ASS.TASK_START_TIME,
    ASS.TASK_END_TIME,
    ASS.STATUS,
    ASS.ASSIGNED_ON,
    ASS.CREATED_BY,
    ASS.CREATED_ON;