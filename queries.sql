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