USE grades_db;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_delete_all_data()
BEGIN
    DELETE FROM grades;
    DELETE FROM students_groups;
    DELETE FROM students_subjects;
    DELETE FROM teaching_loads;
    DELETE FROM `groups`;
    DELETE FROM subjects;
    DELETE FROM degrees;
    DELETE FROM students;
    DELETE FROM professors;
    DELETE FROM people;
END //
DELIMITER ;