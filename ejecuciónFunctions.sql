-- Archivo creadopor mí para ejecutar los functions del laboratorio 5





-- EJ1: 

-- Usar en una consulta SELECT
SELECT f_student_average(6) AS 'Promedio del estudiante 6';

-- Usarla junto con otros datos
SELECT p.person_id, p.first_name, p.last_name,
       f_student_average(s.student_id) AS promedio
FROM people p
JOIN students s ON s.student_id = p.person_id
ORDER BY promedio DESC;

-- Usar en una cláusula WHERE
SELECT p.first_name, p.last_name
FROM people p
JOIN students s ON s.student_id = p.person_id
WHERE f_student_average(s.student_id) >= 7.0;

-- EJ2:

-- Listar asignaturas con indicador de matrícula del estudiante 6 del grado 3
SELECT s.subject_id, s.subject_name,
       f_is_student_enrolled(6, s.subject_id) AS matriculado
FROM subjects s
WHERE s.degree_id = 3;

-- Usar en un WHERE
SELECT s.subject_name
FROM subjects s
WHERE f_is_student_enrolled(6, s.subject_id) = TRUE;

-- EJ3: 
-- Verificar si la asignatura 1 ya tiene el máximo de grupos de teoría en 2025
SELECT f_subject_group_limit_reached(1, 'Teoría', 2025) AS 'Límite alcanzado';

-- Listar asignaturas que han alcanzado el límite de grupos de teoría
SELECT s.subject_id, s.subject_name, s.acronym
FROM subjects s
WHERE f_subject_group_limit_reached(s.subject_id, 'Teoría', 2025) = TRUE;

