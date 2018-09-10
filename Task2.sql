Используя словарь данных, получить информацию о первичных ключах и подчиненных таблицах всех таблиц в схеме HR:
Имя
таблицы	Список столбцов первичного ключа	Список подчиненных таблиц 
		
В списках имена столбцов и подчиненных таблиц вывести через запятую по алфавиту. 
Задачу решить без использования функций Listagg и Wm_concat.

WITH t1 AS
(SELECT col.owner, col.constraint_name, col.table_name, col.column_name, con.constraint_type, con.r_constraint_name
FROM all_constraints con JOIN all_cons_columns col ON (con.constraint_name = col.constraint_name)
WHERE col.owner = 'HR' AND con.owner = 'HR' AND constraint_type = 'R'
ORDER BY col.table_name),

подчин_табл1 AS
(SELECT t1.owner, t1.constraint_name, t1.table_name child_table, t1.column_name, t1.constraint_type, t1.r_constraint_name, par.table_name parent_table, par.column_name
FROM all_cons_columns par JOIN t1 ON(t1.r_constraint_name = par.constraint_name)
WHERE par.owner = 'HR'),

подчин_табл2 AS
(SELECT parent_table, child_table , DENSE_RANK()OVER(PARTITION BY parent_table ORDER BY child_table) rank
FROM подчин_табл1
ORDER BY parent_table),

подчин_табл AS
(SELECT parent_table, LTRIM(SYS_CONNECT_BY_PATH(child_table,', '),', ')  child_tables
FROM подчин_табл2
WHERE CONNECT_BY_ISLEAF = 1
START WITH rank = 1
CONNECT BY PRIOR rank = rank - 1 AND PRIOR parent_table = parent_table
ORDER BY parent_table),

перв_ключи1 AS
(SELECT col.owner, col.constraint_name, col.table_name, col.column_name, con.constraint_type
FROM all_constraints con JOIN all_cons_columns col ON (con.constraint_name = col.constraint_name)
WHERE col.owner = 'HR' AND con.owner = 'HR' AND constraint_type = 'P'
ORDER BY col.table_name),

перв_ключи2 AS
(SELECT table_name, column_name, DENSE_RANK()OVER(PARTITION BY table_name ORDER BY column_name) rank
FROM перв_ключи1
ORDER BY table_name),

перв_ключи AS
(SELECT table_name, LTRIM(SYS_CONNECT_BY_PATH(column_name, ', '),', ') column_name
FROM перв_ключи2
WHERE CONNECT_BY_ISLEAF = 1
START WITH rank = 1
CONNECT BY PRIOR rank = rank-1 AND PRIOR table_name = table_name
ORDER BY table_name),

res1 AS
(SELECT table_name, column_name, child_tables
FROM перв_ключи k FULL JOIN подчин_табл p ON(p.parent_table = k.table_name)),

res2 AS
(SELECT TABLE_NAME FROM all_tables WHERE owner = 'HR')

SELECT r.table_name, nvl(column_name,' ') primary_keys, nvl(child_tables, ' ') child_tables
FROM res1 r FULL JOIN res2 rr ON (r.table_name = rr.table_name)
ORDER BY r.table_name;
