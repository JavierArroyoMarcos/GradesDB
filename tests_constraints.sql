--
-- Autor: Javier Arroyo Marcos
-- Fecha: 18/11
-- Descripción: Laboratorio 4
-- Se incluye en: iissi1/labs/AN-B
--


-- ESTRATEGIA: TESTS NEGATIVOS

-- Test negativo: Intenta realizar una operación que viola una regla de negocio.
-- Resultado esperado: La base de datos rechaza la operación con un error.
-- Test PASS: Si se captura la excepción esperada.
-- Test FAIL: Si la operación se ejecuta sin error (la restricción no funciona).




USE grades_db;

-- 1. TABLA RESULTADOS -----------------------------------------
CREATE OR REPLACE TABLE test_results (
    test_id VARCHAR(20) PRIMARY KEY,
    test_name VARCHAR(200) NOT NULL,
    test_message VARCHAR(500) NOT NULL,
    test_status ENUM('PASS','FAIL') NOT NULL,
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- PASS si la operación prohibida se rechazó
-- -------------------------------------------------------

-- 2. PRODEDIMIENTO AUXILIAR --------------------------
DELIMITER //
CREATE OR REPLACE PROCEDURE p_log_test(
    IN p_test_id VARCHAR(20),
    IN p_message VARCHAR(500),
    IN p_status ENUM('PASS','FAIL')
)
BEGIN
    INSERT INTO test_results(test_id, test_name, test_message, test_status)
    VALUES (p_test_id, SUBSTRING_INDEX(p_message, ':', 1), p_message, p_status);
END //
DELIMITER ;
-- -------------------------------------------------------