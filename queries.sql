USE GradesDB;

-- ============================================================
-- SELECT: La consulta básica
-- ============================================================

-- Consulta 1: Todas las asignaturas
SELECT * FROM subjects;

-- Consulta 2: Asignatura con acrónimo específico
SELECT * FROM subjects s WHERE s.acronym = 'IISSI-1';

-- Consulta 3: Columnas específicas
SELECT s.subject_name, s.acronym FROM subjects s;

-- Consulta 4: Filtrado por tipo
SELECT s.subject_name, s.acronym, s.subject_type
FROM subjects s
WHERE s.subject_type = 'Formación Básica';

-- ============================================================
-- JOIN: Relacionando tablas
-- ============================================================

-- Consulta 5
SELECT p.first_name, p.last_name, st.access_method
FROM students st
JOIN people p ON st.student_id = p.person_id
WHERE st.access_method = 'Selectividad';

-- Consulta 6
SELECT p.first_name, p.last_name, pr.category
FROM professors pr
JOIN people p ON pr.professor_id = p.person_id
WHERE pr.category = 'Catedrático';

-- ============================================================
-- Vistas: Simplificando consultas complejas
-- ============================================================

CREATE OR REPLACE VIEW v_professors AS
SELECT pr.professor_id, pr.category, p.person_id, p.dni,
       p.first_name, p.last_name, p.age, p.email
FROM professors pr
JOIN people p ON pr.professor_id = p.person_id;

CREATE OR REPLACE VIEW v_students AS
SELECT st.student_id, st.access_method, p.person_id, p.dni,
       p.first_name, p.last_name, p.age, p.email
FROM students st
JOIN people p ON st.student_id = p.person_id;

-- ============================================================
-- Funciones agregadas
-- ============================================================

-- Consulta 7
SELECT AVG(g.grade_value) AS average_grade FROM grades g WHERE g.group_id = 1;

-- Consulta 8
SELECT SUM(s.credits) AS total_credits FROM subjects s WHERE s.degree_id = 3;

-- Consulta 9
SELECT COUNT(*) AS total_students FROM students;

-- Consulta 10
SELECT activity, COUNT(*) AS total_groups FROM `groups` GROUP BY activity;

-- Consulta 11
SELECT MAX(g.grade_value) AS max_grade FROM grades g;

-- Consulta 12
SELECT MIN(g.grade_value) AS min_grade FROM grades g;

-- ============================================================
-- Condiciones múltiples
-- ============================================================

-- Consulta 13
SELECT g.grade_id, g.grade_value, g.exam_call
FROM grades g WHERE g.grade_value < 5 OR g.grade_value > 9;

-- Consulta 14
SELECT g.grade_id, g.grade_value, g.exam_call
FROM grades g WHERE g.grade_value BETWEEN 5 AND 7;

-- Consulta 15
SELECT s.subject_name, s.credits FROM subjects s WHERE s.credits IN (6, 12);

-- Consulta 16
SELECT p.first_name, p.last_name, p.age
FROM people p WHERE p.age BETWEEN 20 AND 30;

-- ============================================================
-- DISTINCT
-- ============================================================

-- Consulta 17
SELECT DISTINCT g.group_name FROM `groups` g;

-- Consulta 18
SELECT DISTINCT s.subject_type FROM subjects s;

-- Consulta 19
SELECT DISTINCT g.academic_year FROM `groups` g ORDER BY g.academic_year DESC;

-- ============================================================
-- Subconsultas
-- ============================================================

-- Consulta 20
SELECT MAX(g.grade_value) AS max_grade FROM grades g WHERE g.student_id = 6;

-- Consulta 21
SELECT DISTINCT ge.student_id
FROM group_enrollments ge
WHERE ge.group_id IN (
    SELECT g.group_id FROM `groups` g WHERE g.academic_year = 2024
);

-- Consulta 22
SELECT s.subject_name, s.credits
FROM subjects s
WHERE s.credits > (SELECT AVG(credits) FROM subjects);

-- ============================================================
-- Patrones con LIKE
-- ============================================================

-- Consulta 23
SELECT p.first_name, p.last_name, p.dni FROM people p WHERE p.dni LIKE '%A';

-- Consulta 24
SELECT s.subject_name FROM subjects s WHERE s.subject_name LIKE 'Fundamentos%';

-- Consulta 25
SELECT p.first_name, p.last_name FROM people p WHERE p.first_name LIKE '_____';

-- ============================================================
-- Filtrado por fechas y años
-- ============================================================

-- Consulta 26
SELECT g.group_name, g.activity, g.academic_year
FROM `groups` g WHERE g.academic_year = 2024;

-- Consulta 27
SELECT g.group_name, g.activity, g.academic_year
FROM `groups` g
WHERE g.academic_year BETWEEN 2020 AND 2023
ORDER BY g.academic_year;

-- ============================================================
-- Vistas complejas
-- ============================================================

CREATE OR REPLACE VIEW v_grades_with_honors AS
SELECT g.grade_id, g.student_id, g.group_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.with_honors = 1;

CREATE OR REPLACE VIEW v_student_grades AS
SELECT p.person_id, p.first_name, p.last_name, p.dni,
       g.grade_value, g.exam_call, g.with_honors,
       gr.group_name, gr.activity, gr.academic_year,
       s.subject_name, s.acronym, s.credits
FROM people p
JOIN students st ON p.person_id = st.student_id
JOIN grades g ON st.student_id = g.student_id
JOIN `groups` gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

CREATE OR REPLACE VIEW v_professor_loads AS
SELECT p.person_id, p.first_name, p.last_name, pr.category,
       tl.credits AS teaching_credits,
       gr.group_name, gr.activity, gr.academic_year,
       s.subject_name, s.acronym
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN `groups` gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

CREATE OR REPLACE VIEW v_degree_students AS
SELECT DISTINCT d.degree_id, d.degree_name,
       p.person_id, p.first_name, p.last_name,
       st.access_method, gr.academic_year
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN `groups` gr ON s.subject_id = gr.subject_id
JOIN group_enrollments ge ON gr.group_id = ge.group_id
JOIN students st ON ge.student_id = st.student_id
JOIN people p ON st.student_id = p.person_id;

-- Consulta 28
SELECT COUNT(*) AS total_honors FROM v_grades_with_honors;

-- Consulta 29 (sin el ';' extra que traía el enunciado)
SELECT v.first_name, v.last_name, AVG(v.grade_value) AS average_grade
FROM v_student_grades v
GROUP BY v.person_id, v.first_name, v.last_name;

-- ============================================================
-- ORDER BY, LIMIT y OFFSET
-- ============================================================

-- Consulta 30
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g ORDER BY g.grade_value ASC;

-- Consulta 31
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g ORDER BY g.grade_value DESC;

-- Consulta 32
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g ORDER BY g.grade_value DESC LIMIT 5;

-- Consulta 33
SELECT st.first_name, st.last_name, g.grade_value, g.exam_call
FROM grades g
JOIN v_students st ON g.student_id = st.student_id
WHERE g.grade_value >= 5
ORDER BY st.last_name ASC, st.first_name ASC;

-- Consulta 34
SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g ORDER BY g.grade_value DESC LIMIT 5 OFFSET 5;

-- Consulta 35
SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g ORDER BY g.grade_value DESC LIMIT 5 OFFSET 10;

-- Consulta 36
SELECT g.group_name, g.activity, g.academic_year
FROM `groups` g
ORDER BY g.academic_year DESC, g.group_name ASC;

-- ============================================================
-- JOIN avanzados
-- ============================================================

-- Consulta 37
SELECT st.first_name, st.last_name, gr.group_name, gr.activity, gr.academic_year
FROM v_students st
JOIN group_enrollments ge ON st.student_id = ge.student_id
JOIN `groups` gr ON ge.group_id = gr.group_id;

-- Consulta 38
SELECT d.degree_name, s.subject_name, s.acronym, s.credits, s.course, s.subject_type
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
ORDER BY d.degree_name, s.course;

-- Consulta 39
SELECT st.first_name, st.last_name, s.subject_name, s.acronym,
       g.grade_value, g.exam_call, gr.academic_year
FROM grades g
JOIN v_students st ON g.student_id = st.student_id
JOIN `groups` gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- Consulta 40
SELECT pr.first_name, pr.last_name, pr.category,
       s.subject_name, gr.group_name, gr.activity,
       tl.credits AS teaching_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN `groups` gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- Consulta 41
SELECT DISTINCT st.first_name, st.last_name, s.subject_name, s.acronym, gr.academic_year
FROM v_students st
JOIN group_enrollments ge ON st.student_id = ge.student_id
JOIN `groups` gr ON ge.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
ORDER BY st.last_name, s.subject_name;

-- Consulta 42
SELECT st.first_name, st.last_name, g.grade_value, g.exam_call
FROM v_students st
LEFT JOIN grades g ON st.student_id = g.student_id;

-- ============================================================
-- GROUP BY
-- ============================================================

-- Consulta 43
SELECT st.first_name, st.last_name,
       AVG(g.grade_value) AS average_grade, COUNT(*) AS total_grades
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name;

-- Consulta 44
SELECT st.access_method, COUNT(*) AS total_students
FROM students st GROUP BY st.access_method;

-- Consulta 45
SELECT d.degree_name, COUNT(*) AS total_subjects
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
GROUP BY d.degree_id, d.degree_name;

-- Consulta 46
SELECT s.subject_name, s.acronym, COUNT(*) AS total_groups
FROM subjects s
JOIN `groups` gr ON s.subject_id = gr.subject_id
GROUP BY s.subject_id, s.subject_name, s.acronym;

-- Consulta 47
SELECT g.exam_call, AVG(g.grade_value) AS average_grade, COUNT(*) AS total_grades
FROM grades g GROUP BY g.exam_call;

-- Consulta 48
SELECT s.subject_name, g.exam_call,
       AVG(g.grade_value) AS average_grade, COUNT(*) AS total_grades
FROM grades g
JOIN `groups` gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
GROUP BY s.subject_id, s.subject_name, g.exam_call
ORDER BY s.subject_name, g.exam_call;

-- Consulta 49
SELECT gr.academic_year, COUNT(DISTINCT ge.student_id) AS total_students
FROM `groups` gr
JOIN group_enrollments ge ON gr.group_id = ge.group_id
GROUP BY gr.academic_year
ORDER BY gr.academic_year DESC;

-- Consulta 50
SELECT pr.first_name, pr.last_name, pr.category, SUM(tl.credits) AS total_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name, pr.category;

-- ============================================================
-- HAVING
-- ============================================================

-- Consulta 51
SELECT st.first_name, st.last_name, AVG(g.grade_value) AS average_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
HAVING AVG(g.grade_value) > 7;

-- Consulta 52
SELECT s.subject_name, COUNT(*) AS total_groups
FROM subjects s
JOIN `groups` gr ON s.subject_id = gr.subject_id
GROUP BY s.subject_id, s.subject_name
HAVING COUNT(*) > 3;

-- Consulta 53
SELECT gr.group_name, gr.activity, COUNT(*) AS total_students
FROM `groups` gr
JOIN group_enrollments ge ON gr.group_id = ge.group_id
GROUP BY gr.group_id, gr.group_name, gr.activity
HAVING COUNT(*) > 15;

-- Consulta 54
SELECT s.subject_name, AVG(g.grade_value) AS average_grade, COUNT(*) AS total_grades
FROM subjects s
JOIN `groups` gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
GROUP BY s.subject_id, s.subject_name
HAVING AVG(g.grade_value) > 5.5;

-- ============================================================
-- Consultas complejas combinadas
-- ============================================================

-- Consulta 55
SELECT s.subject_name, COUNT(DISTINCT ge.student_id) AS total_students
FROM subjects s
JOIN `groups` gr ON s.subject_id = gr.subject_id
JOIN group_enrollments ge ON gr.group_id = ge.group_id
WHERE gr.academic_year = 2024
GROUP BY s.subject_id, s.subject_name
ORDER BY total_students DESC, s.subject_name ASC
LIMIT 3;

-- Consulta 56
SELECT st.first_name, st.last_name, COUNT(*) AS total_honors
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
WHERE g.with_honors = 1
GROUP BY st.student_id, st.first_name, st.last_name
HAVING COUNT(*) > 1;

-- Consulta 57
SELECT d.degree_name, COUNT(DISTINCT ge.student_id) AS total_students
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN `groups` gr ON s.subject_id = gr.subject_id
JOIN group_enrollments ge ON gr.group_id = ge.group_id
WHERE gr.academic_year = 2024
GROUP BY d.degree_id, d.degree_name
ORDER BY COUNT(DISTINCT ge.student_id) DESC;

-- Consulta 58
SELECT st.first_name, st.last_name, MAX(g.grade_value) AS max_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
ORDER BY MAX(g.grade_value) DESC;

-- Consulta 59
SELECT pr.first_name, pr.last_name, COUNT(DISTINCT tl.group_id) AS total_groups
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name
HAVING COUNT(DISTINCT tl.group_id) > 1;

-- Consulta 60
SELECT DISTINCT s.subject_name, d.degree_name
FROM subjects s
JOIN degrees d ON s.degree_id = d.degree_id
WHERE d.degree_id IN (
    SELECT degree_id FROM subjects
    GROUP BY degree_id HAVING COUNT(*) > 15
);

-- ============================================================
-- EJERCICIOS PROPUESTOS
-- ============================================================

-- 1. Estudiantes que nunca han suspendido
SELECT st.student_id, st.first_name, st.last_name, MIN(g.grade_value) AS min_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
HAVING MIN(g.grade_value) >= 5
ORDER BY st.last_name, st.first_name;

-- 2. Profesores que solo imparten teoría
SELECT p.professor_id, p.first_name, p.last_name
FROM v_professors p
JOIN teaching_loads tl ON p.professor_id = tl.professor_id
JOIN `groups` gr ON tl.group_id = gr.group_id
GROUP BY p.professor_id, p.first_name, p.last_name
HAVING SUM(gr.activity = 'Laboratorio') = 0
ORDER BY p.last_name, p.first_name;

-- 3. Asignaturas sin grupos creados
SELECT s.subject_id, s.subject_name, s.acronym
FROM subjects s
LEFT JOIN `groups` gr ON s.subject_id = gr.subject_id
WHERE gr.group_id IS NULL
ORDER BY s.subject_name;

-- 4. Nota media de cada grado en 2024
SELECT d.degree_name, AVG(g.grade_value) AS average_grade, COUNT(*) AS total_grades
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN `groups` gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
WHERE gr.academic_year = 2024
GROUP BY d.degree_id, d.degree_name
ORDER BY average_grade DESC;

-- 5. Estudiantes con la mejor nota de cada asignatura
SELECT s.subject_id, s.subject_name, st.first_name, st.last_name, g.grade_value, g.exam_call
FROM grades g
JOIN `groups` gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
JOIN v_students st ON g.student_id = st.student_id
WHERE g.grade_value = (
    SELECT MAX(g2.grade_value)
    FROM grades g2
    JOIN `groups` gr2 ON g2.group_id = gr2.group_id
    WHERE gr2.subject_id = s.subject_id
)
ORDER BY s.subject_name, st.last_name;

-- 6. Grupos ordenados por número de estudiantes
SELECT gr.group_id, gr.group_name, gr.activity, gr.academic_year,
       COUNT(ge.student_id) AS total_students
FROM `groups` gr
LEFT JOIN group_enrollments ge ON gr.group_id = ge.group_id
GROUP BY gr.group_id, gr.group_name, gr.activity, gr.academic_year
ORDER BY total_students DESC, gr.group_name ASC;

-- 7. Profesores con carga > 15 créditos
SELECT p.professor_id, p.first_name, p.last_name, p.category,
       SUM(tl.credits) AS total_credits
FROM v_professors p
JOIN teaching_loads tl ON p.professor_id = tl.professor_id
GROUP BY p.professor_id, p.first_name, p.last_name, p.category
HAVING SUM(tl.credits) > 15
ORDER BY total_credits DESC;

-- 8. Año académico con más matrículas de honor
SELECT gr.academic_year, COUNT(*) AS total_honors
FROM grades g
JOIN `groups` gr ON g.group_id = gr.group_id
WHERE g.with_honors = 1
GROUP BY gr.academic_year
ORDER BY total_honors DESC
LIMIT 1;

-- 9. Asignaturas con mayor dispersión de notas
SELECT s.subject_id, s.subject_name, s.acronym,
       STD(g.grade_value) AS grade_std,
       VARIANCE(g.grade_value) AS grade_variance,
       COUNT(*) AS total_grades
FROM subjects s
JOIN `groups` gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
GROUP BY s.subject_id, s.subject_name, s.acronym
HAVING COUNT(*) > 1
ORDER BY grade_std DESC;

-- 10. Estudiantes matriculados en todas las asignaturas de primer curso
SELECT st.student_id, st.first_name, st.last_name
FROM v_students st
JOIN subject_enrollments se ON st.student_id = se.student_id
JOIN subjects s ON se.subject_id = s.subject_id
WHERE s.course = 1
GROUP BY st.student_id, st.first_name, st.last_name
HAVING COUNT(DISTINCT se.subject_id) = (
    SELECT COUNT(*) FROM subjects WHERE course = 1
)
ORDER BY st.last_name, st.first_name;