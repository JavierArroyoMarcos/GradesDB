--
-- Autor: Javier Arroyo Marcos
-- Fecha: 18/11
-- Descripción: Laboratorio 4
-- Se incluye en: iissi1/labs/AN-B
--


-- Variables locales (DECLARE)
-- Se declaran dentro de los Procedimientos, Funciones o Bloques BEGIN...END con DECLARE

-- Son locales(solamente existen en el bloque donde se declaran)
-- Se destruyen al finalizar
-- Se declaran al princiio del bloque, antes de una instrucción ejecutable

DELIMITER //    -- Tras cada ; termina una orden, por eso cambiamos temporalmente ; por //
CREATE OR REPLACE PROCEDURE ejemplo_variables_locales()  -- En el paréntesis se recibe parámetros de entrada
BEGIN
    DECLARE v_contador INT DEFAULT 0;   -- Variable local
    DECLARE v_nombre VARCHAR(100);      -- Variable local
    DECLARE v_promedio DECIMAL(4,2);    -- Variable local
    
    -- Las dos formas de meter datos en esas variables:
    SET v_contador = 10;       -- Fijando un valor a mano
    SELECT first_name INTO v_nombre FROM people WHERE person_id = 1;  -- Guardando el resultado de una consulta en la variable v_nombre
    
    SELECT v_contador, v_nombre;    -- Lomuestra por pantalla
END //
DELIMITER ;

-- Se ejecuta así: CALL ejemplo_variables_locales();




-- Variables de usuario (@variable)
-- Se identifican conel prefijo @

-- Persite entre llamadas(existe durante toda la sesión)
-- No necesita ser declarado
-- Se crean al asignarle un valor
-- Útil para pasar variables entre procedimientos

-- SET @resultado = 100;  -- Asignar valor directamente

-- SELECT AVG(grade_value) INTO @promedio_general FROM grades;  -- Asignar desde una consulta

-- CALL p_student_average(6, @promedio_estudiante);     -- Usar en procedimientos

-- SELECT @promedio_estudiante;   -- Consultar el valor






-- Parámetros de procedimientos

-- IN(Entrada): No pueden ser modificados
DELIMITER //
CREATE OR REPLACE PROCEDURE ejemplo_in(IN p_student_id INT)  -- Parámetro de entrada
BEGIN
    SELECT * FROM students WHERE student_id = p_student_id;
END //
DELIMITER ;

-- OUT(Salida): Se usapara devolver
DELIMITER //
CREATE OR REPLACE PROCEDURE ejemplo_out(IN p_student_id INT, OUT p_average DECIMAL(4,2))
-- Como debe ser el valor devuelto(OUT), como la caja vacía
BEGIN
    SELECT AVG(grade_value) INTO p_average
    FROM grades
    WHERE student_id = p_student_id;
END //
DELIMITER ;

-- INOUT(entrada/salida): Da una variable y seguarda ahí mismo
DELIMITER //
CREATE OR REPLACE PROCEDURE ejemplo_inout(INOUT p_contador INT)
BEGIN
    SET p_contador = p_contador + 1;
END //
DELIMITER ;



-- EJEMPLO TODO JUNTO
DELIMITER //
CREATE OR REPLACE PROCEDURE p_calculate_and_store(
    IN p_student_id INT,          -- Parámetro de entrada
    OUT p_result DECIMAL(4,2)     -- Parámetro de salida
)
BEGIN
    DECLARE v_count INT;           -- Variable local
    DECLARE v_sum DECIMAL(6,2);    -- Variable local
    
    -- Contar notas del estudiante
    SELECT COUNT(*), SUM(grade_value) 
    INTO v_count, v_sum
    FROM grades
    WHERE student_id = p_student_id;
    
    -- Calcular promedio
    IF v_count > 0 THEN
        SET p_result = v_sum / v_count;
    ELSE
        SET p_result = 0;
    END IF;
    
    -- Guardar en variable de usuario para uso posterior
    SET @last_calculation = p_result;
END //
DELIMITER ;

-- Uso del procedimiento
CALL p_calculate_and_store(6, @average); -- IN(6) OUT(@avarage)
SELECT @average AS 'Promedio', @last_calculation AS 'Última calculada';  -- Muestra en pantalla





-- PROCEDIMIENTOS ALMACENADOS

-- Ej1: Procedimiento para borrar notas de un alumno (RF02)Procedimiento para borrar notas de un alumno (RF02)
-- Borra todas las notas del alumno con el DNI indicado
CREATE OR REPLACE PROCEDURE p_delete_student_grades(
    IN p_student_dni CHAR(9)
)
BEGIN
    DECLARE v_student_id INT;

    SELECT student_id INTO v_student_id
    FROM people p
    JOIN students s ON s.student_id = p.person_id
    WHERE p.dni = p_student_dni;

    DELETE FROM grades WHERE student_id = v_student_id;
END //

-- -- Ej1: ejecuación:
-- -- Borrar las notas del estudiante con DNI '10000006F'
-- CALL p_delete_student_grades('10000006F');

-- -- Verificar que se borraron
-- SELECT * FROM grades g
-- JOIN students s ON s.student_id = g.student_id
-- JOIN people p ON p.person_id = s.student_id
-- WHERE p.dni = '10000006F';


-- Ej2: Procedimiento para borrar todos los datos
-- Borra todos los datos de la BD sin borrar las tablas
CREATE OR REPLACE PROCEDURE p_delete_all_data()
BEGIN
    -- Primero las tablas que referencian a otras y después las referenciadas,
    -- para que ninguna fila se quede apuntando a una que ya no existe (FK)
    DELETE FROM grades;
    DELETE FROM teaching_loads;
    DELETE FROM students_groups;
    DELETE FROM students_subjects;
    DELETE FROM groups;
    DELETE FROM subjects;
    DELETE FROM students;
    DELETE FROM professors;
    DELETE FROM degrees;
    DELETE FROM people;
END //


-- Ej3: Procedimiento para calcular el promedio de notas con parámetro OUT
-- Devuelve en el parámetro de salida p_average la nota media del alumno
-- (NULL si no tiene notas). Compárese con la función f_student_average (L5)
CREATE OR REPLACE PROCEDURE p_student_average(
    IN p_student_id INT,
    OUT p_average DECIMAL(4,2)
)
BEGIN
    SELECT AVG(grade_value) INTO p_average
    FROM grades
    WHERE student_id = p_student_id;
END //



-- Ej 4:  Procedimiento para subir notas de un grupo
CREATE OR REPLACE PROCEDURE p_boost_group_grades(
    IN p_group_id INT,
    IN p_exam_call VARCHAR(20)
)
BEGIN
    DECLARE v_affected_rows INT;
    DECLARE v_group_name VARCHAR(40);

    SELECT group_name INTO v_group_name
    FROM groups
    WHERE group_id = p_group_id;

    UPDATE grades
    
    SET grade_value = LEAST(grade_value * 1.15, 10.0)   -- LEAST devuelve el menor de los dos: la nota no pasa de 10
    WHERE group_id = p_group_id
      AND exam_call = p_exam_call
      AND grade_value BETWEEN 4.5 AND 8.0;

    SET v_affected_rows = ROW_COUNT(); -- ROW_COUNT(): filas modificadas por la última sentencia (el UPDATE)

    SELECT v_group_name AS group_name,
           v_affected_rows AS updated_grades;
END //

-- Ej 5: Procedimiento para asignar matrículas de honor
-- Asigna las matrículas de honor de un grupo en una convocatoria: a las
-- mejores notas a partir de 9, como máximo al 5 % de los alumnos del grupo
CREATE OR REPLACE PROCEDURE p_assign_honors(
    IN p_group_id INT,
    IN p_exam_call VARCHAR(20)
)
BEGIN
    DECLARE v_total_students INT;
    DECLARE v_max_honors INT;

    SELECT COUNT(*) INTO v_total_students
    FROM students_groups
    WHERE group_id = p_group_id;

    -- FLOOR redondea hacia abajo: con menos de 20 alumnos no hay matrículas
    SET v_max_honors = FLOOR(v_total_students * 0.05);

    IF v_max_honors = 0 THEN
        SELECT CONCAT('No se pueden asignar matrículas de honor: ',
                      'el 5% de ', v_total_students,
                      ' estudiantes matriculados es 0') AS mensaje;
    ELSE
        -- Se quitan las matrículas anteriores para volver a asignarlas
        UPDATE grades
        SET with_honors = 0
        WHERE group_id = p_group_id
          AND exam_call = p_exam_call;
        -- MariaDB no admite LIMIT en una subconsulta con IN: por eso las notas elegidas se calculan en una tabla derivada (selected_grades)
        UPDATE grades
        SET with_honors = 1
        WHERE grade_id IN (
            SELECT selected_grades.grade_id
            FROM (
                SELECT grade_id
                FROM grades
                WHERE group_id = p_group_id
                  AND exam_call = p_exam_call
                  AND grade_value >= 9.0
                ORDER BY grade_value DESC
                LIMIT v_max_honors
            ) AS selected_grades
        );
    END IF;
END //







-- PROCEDIMIENTO TRANSACCIONAL  (LAB7)


-- Sin transacción: Si falla la inserción de la asignatura, el grado se queda insertado

CREATE OR REPLACE PROCEDURE p_insert_degree_subject(
    IN p_degree_name VARCHAR(80),
    IN p_degree_years TINYINT,
    IN p_subject_name VARCHAR(120),
    IN p_subject_acronym VARCHAR(12),
    IN p_subject_credits TINYINT,
    IN p_subject_course TINYINT,
    IN p_subject_type VARCHAR(30)
)
BEGIN
    DECLARE v_new_degree_id INT;

    INSERT INTO degrees (degree_name, duration_years)
    VALUES (p_degree_name, p_degree_years);

    -- LAST_INSERT_ID(): id AUTO_INCREMENT asignado por el último INSERT
    SET v_new_degree_id = LAST_INSERT_ID();  -- Sirve para guardar el id del grado recién creado para poder enlazarlo con la asignatura nueva

    INSERT INTO subjects (degree_id, subject_name, acronym, credits, course, subject_type)
    VALUES (v_new_degree_id, p_subject_name, p_subject_acronym,
            p_subject_credits, p_subject_course, p_subject_type);
END //


-- Probar con datos válidos
CALL p_populate();

CALL p_insert_degree_subject('Grado en Inteligencia Artificial',4,'Aprendizaje Automático','AA',6,3,'Obligatoria');

SELECT * FROM degrees WHERE degree_name = 'Grado en Inteligencia Artificial';
SELECT * FROM subjects WHERE acronym = 'AA';

-- Probar con datos erróneos: 
CALL p_populate();

-- El grado es nuevo, pero el acrónimo FP ya es de Fundamentos de Programación
CALL p_insert_degree_subject('Grado en Ciberseguridad',4,'Redes Neuronales','FP',  6,3,'Obligatoria');
-- FP es un acrónimo repetido

SELECT * FROM degrees WHERE degree_name = 'Grado en Ciberseguridad';   -- El grado queda insertado, aunque su asignatura no se haya creado
SELECT * FROM subjects WHERE subject_name = 'Redes Neuronales';

