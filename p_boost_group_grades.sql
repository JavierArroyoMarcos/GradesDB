DELIMITER //
CREATE OR REPLACE PROCEDURE p_boost_group_grades(
    IN p_group_id INT,
    IN p_exam_call VARCHAR(50)
)
BEGIN
    DECLARE v_affected_rows INT;
    
    -- Actualizar notas aplicando LEAST para no pasar de 10
    UPDATE grades
    SET grade_value = LEAST(grade_value * 1.15, 10.0)
    WHERE group_id = p_group_id 
      AND exam_call = p_exam_call
      AND grade_value BETWEEN 4.5 AND 8.0;
      
    -- Obtener cuántas filas se modificaron
    SET v_affected_rows = ROW_COUNT();
    
    -- Mostrar resumen
    SELECT CONCAT('Notas actualizadas en el grupo ', p_group_id, ': ', v_affected_rows) AS Resumen;
END //
DELIMITER ;