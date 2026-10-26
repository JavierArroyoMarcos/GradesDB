-- 1. Crear la tabla de resultados
DROP TABLE IF EXISTS test_results;
CREATE TABLE test_results (
    test_name VARCHAR(100),
    status VARCHAR(10),
    execution_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

-- 2. Procedimiento auxiliar para guardar el resultado
CREATE OR REPLACE PROCEDURE p_log_test(
    IN p_test_name VARCHAR(100),
    IN p_status VARCHAR(10)
)
BEGIN
    INSERT INTO test_results (test_name, status) VALUES (p_test_name, p_status);
END //

-- 3. Procedimiento Orquestador (Aquí irán los 9 tests)
CREATE OR REPLACE PROCEDURE p_run_tests()
BEGIN
    -- Limpiar resultados anteriores
    TRUNCATE TABLE test_results;

    -- ==========================================
    -- EJEMPLO DE TEST NEGATIVO (RN01: DNI Único)
    -- ==========================================
    -- Bloque para capturar el error (Test PASS)
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION 
        BEGIN
            CALL p_log_test('RN01 - DNI único', 'PASS');
        END;
        
        -- Intentar insertar un DNI duplicado (esto debe fallar)
        INSERT INTO people (person_id, dni, first_name, last_name) 
        VALUES (999, '10000006F', 'Nombre', 'Falso');
        
        -- Si el código llega aquí, no hubo error -> FAIL
        CALL p_log_test('RN01 - DNI único', 'FAIL');
    END;

    -- ==========================================
    -- AQUÍ DEBES AÑADIR LOS TESTS RN09 HASTA RN16
    -- Sigue la misma estructura del bloque BEGIN...END de arriba
    -- (Un bloque por cada regla a probar)
    -- ==========================================
    
END //

DELIMITER ;