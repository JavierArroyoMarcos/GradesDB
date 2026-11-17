--
-- Autor: Javier Arroyo Marcos
-- Fecha: 17/11
-- Descripción: 
-- Se incluye en: 
--

SET FOREIGN_KEY_CHECKS = 0; -- Interruptor para q las tablas se puedan borrar sin problemas
DROP TABLE IF EXISTS people; -- Elimina la tabla si ya existía 
DROP TABLE IF EXISTS professors;  -- Primero se pone la tabla principal y después la secundaria
DROP TABLE IF EXITSTS students;

DROP TABLE IF EXITSTS degrees;
DROP TABLE IF EXITSTS subjects;
SET FOREIGN_KEY_CHECKS = 1;
-- ---------------------------------PERSONAS ------------------------------------------------
CREATE TABLE people (       
    person_id INT AUTO_INCREMENT, -- Crea una columna de números enteros que se numera automáticamente (1, 2, 3...).
    dni CHAR(9) NOT NULL,         -- Deja un hueco de 9 caracteres. No puede dejarse en blanco (NOT NULL).
    first_name VARCHAR(100) NOT NULL, -- Texto de hasta 100 caracteres. Más que Char
    last_name VARCHAR(150) NOT NULL,  
    age TINYINT NOT NULL,         -- Número entero pequeño (0-255)
    email VARCHAR(255) NOT NULL,  
    PRIMARY KEY (person_id)       -- Define 'person_id' como el identificador único principal de cada registro en la tabla.
);                           

-- Definición tabla professors

CREATE TABLE professors (
    professor_id INT,
    category VARCHAR(30) NOT NULL,
    PRIMARY KEY (professor_id),   -- El identificador es professor_id
    FOREIGN KEY (professor_id) REFERENCES people(person_id)  -- Señal que professor_id y person_id se refiere a lo mismo
);

CREATE TABLE students (
    student_id INT,
    access_method VARCHAR(20) NOT NULL,
    PRIMARY KEY (student_id),
    FOREIGN KEY (student_id) REFERENCES people(person_id)
);

-- RELACIÓN 1:1: (1)profesor corresponde a exactamente una (1) persona
-- FOREIGN KEY (b_id) REFERENCES people(a_id)
-- ----------------------------GRADOS-----------------------------------------------
CREATE TABLE degrees (
    degree_id INT AUTO_INCREMENT,
    degree_name VARCHAR(80) NOT NULL,
    duration_years TINYINT NOT NULL,
    PRIMARY KEY (degree_id)
);

CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT,
    degree_id INT NOT NULL,
    subject_name VARCHAR(120) NOT NULL,
    acronym VARCHAR(12) NOT NULL,
    credits TINYINT NOT NULL,
    course TINYINT NOT NULL,
    subject_type VARCHAR(30) NOT NULL,
    PRIMARY KEY (subject_id),
    FOREIGN KEY (degree_id) REFERENCES degrees(degree_id)
);

-- Relación 1:N (1) grado corresponde a (muchas) asignaturas
-- FOREIGN KEY (a_id) REFERENCES degrees(a_id)