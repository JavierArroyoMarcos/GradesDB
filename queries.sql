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