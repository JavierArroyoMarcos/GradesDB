DELIMITER //
CREATE OR REPLACE PROCEDURE p_assign_honors(
    IN p_group_id INT,
    IN p_exam_call VARCHAR(50)
)
BEGIN
    DECLARE v_total_students INT;
    DECLARE v_max_honors INT;
    
    -- Contar el total de alumnos en el grupo (a través de la tabla que los relaciona)
    SELECT COUNT(*) INTO v_total_students 
    FROM students_groups 
    WHERE group_id = p_group_id;
    
    -- Calcular el 5% truncando hacia abajo
    SET v_max_honors = FLOOR(v_total_students * 0.05);
    
    IF v_max_honors > 0 THEN
        -- Quitar MH existentes en ese grupo y convocatoria
        UPDATE grades 
        SET with_honors = 0 
        WHERE group_id = p_group_id AND exam_call = p_exam_call;
        
        -- Asignar MH a los mejores usando una tabla derivada (para poder usar LIMIT)
        UPDATE grades
        SET with_honors = 1
        WHERE grade_id IN (
            SELECT grade_id FROM (
                SELECT grade_id 
                FROM grades
                WHERE group_id = p_group_id 
                  AND exam_call = p_exam_call
                  AND grade_value >= 9.0
                  AND with_honors = 0 -- Evitar repetir
                ORDER BY grade_value DESC
                LIMIT v_max_honors
            ) AS selected_grades
        );
    END IF;
END //
DELIMITER ;