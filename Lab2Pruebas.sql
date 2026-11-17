-- EL LABORATORIO " NO PIDE CREAR ESTE DOCUMENTO 

-- Tabla People

-- Prueba 1: Edad fuera de rango
INSERT INTO people (dni, first_name, last_name, age, email)
VALUES ('99999999Z', 'Juan', 'Test', 15, 'juan@test.es');
-- Error esperado: Check constraint 'ck_people_rn12_age' is violated

-- Prueba 2: DNI duplicado
INSERT INTO people (dni, first_name, last_name, age, email)
VALUES ('88888888A', 'Ana', 'Test', 25, 'ana@test.es');
INSERT INTO people (dni, first_name, last_name, age, email)
VALUES ('88888888A', 'Pedro', 'Test', 30, 'pedro@test.es');
-- Error esperado: Duplicate entry '88888888A' for key 'uq_people_dni'


-- Tabla professors
INSERT INTO people (person_id, dni, first_name, last_name, age, email)
VALUES (1000, '11111111A', 'Carlos', 'Profesor', 45, 'carlos@us.es');
INSERT INTO professors (professor_id, category)
VALUES (1000, 'Adjunto');

-- Tabla persona
INSERT INTO people (person_id, dni, first_name, last_name, age, email)
VALUES (2000, '22222222B', 'María', 'Estudiante', 20, 'maria@us.es');
INSERT INTO students (student_id, access_method)
VALUES (2000, 'Erasmus');

-- Tabla students
INSERT INTO people (person_id, dni, first_name, last_name, age, email)
VALUES (2000, '22222222B', 'María', 'Estudiante', 20, 'maria@us.es');
INSERT INTO students (student_id, access_method)
VALUES (2000, 'Erasmus');

-- Tabla degrees 
INSERT INTO degrees (degree_name, duration_years)
VALUES ('Grado en Pruebas', 2);
-- Error esperado: Check constraint 'ck_degrees_rn13_duration' is violated

-- Tabla subjects
INSERT INTO subjects (degree_id, subject_name, acronym, credits, course, subject_type)
VALUES (1, 'Asignatura Test', 'TST', 8, 1, 'Obligatoria');

-- Tabla groups 
INSERT INTO groups (subject_id, group_name, activity, academic_year)
VALUES (1, 'T1', 'Teoría', 1999);

-- Tabla teaching_loads
INSERT INTO teaching_loads (professor_id, group_id, credits)
VALUES (1, 1, 0);

-- Tabla grades
INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
VALUES (1, 1, 8.5, 'Primera', 1);




-- Modificación y borrado de datos: UPDATE y DELETE

-- ACTUALIZAR DATOS UPDATE:

-- UPDATE nombre_tabla
-- SET columna1 = valor1, columna2 = valor2, ...
-- WHERE condición;

-- 1 Cambiar email de una persona:
UPDATE people                       -- Actulizo un dato en la tabla people
SET email = 'nuevo.email@us.es'     -- Cambio el dato email 
WHERE person_id = 1;                -- Donde person_id sea igual a 1

-- 2 Incrementar duración de todos los grados
UPDATE degrees
SET duration_years = duration_years + 1;

-- 3 Cambiar de 'AyudanteDoctor' a category = 'Titular'
UPDATE professors
SET category = 'Titular'
WHERE category = 'AyudanteDoctor';

-- ELIMINAR DATOS DELETE:

-- DELETE FROM nombre_tabla
-- WHERE condición;

-- 1 Borrar 
