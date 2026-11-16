USE grades_db;

CREATE OR REPLACE TABLE test_results (
    test_id VARCHAR(20) PRIMARY KEY,
    test_name VARCHAR(200) NOT NULL,
    test_message VARCHAR(500) NOT NULL,
    test_status ENUM('PASS','FAIL') NOT NULL,
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

-- ====== TESTS DECLARATIVOS ======

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn01_mh_requirement()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN01', 'RN01: No se puede dar MH con nota < 9', 'PASS');
    CALL p_populate();
    INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
        VALUES (6, 1, 8.0, 'Extraordinaria', 1);
    CALL p_log_test('RN01', 'ERROR: Se permitió MH con nota < 9', 'FAIL');
END //

CREATE OR REPLACE PROCEDURE p_test_rn09_not_null_attributes()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN09', 'RN09: No se permite atributo NOT NULL a NULL', 'PASS');
    CALL p_populate();
    INSERT INTO people (dni, first_name, last_name, age, email)
        VALUES ('99999999Z', NULL, 'Apellido', 20, 'nulo@test.us.es');
    CALL p_log_test('RN09', 'ERROR: Se permitió first_name NULL', 'FAIL');
END //

CREATE OR REPLACE PROCEDURE p_test_rn10_subject_credits()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN10', 'RN10: Créditos de asignatura sólo 6 o 12', 'PASS');
    CALL p_populate();
    INSERT INTO subjects (degree_id, subject_name, acronym, credits, course, subject_type)
        VALUES (3, 'Test Subject', 'TST', 9, 1, 'Optativa');
    CALL p_log_test('RN10', 'ERROR: Se permitió créditos = 9', 'FAIL');
END //

CREATE OR REPLACE PROCEDURE p_test_rn11_grade_range()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN11', 'RN11: Nota entre 0 y 10', 'PASS');
    CALL p_populate();
    INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
        VALUES (6, 1, 11.0, 'Extraordinaria', 0);
    CALL p_log_test('RN11', 'ERROR: Se permitió nota = 11', 'FAIL');
END //

CREATE OR REPLACE PROCEDURE p_test_rn12_people_age()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN12', 'RN12: Edad entre 16 y 70', 'PASS');
    CALL p_populate();
    INSERT INTO people (dni, first_name, last_name, age, email)
        VALUES ('99999998Y', 'Test', 'Edad', 15, 'edad15@test.us.es');
    CALL p_log_test('RN12', 'ERROR: Se permitió edad = 15', 'FAIL');
END //

CREATE OR REPLACE PROCEDURE p_test_rn13_degree_years()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN13', 'RN13: Duración grado entre 3 y 6 años', 'PASS');
    CALL p_populate();
    INSERT INTO degrees (degree_name, duration_years)
        VALUES ('Grado Test Largo', 7);
    CALL p_log_test('RN13', 'ERROR: Se permitió duración = 7', 'FAIL');
END //

CREATE OR REPLACE PROCEDURE p_test_rn14_dni_format()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN14', 'RN14: DNI 8 dígitos + 1 letra', 'PASS');
    CALL p_populate();
    INSERT INTO people (dni, first_name, last_name, age, email)
        VALUES ('1234567AB', 'Test', 'DNI', 20, 'dnitest@test.us.es');
    CALL p_log_test('RN14', 'ERROR: Se permitió DNI inválido', 'FAIL');
END //

CREATE OR REPLACE PROCEDURE p_test_rn15_academic_year()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN15', 'RN15: Año académico entre 2000 y 2100', 'PASS');
    CALL p_populate();
    INSERT INTO `groups` (subject_id, group_name, activity, academic_year)
        VALUES (11, 'T99', 'Teoría', 1999);
    CALL p_log_test('RN15', 'ERROR: Se permitió año académico = 1999', 'FAIL');
END //

CREATE OR REPLACE PROCEDURE p_test_rn16_course_range()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN16', 'RN16: Curso entre 1 y 6', 'PASS');
    CALL p_populate();
    INSERT INTO subjects (degree_id, subject_name, acronym, credits, course, subject_type)
        VALUES (3, 'Test Course', 'TSC', 6, 7, 'Optativa');
    CALL p_log_test('RN16', 'ERROR: Se permitió curso = 7', 'FAIL');
END //

-- Orquestador de los tests declarativos (para uso standalone de este script)
CREATE OR REPLACE PROCEDURE p_run_tests()
BEGIN
    DELETE FROM test_results;
    CALL p_test_rn01_mh_requirement();
    CALL p_test_rn09_not_null_attributes();
    CALL p_test_rn10_subject_credits();
    CALL p_test_rn11_grade_range();
    CALL p_test_rn12_people_age();
    CALL p_test_rn13_degree_years();
    CALL p_test_rn14_dni_format();
    CALL p_test_rn15_academic_year();
    CALL p_test_rn16_course_range();
    SELECT * FROM test_results ORDER BY execution_time, test_id;
END //
DELIMITER ;

-- Ejecución standalone (si ejecutas tests.sql después, éste reemplaza p_run_tests)
CALL p_run_tests();