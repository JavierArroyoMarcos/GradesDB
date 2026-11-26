SELECT @@transaction_isolation; 


-- Prueba 1: Con REPEATABLE READ:

-- Ventana A:
-- Paso 1
CALL p_populate();

-- Paso 4
UPDATE grades
SET grade_value = grade_value + 1
WHERE grade_id = 3;



-- Vemtana B
-- Paso 2
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;

-- Paso 3
SELECT grade_value FROM grades WHERE grade_id = 3; -- veo 5.40

-- Paso 5 
SELECT grade_value FROM grades WHERE grade_id = 3;  -- sigo viendo 5.40

-- Paso 6
COMMIT;
SELECT grade_value FROM grades WHERE grade_id = 3;  -- cierro la transacción y veo 6.40






-- Prueba 1: Con READ COMMITTED

-- Ventana A:
-- Paso 1
CALL p_populate();

-- Paso 4
UPDATE grades
SET grade_value = grade_value + 1
WHERE grade_id = 3;


-- Ventana B:
-- Paso 2
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;

-- Paso 3
SELECT grade_value FROM grades WHERE grade_id = 3; -- veo 5.40

-- Paso 5 
SELECT grade_value FROM grades WHERE grade_id = 3;  -- ahora si veo 6.40

-- Paso 6
COMMIT;
SELECT grade_value FROM grades WHERE grade_id = 3;  -- sigo viendo 6.40