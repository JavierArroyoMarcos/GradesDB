--
-- Autor: Javier Arroyo Marcos
-- Fecha: 23/11
-- Descripción: 
-- Se incluye en: Lab7
-- 

-- La parte más importante es el punto 5




-- 2. AUTOCOMMIT Y START TRANSACTION

-- AUTOCOMMIT: Decide cuándo empieza y termina una transacción:
    -- Activado(1, por defecto): cada sentencia es una trasacción confirmada si se ejecuta correctamente
        -- START TRANSACTION(abre una transacción), COMMIT(confirmar), ROLLBACK(deshacer)
    -- Activado(1, por defecto): transacción comienza sola y las agrupa hasta el COMMIT o ROLLBACK   (no hace falta START TRANSACTION)

-- (sentencia = instrucción, ej: SELECT * FROM people;)

CALL p_populate();   -- reinicio la base de datos

SET AUTOCOMMIT = 1;  -- activo el autoguardado
START TRANSACTION;

INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
VALUES (6, 1, 4.5, 'Extraordinaria', 0);
INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
VALUES (7, 1, 7.5, 'Extraordinaria', 0);

SELECT @@in_transaction;  -- 1: hay una transacción abierta
ROLLBACK;                 -- Cancela la transaccióne deshace las dos inserciones





-- Con AUTOCOMMIT DESACTIVADO
CALL p_populate();

SET AUTOCOMMIT = 0; -- No se escribe START TRANSACTION

INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
VALUES (6, 1, 4.5, 'Extraordinaria', 0);

SELECT @@in_transaction;  -- 1: la transacción ha empezado con el INSERT
ROLLBACK;                 -- deshace la inserción

SET AUTOCOMMIT = 1;





SELECT * FROM grades
WHERE student_id IN (6, 7) AND exam_call = 'Extraordinaria';
-- debe salir 0 pues ROLLBACK deshace la inserción






-- START TRANSACTION con una transacción abierta la confirma antes de abrir la nueva
CALL p_populate();

SET AUTOCOMMIT = 0;  -- Apago el autoguardado

INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)  -- Inserto los valores
VALUES (6, 1, 4.5, 'Extraordinaria', 0);

START TRANSACTION;  -- Dado q abro otra transaction nuevo, la anterior se guarda
ROLLBACK;           -- Solo deshace la transacción nueva, que está vacía

SET AUTOCOMMIT = 1;  -- Dejo encendido elautoguardado para futuras operaciones



SELECT * FROM grades 
WHERE student_id = 6 AND exam_call = 'Extraordinaria';
-- debe salir el valor









-- ERRORES 


CALL p_populate();

START TRANSACTION;  
-- Da error solamente una(la 3ra), si una da error sigue con el resto
INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
VALUES (6, 1, 4.5, 'Extraordinaria', 0);
INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
VALUES (7, 1, 7.5, 'Extraordinaria', 0);
INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
VALUES (8, 1, -7.5, 'Extraordinaria', 0);

COMMIT;



SELECT * FROM grades    -- Quedan las dos primeras notas
WHERE student_id IN (6, 7, 8) AND exam_call = 'Extraordinaria';










-- Este código hace TODO O NADA: 
CALL p_populate();

DELIMITER //
BEGIN NOT ATOMIC            -- BLOQUE ATÓMICO
    DECLARE EXIT HANDLER FOR SQLEXCEPTION   -- SI HAY ALGÚN ERROR SALE INMEDIATAMENTE
    BEGIN
        ROLLBACK;  -- DESHACE TODO
        RESIGNAL;  -- LANZA LA SEÑAL DE ERROR
    END;

    START TRANSACTION;

    INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
    VALUES (6, 1, 4.5, 'Extraordinaria', 0);
    INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
    VALUES (7, 1, 7.5, 'Extraordinaria', 0);
    INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
    VALUES (8, 1, -7.5, 'Extraordinaria', 0);

    COMMIT;
END //
DELIMITER ;



SELECT * FROM grades     -- No queda ninguna de las tres notas
WHERE student_id IN (6, 7, 8) AND exam_call = 'Extraordinaria';




