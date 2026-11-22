-- Archivo creadopor mí para ejecutar los procedures del laboratorio 4


-- Ej1: ejecuación:
-- Borrar las notas del estudiante con DNI '10000006F'
CALL p_delete_student_grades('10000006F');

-- Verificar que se borraron
SELECT * FROM grades g
JOIN students s ON s.student_id = g.student_id
JOIN people p ON p.person_id = s.student_id
WHERE p.dni = '10000006F';


-- Ej2: ejecución
-- Borrar todos los datos (¡cuidado con esta operación!)
CALL p_delete_all_data();

-- Verificar que las tablas están vacías
SELECT COUNT(*) AS total_grades FROM grades;
SELECT COUNT(*) AS total_students FROM students;
SELECT COUNT(*) AS total_people FROM people;

-- Ej3: ejecución
-- Consultar la nota media del estudiante con ID 6
CALL p_student_average(6, @avg_student_6);
SELECT @avg_student_6 AS 'Promedio del estudiante 6';

-- Consultar para varios estudiantes
CALL p_student_average(7, @avg_student_7);
CALL p_student_average(8, @avg_student_8);
SELECT @avg_student_6, @avg_student_7, @avg_student_8;

-- Ej4: ejecución
-- Ver las notas del grupo 1 antes de la actualización
SELECT g.grade_id, p.first_name, p.last_name, g.grade_value, g.exam_call
FROM grades g
JOIN students s ON s.student_id = g.student_id
JOIN people p ON p.person_id = s.student_id
WHERE g.group_id = 1 AND g.exam_call = 'Primera'
ORDER BY g.grade_value;

-- Subir las notas del grupo 1 en la convocatoria 'Primera'
CALL p_boost_group_grades(1, 'Primera');

-- Verificar las notas después de la actualización
SELECT g.grade_id, p.first_name, p.last_name, g.grade_value, g.exam_call
FROM grades g
JOIN students s ON s.student_id = g.student_id
JOIN people p ON p.person_id = s.student_id
WHERE g.group_id = 1 AND g.exam_call = 'Primera'
ORDER BY g.grade_value;



-- Ej5: Ejecución
-- Ver las notas del grupo 1 antes de asignar MH
SELECT g.grade_id, p.first_name, p.last_name, g.grade_value, 
       g.with_honors, g.exam_call
FROM grades g
JOIN students s ON s.student_id = g.student_id
JOIN people p ON p.person_id = s.student_id
WHERE g.group_id = 1 AND g.exam_call = 'Primera'
ORDER BY g.grade_value DESC;
-- Asignar matrículas de honor al grupo 1 en la convocatoria 'Primera'
CALL p_assign_honors(1, 'Primera');
-- Verificar las matrículas asignadas
SELECT g.grade_id, p.first_name, p.last_name, g.grade_value, 
       g.with_honors, g.exam_call
FROM grades g
JOIN students s ON s.student_id = g.student_id
JOIN people p ON p.person_id = s.student_id
WHERE g.group_id = 1 AND g.exam_call = 'Primera' AND g.with_honors = 1
ORDER BY g.grade_value DESC;


