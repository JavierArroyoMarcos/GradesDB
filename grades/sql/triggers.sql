--
-- Autor: Javier Arroyo Marcos
-- Fecha: 22/11
-- Descripción: TRIGGERS
-- Se incluye en: Lab 5
--

-- NO HACE FALTA LLAMARLOS

-- Pueden ser ejecutado antes(BEFORE): Validar datos, Cancelar datos(SIGNAL), Modificar valores(NEW)
--  o después(AFTER) de un evento: Acciones dependen de listas ya escrita, Acciones dependen de fila ya guardad, Actualizar tablas, Validar si lanza un error

-- Acceso a valores nuevos(NEW) o antiguos(OLD)

-- Errores con SIGNAL


-- SINTAXIS
-- DELIMITER //
-- CREATE OR REPLACE TRIGGER nombre_trigger
-- {BEFORE | AFTER} {INSERT | UPDATE | DELETE | INSERT OR UPDATE} ON nombre_tabla
-- FOR EACH ROW
-- BEGIN
--     -- Código del trigger
--     -- Puede usar NEW.columna (valor nuevo)
--     -- Puede usar OLD.columna (valor antiguo en UPDATE/DELETE)
-- END //
-- DELIMITER ;



DELIMITER //

-- TRIGGERS DE GRADES_DB -------------------------------------------------------------------

DELIMITER //

-- RN08: un alumno que accede por Selectividad debe tener al menos 16 años
CREATE OR REPLACE TRIGGER t_bi_students_rn08
BEFORE INSERT ON students
FOR EACH ROW
BEGIN
    DECLARE v_age TINYINT;
    IF NEW.access_method = 'Selectividad' THEN
        SELECT age INTO v_age FROM people WHERE person_id = NEW.student_id;
        IF v_age < 16 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'RN08: No se puede acceder por Selectividad con menos de 16 años';
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
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'RN08: No se puede acceder por Selectividad con menos de 16 años';
        END IF;
    END IF;
END//

-- RN02: un alumno solo puede tener notas en los grupos a los que pertenece
CREATE OR REPLACE TRIGGER t_bi_grades_rn02
BEFORE INSERT ON grades
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM students_groups
    WHERE student_id = NEW.student_id AND group_id = NEW.group_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN02: El alumno no pertenece al grupo indicado';
    END IF;
END//

CREATE OR REPLACE TRIGGER t_bu_grades_rn02
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM students_groups
    WHERE student_id = NEW.student_id AND group_id = NEW.group_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN02: El alumno no pertenece al grupo indicado';
    END IF;
END//

-- RN17: no más de una nota para la misma asignatura, convocatoria y año académico
CREATE OR REPLACE TRIGGER t_bi_grades_rn17
BEFORE INSERT ON grades
FOR EACH ROW
BEGIN
    DECLARE v_subject_id INT;
    DECLARE v_academic_year YEAR;
    DECLARE v_exists INT;

    SELECT subject_id, academic_year INTO v_subject_id, v_academic_year
    FROM groups WHERE group_id = NEW.group_id;

    SELECT COUNT(*) INTO v_exists
    FROM grades g
    JOIN groups gr ON gr.group_id = g.group_id
    WHERE g.student_id = NEW.student_id
      AND g.exam_call = NEW.exam_call
      AND gr.subject_id = v_subject_id
      AND gr.academic_year = v_academic_year;

    IF v_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN17: Ya existe una nota para la misma asignatura, convocatoria y año académico';
    END IF;
END//

CREATE OR REPLACE TRIGGER t_bu_grades_rn17
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    DECLARE v_subject_id INT;
    DECLARE v_academic_year YEAR;
    DECLARE v_exists INT;

    SELECT subject_id, academic_year INTO v_subject_id, v_academic_year
    FROM groups WHERE group_id = NEW.group_id;

    SELECT COUNT(*) INTO v_exists
    FROM grades g
    JOIN groups gr ON gr.group_id = g.group_id
    WHERE g.student_id = NEW.student_id
      AND g.exam_call = NEW.exam_call
      AND gr.subject_id = v_subject_id
      AND gr.academic_year = v_academic_year
      AND g.grade_id <> NEW.grade_id;

    IF v_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN17: Ya existe una nota para la misma asignatura, convocatoria y año académico';
    END IF;
END//

-- RN05: una nota no puede modificarse en más de 4 puntos
CREATE OR REPLACE TRIGGER t_bu_grades_rn05
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    IF ABS(NEW.grade_value - OLD.grade_value) > 4 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN05: No se puede modificar la nota en más de 4 puntos';
    END IF;
END//

-- RN03: un grupo no puede tener más de 2 profesores
CREATE OR REPLACE TRIGGER t_bi_teaching_loads_rn03
BEFORE INSERT ON teaching_loads
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM teaching_loads WHERE group_id = NEW.group_id;

    IF v_count >= 2 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN03: El grupo ya tiene 2 profesores asignados';
    END IF;
END//

CREATE OR REPLACE TRIGGER t_bu_teaching_loads_rn03
BEFORE UPDATE ON teaching_loads
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    IF NOT (NEW.group_id <=> OLD.group_id) THEN
        SELECT COUNT(*) INTO v_count
        FROM teaching_loads WHERE group_id = NEW.group_id;

        IF v_count >= 2 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'RN03: El grupo ya tiene 2 profesores asignados';
        END IF;
    END IF;
END//

-- RN07 y RN04 en students_groups
CREATE OR REPLACE TRIGGER t_bi_students_groups_rn04_rn07
BEFORE INSERT ON students_groups
FOR EACH ROW
BEGIN
    DECLARE v_subject_id INT;
    DECLARE v_activity VARCHAR(15);

    SELECT subject_id, activity INTO v_subject_id, v_activity
    FROM groups WHERE group_id = NEW.group_id;

    IF NOT f_is_student_enrolled(NEW.student_id, v_subject_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN07: El alumno debe estar matriculado en la asignatura';
    END IF;

    IF f_student_group_limit(NEW.student_id, v_subject_id, v_activity) THEN
        IF v_activity = 'Teoría' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'RN04: Solo puede haber un grupo de teoría por asignatura y alumno';
        ELSE
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'RN04: Solo puede haber un grupo de laboratorio por asignatura y alumno';
        END IF;
    END IF;
END//

CREATE OR REPLACE TRIGGER t_bu_students_groups_rn04_rn07
BEFORE UPDATE ON students_groups
FOR EACH ROW
BEGIN
    DECLARE v_subject_id INT;
    DECLARE v_activity VARCHAR(15);
    DECLARE v_old_subject_id INT;
    DECLARE v_old_activity VARCHAR(15);

    SELECT subject_id, activity INTO v_subject_id, v_activity
    FROM groups WHERE group_id = NEW.group_id;

    SELECT subject_id, activity INTO v_old_subject_id, v_old_activity
    FROM groups WHERE group_id = OLD.group_id;

    IF NOT f_is_student_enrolled(NEW.student_id, v_subject_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN07: El alumno debe estar matriculado en la asignatura';
    END IF;

    IF NOT (NEW.student_id <=> OLD.student_id
            AND v_subject_id <=> v_old_subject_id
            AND v_activity <=> v_old_activity)
       AND f_student_group_limit(NEW.student_id, v_subject_id, v_activity) THEN
        IF v_activity = 'Teoría' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'RN04: Solo puede haber un grupo de teoría por asignatura y alumno';
        ELSE
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'RN04: Solo puede haber un grupo de laboratorio por asignatura y alumno';
        END IF;
    END IF;
END//

-- RN06: máximo un grupo de teoría y dos de laboratorio por asignatura y año
CREATE OR REPLACE TRIGGER t_bi_groups_rn06
BEFORE INSERT ON groups
FOR EACH ROW
BEGIN
    IF f_subject_group_limit_reached(NEW.subject_id, NEW.activity, NEW.academic_year) THEN
        IF NEW.activity = 'Teoría' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'RN06: Solo puede existir un grupo de teoría por asignatura y año académico';
        ELSE
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'RN06: Solo pueden existir dos grupos de laboratorio por asignatura y año académico';
        END IF;
    END IF;
END//

CREATE OR REPLACE TRIGGER t_bu_groups_rn06
BEFORE UPDATE ON groups
FOR EACH ROW
BEGIN
    IF NOT (NEW.subject_id <=> OLD.subject_id
            AND NEW.activity <=> OLD.activity
            AND NEW.academic_year <=> OLD.academic_year) THEN
        IF f_subject_group_limit_reached(NEW.subject_id, NEW.activity, NEW.academic_year) THEN
            IF NEW.activity = 'Teoría' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'RN06: Solo puede existir un grupo de teoría por asignatura y año académico';
            ELSE
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'RN06: Solo pueden existir dos grupos de laboratorio por asignatura y año académico';
            END IF;
        END IF;
    END IF;
END//

DELIMITER ;