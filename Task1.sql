Используя обращение только к таблице DUAL, построить SQL-запрос, возвращающий один столбец, содержащий календарь на заданный месяц заданного года:
-	номер дня в месяце (две цифры),
-	полное название месяца по-английски заглавными буквами (в верхнем регистре),
-	год (четыре цифры),
-	полное название дня недели по-английски строчными буквами (в нижнем регистре).
Каждое "подполе" должно быть отделено от следующего одним пробелом. В результате не должно быть начальных и хвостовых пробелов. Количество возвращаемых строк должно точно соответствовать количеству дней в текущем месяце. Строки должны быть упорядочены по номерам дней в месяце по возрастанию.

UNDEFINE MONTH;
UNDEFINE YEAR;

SELECT 
TO_CHAR(LEVEL, 'fm09')
||' '||
RTRIM(TO_CHAR(first_day, 'MONTH', 'NLS_DATE_LANGUAGE = American'), ' ')
||' '||
TO_CHAR(first_day, 'YYYY')
 ||' '||
TRIM(TO_CHAR(first_day + level - 1, 'day', 'NLS_DATE_LANGUAGE = American')) as "Calendar"
FROM (SELECT TO_DATE(UPPER('&&month')||'_'||&&year, 'MONTH_YYYY', 'NLS_DATE_LANGUAGE = Russian') as first_day
FROM DUAL
)
CONNECT BY LEVEL <= TO_CHAR(last_day(first_day), 'DD');