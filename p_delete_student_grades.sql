DELIMITER //
CREATE OR REPLACE PROCEDURE p_delete_student_grades(
    IN p_dni VARCHAR(20)
)
BEGIN
    DECLARE v_student_id INT;
    
    -- Obtener el student_id a partir del DNI
    SELECT s.student_id INTO v_student_id
    FROM students s
    JOIN people p ON p.person_id = s.student_id
    WHERE p.dni = p_dni;
    
    -- Borrar las notas de ese estudiante
    DELETE FROM grades WHERE student_id = v_student_id;
END //
DELIMITER ;