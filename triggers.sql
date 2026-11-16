--
-- Autor: [Tu nombre]
-- Fecha: [mes y año]
-- Descripción: Triggers de integridad para grades_db (L5)
--   Requiere haber ejecutado antes functions.sql
--
USE grades_db;

DELIMITER //
-- ============================================================
-- RN02: Un alumno solo puede tener notas en grupos a los que pertenece
-- ============================================================
CREATE OR REPLACE TRIGGER t_bi_grades_rn02
BEFORE INSERT ON grades
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM students_groups
    WHERE student_id = NEW.student_id AND group_id = NEW.group_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN02: El alumno no pertenece al grupo indicado';
    END IF;
END//

CREATE OR REPLACE TRIGGER t_bu_grades_rn02
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM students_groups
    WHERE student_id = NEW.student_id AND group_id = NEW.group_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN02: El alumno no pertenece al grupo indicado';
    END IF;
END//

-- ============================================================
-- RN03: Un grupo no puede tener más de 2 profesores
-- ============================================================
CREATE OR REPLACE TRIGGER t_bi_teaching_loads_rn03
BEFORE INSERT ON teaching_loads
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM teaching_loads
    WHERE group_id = NEW.group_id AND professor_id <> NEW.professor_id;
    IF v_count >= 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN03: Un grupo no puede tener más de 2 profesores';
    END IF;
END//

CREATE OR REPLACE TRIGGER t_bu_teaching_loads_rn03
BEFORE UPDATE ON teaching_loads
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM teaching_loads
    WHERE group_id = NEW.group_id AND professor_id <> NEW.professor_id;
    IF v_count >= 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN03: Un grupo no puede tener más de 2 profesores';
    END IF;
END//

-- ============================================================
-- RN04 + RN07: Límite de grupos por actividad y matrícula previa
-- ============================================================
CREATE OR REPLACE TRIGGER t_bi_students_groups_rn04_rn07
BEFORE INSERT ON students_groups
FOR EACH ROW
BEGIN
    DECLARE v_subject_id INT;
    DECLARE v_activity VARCHAR(15);
    SELECT subject_id, activity INTO v_subject_id, v_activity FROM `groups` WHERE group_id = NEW.group_id;
    
    IF NOT f_is_student_enrolled(NEW.student_id, v_subject_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN07: El alumno no está matriculado en la asignatura';
    END IF;
    
    IF f_student_group_limit(NEW.student_id, v_subject_id, v_activity) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN04: El alumno ya pertenece a un grupo de esa actividad';
    END IF;
END//

CREATE OR REPLACE TRIGGER t_bu_students_groups_rn04_rn07
BEFORE UPDATE ON students_groups
FOR EACH ROW
BEGIN
    DECLARE v_subject_id INT;
    DECLARE v_activity VARCHAR(15);
    -- Solo validar si cambia el grupo o el alumno
    IF NEW.group_id <> OLD.group_id OR NEW.student_id <> OLD.student_id THEN
        SELECT subject_id, activity INTO v_subject_id, v_activity FROM `groups` WHERE group_id = NEW.group_id;
        
        IF NOT f_is_student_enrolled(NEW.student_id, v_subject_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN07: El alumno no está matriculado en la asignatura';
        END IF;
        
        IF f_student_group_limit(NEW.student_id, v_subject_id, v_activity) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN04: El alumno ya pertenece a un grupo de esa actividad';
        END IF;
    END IF;
END//

-- ============================================================
-- RN05: No se puede modificar una nota en más de 4 puntos
-- ============================================================
CREATE OR REPLACE TRIGGER t_bu_grades_rn05
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    IF ABS(NEW.grade_value - OLD.grade_value) > 4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN05: No se puede modificar la nota en más de 4 puntos';
    END IF;
END//

-- ============================================================
-- RN06: Máximo 1 teoría / 2 laboratorios por asignatura y año
-- ============================================================
CREATE OR REPLACE TRIGGER t_bi_groups_rn06
BEFORE INSERT ON `groups`
FOR EACH ROW
BEGIN
    IF f_subject_group_limit_reached(NEW.subject_id, NEW.activity, NEW.academic_year) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN06: La asignatura ya tiene el máximo de grupos de esa actividad y año';
    END IF;
END//

CREATE OR REPLACE TRIGGER t_bu_groups_rn06
BEFORE UPDATE ON `groups`
FOR EACH ROW
BEGIN
    IF (NEW.subject_id <> OLD.subject_id OR NEW.activity <> OLD.activity OR NEW.academic_year <> OLD.academic_year) 
       AND f_subject_group_limit_reached(NEW.subject_id, NEW.activity, NEW.academic_year) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN06: La asignatura ya tiene el máximo de grupos de esa actividad y año';
    END IF;
END//

-- ============================================================
-- RN08: Selectividad exige al menos 16 años
-- ============================================================
CREATE OR REPLACE TRIGGER t_bi_students_rn08
BEFORE INSERT ON students
FOR EACH ROW
BEGIN
    DECLARE v_age TINYINT;
    IF NEW.access_method = 'Selectividad' THEN
        SELECT age INTO v_age FROM people WHERE person_id = NEW.student_id;
        IF v_age < 16 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN08: No se puede acceder por Selectividad con menos de 16 años';
        END IF;
    END IF;
END//

CREATE OR REPLACE TRIGGER t_bu_students_rn08
BEFORE UPDATE ON students
FOR EACH ROW
BEGIN
    DECLARE v_age TINYINT;
    IF NEW.access_method = 'Selectividad' THEN
        SELECT age INTO v_age FROM people WHERE person_id = NEW.student_id;
        IF v_age < 16 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN08: No se puede acceder por Selectividad con menos de 16 años';
        END IF;
    END IF;
END//

-- ============================================================
-- RN17: Sin notas duplicadas por asignatura+convocatoria+año
-- ============================================================
CREATE OR REPLACE TRIGGER t_bi_grades_rn17
BEFORE INSERT ON grades
FOR EACH ROW
BEGIN
    DECLARE v_subject_id INT;
    DECLARE v_year YEAR;
    DECLARE v_count INT;
    SELECT subject_id, academic_year INTO v_subject_id, v_year FROM `groups` WHERE group_id = NEW.group_id;
    
    SELECT COUNT(*) INTO v_count FROM grades g JOIN `groups` gr ON g.group_id = gr.group_id
    WHERE g.student_id = NEW.student_id AND g.exam_call = NEW.exam_call
      AND gr.subject_id = v_subject_id AND gr.academic_year = v_year;
      
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN17: Ya existe una nota del alumno en esa asignatura y convocatoria';
    END IF;
END//

CREATE OR REPLACE TRIGGER t_bu_grades_rn17
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    DECLARE v_subject_id INT;
    DECLARE v_year YEAR;
    DECLARE v_count INT;
    SELECT subject_id, academic_year INTO v_subject_id, v_year FROM `groups` WHERE group_id = NEW.group_id;
    
    SELECT COUNT(*) INTO v_count FROM grades g JOIN `groups` gr ON g.group_id = gr.group_id
    WHERE g.student_id = NEW.student_id AND g.exam_call = NEW.exam_call
      AND gr.subject_id = v_subject_id AND gr.academic_year = v_year
      AND g.grade_id <> OLD.grade_id; -- Excluir la nota actual
      
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN17: Ya existe una nota del alumno en esa asignatura y convocatoria';
    END IF;
END//

DELIMITER ;;