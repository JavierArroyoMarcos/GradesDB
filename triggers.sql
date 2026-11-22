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





-- TRIGGERS DE GRADES_DB -------------------------------------------------------------------

-- Ej1: RN08: un alumno que accede por Selectividad debe tener al menos 16 años
CREATE OR REPLACE TRIGGER t_biu_students_rn08
BEFORE INSERT OR UPDATE ON students
FOR EACH ROW
BEGIN
    DECLARE v_age TINYINT;
    IF NEW.access_method = 'Selectividad' THEN
        -- La edad está en people: el id del alumno es el de la persona (herencia)
        SELECT age INTO v_age FROM people WHERE person_id = NEW.student_id;
        IF v_age < 16 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'RN08: No se puede acceder por Selectividad con menos de 16 años';
        END IF;
    END IF;
END//


-- Ej2: RN02: un alumno solo puede tener notas en los grupos a los que pertenece
CREATE OR REPLACE TRIGGER t_biu_grades_rn02
BEFORE INSERT OR UPDATE ON grades
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    -- ¿Está el alumno en el grupo de la nota?
    SELECT COUNT(*) INTO v_count
    FROM students_groups
    WHERE student_id = NEW.student_id
      AND group_id = NEW.group_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN02: El alumno no pertenece al grupo indicado';
    END IF;
END//


-- Ej3: RN17: un alumno no puede tener más de una nota para la misma asignatura, convocatoria y año académico (aunque sean de grupos distintos)
CREATE OR REPLACE TRIGGER t_biu_grades_rn17
BEFORE INSERT OR UPDATE ON grades
FOR EACH ROW
BEGIN
    DECLARE v_subject_id INT;
    DECLARE v_academic_year YEAR;
    DECLARE v_exists INT;

    -- Asignatura y año académico del grupo de la nota
    SELECT subject_id, academic_year INTO v_subject_id, v_academic_year
    FROM groups
    WHERE group_id = NEW.group_id;

    -- Otras notas del alumno en esa asignatura, convocatoria y año, en cualquier grupo
    SELECT COUNT(*) INTO v_exists
    FROM grades g
    JOIN groups gr ON gr.group_id = g.group_id
    WHERE g.student_id = NEW.student_id
      AND g.exam_call = NEW.exam_call
      AND gr.subject_id = v_subject_id
      AND gr.academic_year = v_academic_year
      -- excluye la propia fila al actualizar (en INSERT, NEW.grade_id vale 0)
      AND g.grade_id <> NEW.grade_id;

    IF v_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN17: Ya existe una nota para la misma asignatura, convocatoria y año académico';
    END IF;
END//




-- Ej4: RN05: una nota no puede modificarse en más de 4 puntos (solo en UPDATE:
-- al insertar no hay valor anterior)
CREATE OR REPLACE TRIGGER t_bu_grades_rn05
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    -- ABS: cuenta igual una subida que una bajada
    IF ABS(NEW.grade_value - OLD.grade_value) > 4 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN05: No se puede modificar la nota en más de 4 puntos';
    END IF;
END//


-- Ej5: RN03: un grupo no puede tener más de 2 profesores
CREATE OR REPLACE TRIGGER t_biu_teaching_loads_rn03
BEFORE INSERT OR UPDATE ON teaching_loads
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    -- Se comprueba solo si la asignación entra en un grupo:
    -- - en INSERT, OLD.group_id vale NULL: entra siempre
    -- - en UPDATE, entra si cambia de grupo (<=> trata NULL como un valor)
    IF NOT (NEW.group_id <=> OLD.group_id) THEN
        SELECT COUNT(*) INTO v_count
        FROM teaching_loads
        WHERE group_id = NEW.group_id;

        IF v_count >= 2 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'RN03: El grupo ya tiene 2 profesores asignados';
        END IF;
    END IF;
END//





-- Ej6: RN07: el alumno debe estar matriculado en la asignatura del grupo. RN04: un alumno solo puede estar en un grupo de teoría y en uno de laboratorio por asignatura
CREATE OR REPLACE TRIGGER t_biu_students_groups_rn04_rn07
BEFORE INSERT OR UPDATE ON students_groups
FOR EACH ROW
BEGIN
    DECLARE v_subject_id INT;
    DECLARE v_activity VARCHAR(15);
    DECLARE v_old_subject_id INT;
    DECLARE v_old_activity VARCHAR(15);

    -- Asignatura y actividad del grupo nuevo
    SELECT subject_id, activity INTO v_subject_id, v_activity
    FROM groups
    WHERE group_id = NEW.group_id;

    -- Asignatura y actividad del grupo anterior (en INSERT, OLD.group_id vale NULL y quedan a NULL)
    SET v_old_subject_id = (SELECT subject_id FROM groups WHERE group_id = OLD.group_id);
    SET v_old_activity = (SELECT activity FROM groups WHERE group_id = OLD.group_id);

    IF NOT f_is_student_enrolled(NEW.student_id, v_subject_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN07: El alumno debe estar matriculado en la asignatura';
    END IF;

    -- RN04 solo se comprueba si el alumno entra en un grupo de otra asignatura o actividad (cambiar de L1 a L2 de la misma asignatura está permitido).
    -- En INSERT, OLD y las variables v_old_* valen NULL: se comprueba siempre
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



-- Funcion auxiliar de para usar en functions.sql RN07: indica si el alumno está matriculado en la asignatura.
-- La usa el trigger t_biu_students_groups_rn04_rn07
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

-- RN04: indica si el alumno ya está en un grupo de la actividad (teoría o
-- laboratorio) en la asignatura. La usa el trigger t_biu_students_groups_rn04_rn07
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
    -- Grupos de esa asignatura y actividad en los que ya está el alumno
    SELECT COUNT(*) INTO v_count
    FROM students_groups ge
    JOIN groups g ON g.group_id = ge.group_id
    WHERE ge.student_id = p_student_id
      AND g.subject_id = p_subject_id
      AND g.activity = p_activity;

    -- RN04: como máximo un grupo de cada actividad (teoría o laboratorio)
    RETURN v_count >= 1;
END//




-- Ej7: RN06: por asignatura y año académico, como máximo un grupo de teoría y dos
-- de laboratorio
CREATE OR REPLACE TRIGGER t_biu_groups_rn06
BEFORE INSERT OR UPDATE ON groups
FOR EACH ROW
BEGIN
    -- Se comprueba si el grupo entra en otra asignatura, actividad o año:
    -- - en INSERT, OLD vale NULL: se comprueba siempre
    -- - en UPDATE, solo si cambia alguno de los tres (<=> trata NULL como un valor)
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





-- Functions auxiliar usada en functions.sql RN07: indica si el alumno está matriculado en la asignatura.
-- La usa el trigger t_biu_students_groups_rn04_rn07
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

-- RN04: indica si el alumno ya está en un grupo de la actividad (teoría o
-- laboratorio) en la asignatura. La usa el trigger t_biu_students_groups_rn04_rn07
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
    -- Grupos de esa asignatura y actividad en los que ya está el alumno
    SELECT COUNT(*) INTO v_count
    FROM students_groups ge
    JOIN groups g ON g.group_id = ge.group_id
    WHERE ge.student_id = p_student_id
      AND g.subject_id = p_subject_id
      AND g.activity = p_activity;

    -- RN04: como máximo un grupo de cada actividad (teoría o laboratorio)
    RETURN v_count >= 1;
END//




-- Ej 8: RN06: por asignatura y año académico, como máximo un grupo de teoría y dos de laboratorio
CREATE OR REPLACE TRIGGER t_biu_groups_rn06
BEFORE INSERT OR UPDATE ON groups
FOR EACH ROW
BEGIN
    -- Se comprueba si el grupo entra en otra asignatura, actividad o año:
    -- - en INSERT, OLD vale NULL: se comprueba siempre
    -- - en UPDATE, solo si cambia alguno de los tres (<=> trata NULL como un valor)
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




-- Functions auxiliar usada en functions.sql: -- RN06: indica si la asignatura ya tiene en ese año académico el máximo de grupos de la actividad (uno de teoría o dos de laboratorio).
-- La usa el trigger t_biu_groups_rn06
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

    -- Grupos que ya tiene la asignatura de esa actividad en ese año
    SELECT COUNT(*) INTO v_count
    FROM groups
    WHERE subject_id = p_subject_id
      AND activity = p_activity
      AND academic_year = p_academic_year;

    -- El máximo depende de la actividad
    IF p_activity = 'Teoría' THEN
        SET v_result = (v_count >= 1);
    ELSEIF p_activity = 'Laboratorio' THEN
        SET v_result = (v_count >= 2);
    END IF;

    RETURN v_result;
END//




