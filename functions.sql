USE grades_db;

DELIMITER //

-- RN04
CREATE OR REPLACE FUNCTION f_student_group_limit(
    p_student_id INT,
    p_subject_id INT,
    p_activity VARCHAR(15)
)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM students_groups ge
    JOIN `groups` g ON g.group_id = ge.group_id
    WHERE ge.student_id = p_student_id
      AND g.subject_id = p_subject_id
      AND g.activity = p_activity;
    RETURN v_count >= 1;
END//

-- RN07
CREATE OR REPLACE FUNCTION f_is_student_enrolled(
    p_student_id INT,
    p_subject_id INT
)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_exists INT;
    SELECT COUNT(*) INTO v_exists
    FROM students_subjects
    WHERE student_id = p_student_id
      AND subject_id = p_subject_id;
    RETURN v_exists > 0;
END//

-- RN06
CREATE OR REPLACE FUNCTION f_subject_group_limit_reached(
    p_subject_id INT,
    p_activity VARCHAR(15),
    p_academic_year YEAR
)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    DECLARE v_result BOOLEAN DEFAULT FALSE;

    SELECT COUNT(*) INTO v_count
    FROM `groups`
    WHERE subject_id = p_subject_id
      AND activity = p_activity
      AND academic_year = p_academic_year;

    IF p_activity = 'Teoría' THEN
        SET v_result = (v_count >= 1);
    ELSEIF p_activity = 'Laboratorio' THEN
        SET v_result = (v_count >= 2);
    END IF;

    RETURN v_result;
END//

-- Nota media del alumno (0 si no tiene notas)
CREATE OR REPLACE FUNCTION f_student_average(
    p_student_id INT
) RETURNS DECIMAL(4,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_average DECIMAL(4,2) DEFAULT 0;
    SELECT COALESCE(AVG(grade_value), 0) INTO v_average
    FROM grades
    WHERE student_id = p_student_id;
    RETURN v_average;
END//

-- EJERCICIO 1: nº de notas de un estudiante en una convocatoria
CREATE OR REPLACE FUNCTION f_count_student_grades(
    p_student_id INT,
    p_exam_call VARCHAR(20)
) RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT DEFAULT 0;
    SELECT COUNT(*) INTO v_count
    FROM grades
    WHERE student_id = p_student_id
      AND exam_call = p_exam_call;
    RETURN v_count;
END//

-- EJERCICIO 2: créditos totales impartidos por un profesor
CREATE OR REPLACE FUNCTION f_professor_total_credits(
    p_professor_id INT
) RETURNS DECIMAL(6,1)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(6,1) DEFAULT 0;
    SELECT COALESCE(SUM(credits), 0) INTO v_total
    FROM teaching_loads
    WHERE professor_id = p_professor_id;
    RETURN v_total;
END//

DELIMITER ;