Для произвольной команды SELECT определить список входящих в нее таблиц (через запятую) с указанием имени схемы. Задачу решить одной командой SELECT.
Например, для команды:
WITH "СР ПО ОТД" AS (
SELECT DEPARTMENT_ID,AVG(SALARY) AS ASAL
FROM hr.EMPLOYEES 
GROUP BY DEPARTMENT_ID),
"НАИБ БЛИЗ" AS (
SELECT DEPARTMENT_ID, MIN(ABS(SALARY - ASAL)) AS MINSAL
FROM EMPLOYEES JOIN "СР ПО ОТД" USING (DEPARTMENT_ID)
GROUP BY DEPARTMENT_ID)
SELECT EMPLOYEE_ID AS "Номер",LAST_NAME AS "Фамилия",JOB_ID AS "Должность",
DEPARTMENT_ID AS "Отдел",SALARY AS "Оклад", TRUNC(ASAL) AS "Средний оклад"
FROM EMPLOYEES JOIN "MY JOBS" USING (JOB_ID)
JOIN "СР ПО ОТД" USING (DEPARTMENT_ID) JOIN "НАИБ БЛИЗ"
USING (DEPARTMENT_ID)
WHERE (DEPARTMENT_ID, ABS(SALARY - ASAL)) IN
(SELECT DEPARTMENT_ID, MINSAL FROM "НАИБ БЛИЗ")
ORDER BY DEPARTMENT_ID, SALARY, LAST_NAME;
результат должен быть:
hr.EMPLOYEES,os.EMPLOYEES,os."MY JOBS"

WITH str AS
(SELECT 'WITH "СР ПО ОТД" AS (
SELECT DEPARTMENT_ID,AVG(SALARY) AS ASAL
FROM hr.EMPLOYEES 
GROUP BY DEPARTMENT_ID),
"НАИБ БЛИЗ" AS (
SELECT DEPARTMENT_ID, MIN(ABS(SALARY - ASAL)) AS MINSAL
FROM EMPLOYEES JOIN "СР ПО ОТД" USING (DEPARTMENT_ID)
GROUP BY DEPARTMENT_ID)
SELECT EMPLOYEE_ID AS "Номер",LAST_NAME AS "Фамилия",JOB_ID AS "Должность",
DEPARTMENT_ID AS "Отдел",SALARY AS "Оклад", TRUNC(ASAL) AS "Средний оклад"
FROM EMPLOYEES JOIN "MY JOBS" USING (JOB_ID)
JOIN "СР ПО ОТД" USING (DEPARTMENT_ID) JOIN "НАИБ БЛИЗ"
USING (DEPARTMENT_ID)
WHERE (DEPARTMENT_ID, ABS(SALARY - ASAL)) IN
(SELECT DEPARTMENT_ID, MINSAL FROM "НАИБ БЛИЗ")
ORDER BY DEPARTMENT_ID, SALARY, LAST_NAME;' AS stroka
FROM DUAL),

from_str AS
(SELECT DISTINCT REPLACE(REGEXP_SUBSTR(stroka, 'from (\")\w+( \w+)*(\")|from (\w+\.)?\w+', 1, LEVEL, 'i'), 'FROM ', '') stroka
FROM str
CONNECT BY LEVEL <= REGEXP_COUNT(LOWER(stroka), 'from (\")\w+( \w+)*(\")|from (\w+\.)?\w+')),

join_str AS
(SELECT DISTINCT REPLACE(REGEXP_SUBSTR(stroka, 'join (\")\w+( \w+)*(\")|join (\w+\.)?\w+', 1, LEVEL, 'i'), 'JOIN ', '') stroka
FROM str
CONNECT BY LEVEL <= REGEXP_COUNT(LOWER(stroka), 'join (\")\w+( \w+)*(\")|join (\w+\.)?\w+')),

with_str AS
(SELECT DISTINCT REPLACE(REGEXP_SUBSTR(stroka, '(\")\w+( \w+)*(\") as \(|(\w+\.)?\w+ as \(', 1, LEVEL, 'i'), ' AS (', '') stroka
FROM str
CONNECT BY LEVEL <= REGEXP_COUNT(LOWER(stroka), '(\")\w+( \w+)*(\") as \(|(\w+\.)?\w+ as \(')),

res AS
(SELECT * FROM from_str UNION
SELECT * FROM join_str MINUS
SELECT * FROM with_str),

res2 AS
(SELECT 'os.'||stroka stroka
FROM res
WHERE stroka NOT IN(SELECT stroka FROM res WHERE REGEXP_LIKE(LOWER(stroka),'\w+\.\w+'))),

res3 AS
(SELECT * FROM res2 UNION SELECT stroka FROM res WHERE REGEXP_LIKE(LOWER(stroka),'\w+\.\w+'))

SELECT LISTAGG(stroka, ',')WITHIN GROUP(ORDER BY stroka) stroka
FROM res3;