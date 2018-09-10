Определить список сотрудников (таблица Employees), у которых в именах и фамилиях содержится, по крайней мере, по три совпадающие буквы. 
Результат представить в виде:
Сотрудник			Результат
Alberto Errazuriz	Совпадают три буквы (a,e,r)
Alexaner Hunold		Совпадают три буквы (d,l,n)
Elizabeth Bates		Совпадают четыре буквы (a,b,e,t)

WITH inf_l AS
(SELECT employee_id, LOWER(REPLACE(last_name, ' ', '')) last_name, NULL alph
FROM employees),

recur_l(employee_id, last_name, alph) AS
(SELECT employee_id, last_name, alph
FROM inf_l
UNION ALL
SELECT employee_id, REPLACE(last_name,RPAD(last_name, 1),''), RPAD(last_name, 1)
FROM recur_l
WHERE last_name IS NOT NULL),

las AS
(SELECT r.employee_id, e.last_name, r.alph 
FROM recur_l r JOIN employees e ON(r.employee_id = e.employee_id)
WHERE alph IS NOT NULL
ORDER BY employee_id),

inf_f AS
(SELECT employee_id, LOWER(REPLACE(first_name, ' ', '')) first_name, NULL alph
FROM employees),

recur_f(employee_id, first_name, alph) AS
(SELECT employee_id, first_name, alph
FROM inf_f
UNION ALL
SELECT employee_id, REPLACE(first_name,RPAD(first_name, 1),''), RPAD(first_name, 1)
FROM recur_f
WHERE first_name IS NOT NULL),

fir AS
(SELECT r.employee_id, e.first_name, r.alph 
FROM recur_f r JOIN employees e ON(r.employee_id = e.employee_id)
WHERE alph IS NOT NULL
ORDER BY employee_id),

res1 AS
(SELECT l.employee_id, f.first_name, f.alph , l.last_name
FROM las l JOIN fir f ON(l.employee_id = f.employee_id AND f.alph = l.alph)),

res2 AS
(SELECT employee_id , first_name, last_name, LISTAGG(alph, ',') WITHIN GROUP(ORDER BY alph) alph
FROM res1
GROUP BY employee_id , first_name, last_name)

SELECT employee_id , first_name||' '||last_name sotr, 'Совпадают '||DECODE(REGEXP_COUNT(alph, '[^,]+'),3,'три',4,'четыре')||' буквы('||alph||')' alph
FROM res2
WHERE REGEXP_COUNT(alph, '[^,]+') >=3; 