Создать запрос для разделения  "задвоенных" данных. Например, из

CODE_OPERATION	ID_CLIENT
1000 1100	    841000 841100
2000	        6700 8967 5500
сделать
RN	CNT	CODE_OPERATION	ID_CLIENT
1	0	1000 1100	    841000 841100
	1	1000	        841000
	2	1100	        841100
2	0	2000	        6700 8967 5500
	1	2000	        6700
	2		            8967
	3		            5500

WITH inf1 AS 
(SELECT '1000 1100' code_operation, '841000 841100' id_client 
FROM dual 
UNION 
SELECT '2000' , '6700 8967 5500' 
FROM dual), 

inf AS 
(SELECT code_operation, id_client, ROWNUM rn 
FROM inf1), 

code AS 
(SELECT DISTINCT regexp_substr(code_operation, '[^ ]+', 1, LEVEL) code_operation, rn, Level cnt 
FROM inf 
CONNECT BY LEVEL <= regexp_count(code_operation, '[^ ]+') 
ORDER BY rn, cnt), 

id AS 
(SELECT DISTINCT regexp_substr(id_client, '[^ ]+', 1, LEVEL) id_client, rn, LEVEL cnt 
FROM inf 
CONNECT BY LEVEL <= regexp_count(id_client, '[^ ]+') 
ORDER BY rn, cnt), 

res AS 
(SELECT c.rn rn, i.cnt cnt, nvl(code_operation, ' ') code_operation, id_client 
FROM code c FULL JOIN id i ON(c.rn=i.rn AND c.cnt=i.cnt) 
UNION 
SELECT rn, 0 , code_operation, id_client 
FROM inf) 

SELECT decode(cnt, 0, to_char(rn), ' ') rn, cnt, code_operation, id_client 
FROM res;