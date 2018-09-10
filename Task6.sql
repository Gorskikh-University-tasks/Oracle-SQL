Имеется таблица со столбцом, содержащим информацию о названиях  документов, например:
		Группафамилиястипендия
		Группафамилидисциплина оценка
		Аттестация ведомость
и т.д.
Кроме того имеется таблица с сокращениями отдельных выражений. Например:

Полное выражение	Сокращенное выражение
Группа				Гр
Фамилия				Фам
Стипендия			Ст
Дисциплина			Дсц
Оценка				Оц
Аттестация			Атт
Ведомость			Вдм
 
 Требуется вывести полные  названия документов и сокращенные. 
Пример результата:

Полное название документа		Сокращенное название
Группафамилиястипендия			ГрФамСт
Группафамилидисциплина оценка	ГрФамДсцОц
Аттестация ведомость			АттВдм

WITH docs1 AS
(SELECT 'Группафамилиястипендия' Doc  FROM DUAL
UNION
SELECT 'Группафамилиядисциплина оценка'  FROM  DUAL
UNION
SELECT 'Аттестация ведомость'  FROM DUAL),

sokr1 AS
(SELECT  'Группа' пол_выр, 'Гр' сокр_выр  FROM DUAL
UNION
SELECT  'Фамилия',  'Фам' FROM DUAL
UNION
SELECT  'Стипендия',  'Ст' FROM DUAL
UNION
SELECT  'Дисциплина',  'Дсц' FROM DUAL
UNION
SELECT  'Оценка',  'Оц' FROM DUAL
UNION
SELECT  'Ведомость',  'Вдм' FROM DUAL
UNION
SELECT  'Аттестация',  'Атт' FROM DUAL),

docs2 AS
(SELECT doc,  ROWNUM rn  FROM docs1),

docs AS
(SELECT RPAD(REPLACE(LOWER(doc), ' ', ''), LENGTH(REPLACE(LOWER(doc), ' ', '') )+ 1, '*') doc, NULL sok, ROWNUM rn  FROM docs1),

sokr AS
(SELECT LOWER(пол_выр) пол_выр,  сокр_выр FROM sokr1),

recur( doc, sok, rn)AS
(SELECT doc, sok, rn FROM docs
UNION ALL
SELECT SUBSTR(r.doc, LENGTH(s.пол_выр)+1), s.сокр_выр, r.rn
FROM recur r JOIN sokr s ON(rpad(r.doc, LENGTH(s.пол_выр)) = s.пол_выр)),

itog AS
(SELECT DISTINCT  listagg(sok)WITHIN GROUP(ORDER BY rn, LENGTH(doc) DESC) OVER(PARTITION BY rn) сокр_назв, rn
 FROM recur
WHERE sok IS NOT NULL)

, t1 AS (
SELECT doc, сокр_назв
 FROM docs2 JOIN itog USING(rn)
ORDER BY rn )

SELECT *
FROM t1;
