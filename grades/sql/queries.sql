--
-- Autor: Javier Arroyo Marcos
-- Fecha: 17/11
-- Descripción: CONSULTAS
-- Se incluye en: 
--

USE grades_db;


-- SELECT:    SELECT columnas FROM tabla WHERE condiciones;

-- 1
SELECT *
FROM subjects; -- Seleccionar todo de la tabla subjects


-- 2
SELECT * 
FROM subjects s     -- pongo un alias de la tabla
WHERE s.acronym = 'IISSI-1';  -- obtengo solamente el acrónimo pedido

-- 3 
SELECT s.subject_name, s.acronym 
FROM subjects s;

-- 4
SELECT s.subject_name, s.acronym, s.subject_type
FROM subjects s
WHERE s.subject_type = 'Formación Básica';


-- JOIN: -- JOIN:   SELECT columnas FROM tabla1 JOIN tabla2 ON tabla1.id = tabla2.id WHERE condiciones;

-- 5
SELECT p.first_name, p.last_name, st.access_method
FROM students st
JOIN people p ON st.student_id = p.person_id
WHERE st.access_method = 'Selectividad';
-- JOIN: uno la tabla people con la tabla q estoy trabajando(students) 
    -- ON: bajo la condición que clave ajena = clave primaria

    -- People
-- person_id   first_name   last_name   
-- 1            Ana          López
-- 2           Carlos        Ruiz
-- 3           Javi          Arroyo
    -- Students
-- student_id	    access_method
-- 1	            Selectividad
-- 3	            Grado Superior  
    -- Unión
-- first_name        last_name     access_method
-- Ana              López          Selectividad
-- Laura            Gómez          Grado Superior


-- 6
SELECT p.first_name, p.last_name, pr.category
FROM professors pr
JOIN people p ON pr.professor_id = p.person_id
WHERE pr.category = 'Catedrático';

----------------------------------- VISTAS ------------------------------------------
-- Es una tabla virtual q funciona como accceso directo a un select guardado

-- 1
CREATE OR REPLACE VIEW v_professors AS
SELECT 
    pr.professor_id,
    pr.category,
    p.person_id,
    p.dni,
    p.first_name,
    p.last_name,
    p.age,
    p.email
FROM professors pr
JOIN people p ON pr.professor_id = p.person_id;


-- 2
CREATE OR REPLACE VIEW v_students AS
SELECT 
    st.student_id,
    st.access_method,
    p.person_id,
    p.dni,
    p.first_name,
    p.last_name,
    p.age,
    p.email
FROM students st
JOIN people p ON st.student_id = p.person_id;
---------------------------------------------------------------------------------

-- FUNCIONES AGREGADAS: SELECT FUNCION(columna) AS alias FROM tabla WHERE condiciones;

-- 7
SELECT AVG(g.grade_value) AS average_grade    -- AVG() promedio aritmético de los valores
FROM grades g
WHERE g.group_id = 1;

-- 8
SELECT SUM(s.credits) AS total_credits     -- SUM() suma todos los valores numéricos
FROM subjects s 
WHERE s.degree_id = 3;

-- 9
SELECT COUNT(*) AS total_students      -- COUNT(*) cuenta el número de filas
FROM students;
-- Sin WHERE, cuenta todas las filas de la tabla.
-- total_students
-- 120

-- 10
SELECT activity, COUNT(*) AS total_groups
FROM groups
GROUP BY activity;
-- activity    total_groups
-- Teoría      4
-- Laboratorio 6


-- 11
SELECT MAX(g.grade_value) AS max_grade
FROM grades g;

-- 12
SELECT MIN(g.grade_value) AS min_grade
FROM grades g;


-- CONDICIONES MÚLTIPLES:
-- 13: OR
SELECT g.grade_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.grade_value < 5 OR g.grade_value > 9;

-- 14: BETWEEN (entre dos números)
SELECT g.grade_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.grade_value BETWEEN 5 AND 7;

-- 15: IN 
SELECT s.subject_name, s.credits
FROM subjects s
WHERE s.credits IN (6, 12);   -- Si el valor está en la lista dada

-- 16: BETWEEN (entre dos números)
SELECT p.first_name, p.last_name, p.age
FROM people p
WHERE p.age BETWEEN 20 AND 30;




-- DISTINCT(eliminar elementos duplicados):     SELECT DISTINCT columnas FROM tabla WHERE condiciones;

-- 17
SELECT DISTINCT g.group_name 
FROM groups g;

-- 18
SELECT DISTINCT s.subject_type
FROM subjects s;


-- 19
SELECT DISTINCT g.academic_year
FROM groups g
ORDER BY g.academic_year DESC;      -- ASC es por defecto


-- SUBCONSULTAS
-- SUBCONSULTA (1 valor): SELECT columnas FROM tabla1 WHERE columna = (SELECT FUNCION(col) FROM tabla2);
-- SUBCONSULTA (varios):  SELECT columnas FROM tabla1 WHERE columna IN (SELECT col FROM tabla2 WHERE condiciones);

-- 20
SELECT MAX(g.grade_value) AS max_grade
FROM grades g
WHERE g.student_id = 6;

-- 21
SELECT DISTINCT ge.student_id
FROM students_groups ge
WHERE ge.group_id IN (      -- el SEGUNDO SELECT es para filtrar 
    SELECT g.group_id 
    FROM groups g 
    WHERE g.academic_year = 2024
);


-- 22
SELECT s.subject_name, s.credits
FROM subjects s
WHERE s.credits > (SELECT AVG(credits) FROM subjects);



-- LIKE: SELECT columnas FROM tabla WHERE columna LIKE 'patron';
-- %: Representa cero, uno o muchos caracteres cualesquiera.
    -- 'A%' -> Empieza por A (Ana, Alberto, A).
    -- '%ez' -> Termina en ez (López, Gómez).
    -- '%an%' -> Contiene "an" en cualquier parte (Juan, Santiago, Ana).

-- _: Representa un único carácter cualquiera.
    -- 'A_a' -> Empieza por A, una letra cualquiera en medio, termina en a (Ana, Ada).

-- Lo contrario es NOT LIKE


-- 23: Termine en A
SELECT p.first_name, p.last_name, p.dni
FROM people p
WHERE p.dni LIKE '%A';

-- 24: Nombre empieza por 'Fundamentos'
SELECT s.subject_name
FROM subjects s
WHERE s.subject_name LIKE 'Fundamentos%';

-- 25: El nombre tenga 5 carácteres(da igual cuáles)
SELECT p.first_name, p.last_name
FROM people p
WHERE p.first_name LIKE '_____';


-- FILTRADO
-- 26
SELECT g.group_name, g.activity, g.academic_year
FROM groups g
WHERE g.academic_year = 2024;

-- 27
SELECT g.group_name, g.activity, g.academic_year
FROM groups g
WHERE g.academic_year BETWEEN 2020 AND 2023
ORDER BY g.academic_year;

--- -------------------------Vistas complejas---------------------------------------
-- 1
CREATE OR REPLACE VIEW v_grades_with_honors AS
SELECT g.grade_id, g.student_id, g.group_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.with_honors = 1;

-- 2
CREATE OR REPLACE VIEW v_student_grades AS
SELECT 
    p.person_id, p.first_name, p.last_name, p.dni,
    g.grade_value, g.exam_call, g.with_honors, gr.group_name, gr.activity, gr.academic_year,
    s.subject_name, s.acronym, s.credits
FROM people p
JOIN students st ON p.person_id = st.student_id
JOIN grades g ON st.student_id = g.student_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;
-- ej: Quiero saber la nota de Ana y en qué asignatura
-- JOIN students st (conectas 1 = 1)
-- JOIN grades g (buscas student_id = 1): Encuentras su nota: 8.5, pero solo te dice que fue en el group_id = 10
-- JOIN groups gr (buscas group_id = 10): Ese grupo te dice que pertenece a la asignatura subject_id = 5
-- JOIN subjects s (buscas subject_id = 5)


-- 3
CREATE OR REPLACE VIEW v_professor_loads AS
SELECT
    p.person_id,
    p.first_name,
    p.last_name,
    pr.category,
    tl.credits AS teaching_credits,
    gr.group_name,
    gr.activity,
    gr.academic_year,
    s.subject_name,
    s.acronym
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- 4
-- Vista 4: Estudiantes por grado
CREATE OR REPLACE VIEW v_degree_students AS
SELECT DISTINCT
    d.degree_id,
    d.degree_name,
    p.person_id,
    p.first_name,
    p.last_name,
    st.access_method,
    gr.academic_year
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN students_groups ge ON gr.group_id = ge.group_id
JOIN students st ON ge.student_id = st.student_id
JOIN people p ON st.student_id = p.person_id;

-- 28
SELECT COUNT(*) AS total_honors
FROM v_grades_with_honors;

-- 29
SELECT v.first_name, v.last_name, AVG(v.grade_value) AS average_grade
FROM v_student_grades v
GROUP BY v.person_id, v.first_name, v.last_name;



-- ORDER BY, LIMIT y OFFSET
-- ORDER BY:  SELECT columnas FROM tabla WHERE condiciones ORDER BY columna ASC|DESC;
-- LIMIT:     SELECT columnas FROM tabla WHERE condiciones ORDER BY columna ASC|DESC LIMIT cantidad;
-- OFFSET:    SELECT columnas FROM tabla WHERE condiciones ORDER BY columna ASC|DESC LIMIT cantidad OFFSET salto;

-- 30 ORDER BY(ASC)
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value ASC;  -- ASC se puede omitir

-- 31 ORDER BY(DESC)
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value DESC;

-- 32 LIMIT
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5;  -- LIMITA cuantos se muestran

-- 33 ORDENACIÓN MÚLTIPLE
SELECT 
    st.first_name,
    st.last_name,
    g.grade_value,
    g.exam_call
FROM grades g
JOIN v_students st ON g.student_id = st.student_id
WHERE g.grade_value >= 5
ORDER BY st.last_name ASC, st.first_name ASC;
-- Se ordena por la primera, y solo si hay empate usa la segunda para desempatar.

-- 34 OFFSET (salta n filas)
-- Consulta 34: Paginación - Segunda página de 5 notas
SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5 OFFSET 5;

-- 35 OFFSET
SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5 OFFSET 10;

-- 36 ORDER BY
SELECT g.group_name, g.activity, g.academic_year
FROM groups g
ORDER BY g.academic_year DESC, g.group_name ASC;


-- JOIN:       SELECT columnas FROM tabla1 t1 JOIN tabla2 t2 ON t1.id = t2.id WHERE condiciones;
-- INNER JOIN: SELECT columnas FROM tabla1 t1 INNER JOIN tabla2 t2 ON t1.id = t2.id WHERE condiciones;
-- LEFT JOIN:  SELECT columnas FROM tabla1 t1 LEFT JOIN tabla2 t2 ON t1.id = t2.id WHERE condiciones;
-- RIGHT JOIN: SELECT columnas FROM tabla1 t1 RIGHT JOIN tabla2 t2 ON t1.id = t2.id WHERE condiciones;

-- JOIN / INNER JOIN: Solo devuelve las filas que coinciden en ambas tablas.
-- LEFT JOIN: Devuelve todas las filas de tabla1 (la de la izquierda) y las que coincidan de tabla2 (si no hay coincidencia, rellena con NULL)
-- RIGHT JOIN: Al revés; devuelve todas las filas de tabla2 (la de la derecha) y las que coincidan de tabla1

-- 37: INNER JOIN(JOIN)
SELECT 
    st.first_name,
    st.last_name,
    gr.group_name,
    gr.activity,
    gr.academic_year
FROM v_students st
JOIN students_groups ge ON st.student_id = ge.student_id   -- N:M se usa una tabla intermedia(2 JOINS)
JOIN groups gr ON ge.group_id = gr.group_id;

-- 38: -- 1:M
SELECT 
    d.degree_name,
    s.subject_name,
    s.acronym,
    s.credits,
    s.course,
    s.subject_type
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
ORDER BY d.degree_name, s.course;


-- 39
SELECT 
    st.first_name,
    st.last_name,
    s.subject_name,
    s.acronym,
    g.grade_value,
    g.exam_call,
    gr.academic_year
FROM grades g
JOIN v_students st ON g.student_id = st.student_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;


-- 40
SELECT 
    pr.first_name,
    pr.last_name,
    pr.category,
    s.subject_name,
    gr.group_name,
    gr.activity,
    tl.credits AS teaching_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- 41 
SELECT DISTINCT  -- elimina los duplicados
    st.first_name,
    st.last_name,
    s.subject_name,
    s.acronym,
    gr.academic_year
FROM v_students st
JOIN students_groups ge ON st.student_id = ge.student_id
JOIN groups gr ON ge.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
ORDER BY st.last_name, s.subject_name;

-- 42: LEFT JOIN Todos los datos de la tabla de la izq(students)  FROM Izq LEFT JOINT Der
SELECT 
    st.first_name,
    st.last_name,
    g.grade_value,
    g.exam_call
FROM v_students st
LEFT JOIN grades g ON st.student_id = g.student_id;





-- GROUP BY:    SELECT columna_grupo, FUNCION(col) AS alias FROM tabla WHERE condiciones GROUP BY columna_grupo;
-- CON HAVING:  SELECT columna_grupo, FUNCION(col) AS alias FROM tabla WHERE condiciones GROUP BY columna_grupo HAVING FUNCION(col) condicion;

-- 43
SELECT 
    st.first_name,
    st.last_name,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name;

-- 44 
SELECT 
    st.access_method,
    COUNT(*) AS total_students
FROM students st
GROUP BY st.access_method;

-- 45
SELECT 
    d.degree_name,
    COUNT(*) AS total_subjects
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
GROUP BY d.degree_id, d.degree_name;

-- 46
SELECT 
    s.subject_name,
    s.acronym,
    COUNT(*) AS total_groups
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
GROUP BY s.subject_id, s.subject_name, s.acronym;

-- 47
SELECT 
    g.exam_call,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM grades g
GROUP BY g.exam_call;

-- 48 
SELECT 
    s.subject_name,
    g.exam_call,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM grades g
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
GROUP BY s.subject_id, s.subject_name, g.exam_call
ORDER BY s.subject_name, g.exam_call;

-- 49 COUNT DISTINCT
SELECT 
    gr.academic_year,
    COUNT(DISTINCT ge.student_id) AS total_students   -- Cuenta cuántos valores únicos (sin repetir) hay en cada grupo
FROM groups gr
JOIN students_groups ge ON gr.group_id = ge.group_id
GROUP BY gr.academic_year
ORDER BY gr.academic_year DESC;

-- 50
SELECT 
    pr.first_name,
    pr.last_name,
    pr.category,
    SUM(tl.credits) AS total_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name, pr.category;






-- HAVING: filtro

-- SELECT group_id, AVG(grade_value) AS media
-- FROM grades
-- GROUP BY group_id         -- 1. Hace un montón por cada grupo y calcula su media
-- HAVING AVG(grade_value) >= 5; -- 2. Se queda SOLO con los grupos cuya media sea 5 o más

-- 51
SELECT 
    st.first_name,
    st.last_name,
    AVG(g.grade_value) AS average_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
HAVING AVG(g.grade_value) > 7;

-- 52
SELECT 
    s.subject_name,
    COUNT(*) AS total_groups
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
GROUP BY s.subject_id, s.subject_name
HAVING COUNT(*) > 3;

-- 53
SELECT 
    gr.group_name,
    gr.activity,
    COUNT(*) AS total_students
FROM groups gr
JOIN students_groups ge ON gr.group_id = ge.group_id
GROUP BY gr.group_id, gr.group_name, gr.activity
HAVING COUNT(*) > 15;

-- 54
SELECT 
    s.subject_name,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
GROUP BY s.subject_id, s.subject_name
HAVING AVG(g.grade_value) > 5.5;







-- CONSULTAS COMPLEJAS

-- 55
SELECT 
    s.subject_name,
    COUNT(DISTINCT ge.student_id) AS total_students
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN students_groups ge ON gr.group_id = ge.group_id
WHERE gr.academic_year = 2024
GROUP BY s.subject_id, s.subject_name
ORDER BY total_students DESC, s.subject_name ASC
LIMIT 3;
-- Secuencia: FROM → WHERE → GROUP BY → ORDER BY → LIMIT

-- 56
SELECT 
    st.first_name,
    st.last_name,
    COUNT(*) AS total_honors
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
WHERE g.with_honors = 1
GROUP BY st.student_id, st.first_name, st.last_name
HAVING COUNT(*) > 1;

-- 57
SELECT 
    d.degree_name,
    COUNT(DISTINCT ge.student_id) AS total_students
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN students_groups ge ON gr.group_id = ge.group_id
WHERE gr.academic_year = 2024
GROUP BY d.degree_id, d.degree_name
ORDER BY COUNT(DISTINCT ge.student_id) DESC;
-- Secuencia: FROM → WHERE → GROUP BY → ORDER BY

-- 58
SELECT 
    st.first_name,
    st.last_name,
    MAX(g.grade_value) AS max_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
ORDER BY MAX(g.grade_value) DESC;

-- 59
SELECT 
    pr.first_name,
    pr.last_name,
    COUNT(DISTINCT tl.group_id) AS total_groups
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name
HAVING COUNT(DISTINCT tl.group_id) > 1;

-- 60
SELECT DISTINCT s.subject_name, d.degree_name
FROM subjects s
JOIN degrees d ON s.degree_id = d.degree_id
WHERE d.degree_id IN (
    SELECT degree_id
    FROM subjects
    GROUP BY degree_id
    HAVING COUNT(*) > 15
);