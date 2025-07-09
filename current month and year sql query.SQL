get mont and year show in pop love 
SELECT 
       trim(to_char(add_months(sysdate,level-1),'MONTH'))||'-'||to_char(add_months(sysdate,level-1),'RRRR') AS R,
       trim(to_char(add_months(sysdate,level-1),'MONTH'))||'-'||to_char(add_months(sysdate,level-1),'RRRR') AS D
FROM DUAL
CONNECT BY LEVEL <= 1;


-------===============
ONLY 12 MONTH SHOW 
SELECT 
    TO_CHAR(TO_DATE(LEVEL, 'MM'), 'Month') AS DISPLAY_VALUE,
    LEVEL AS RETURN_VALUE
FROM DUAL
CONNECT BY LEVEL <= 12;
