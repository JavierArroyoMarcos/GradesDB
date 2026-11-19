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
