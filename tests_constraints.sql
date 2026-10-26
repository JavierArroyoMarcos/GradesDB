-- Debe fallar: rn12_people_age
INSERT INTO people (dni, first_name, last_name, age, email)
VALUES ('99999999Z', 'Juan', 'Test', 15, 'juan@test.es');

-- Debe fallar: rn_uq_people_dni (DNI ya existe en populatedb)
INSERT INTO people (dni, first_name, last_name, age, email)
VALUES ('00000001A', 'Pedro', 'Test', 30, 'pedro@test.es');

-- Debe fallar: rn01_grades_with_honors
INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
VALUES (6, 1, 8.5, 'Primera', 1);

-- Debe fallar: rn15_groups_year
INSERT INTO `groups` (subject_id, group_name, activity, academic_year)
VALUES (11, 'T3', 'Teoría', 1999);