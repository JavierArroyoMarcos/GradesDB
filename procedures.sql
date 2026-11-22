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




-- Variables locales (@variable)
-- Se identifican conel prefijo @

-- Persite entre llamadas(existe durante toda la sesión)
-- No necesita ser declarado
-- Se crean al asignarle un valor
-- Útil para pasar variables entre procedimientos

SET @resultado = 100;  -- Asignar valor directamente

SELECT AVG(grade_value) INTO @promedio_general FROM grades;  -- Asignar desde una consulta

CALL p_student_average(6, @promedio_estudiante);     -- Usar en procedimientos

SELECT @promedio_estudiante;   -- Consultar el valor
