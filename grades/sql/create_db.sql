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

DROP TABLE IF EXITSTS groups;
DROP TABLE IF EXITSTS students_groups;

DROP TABLE IF EXITSTS grades;

DROP TABLE IF EXITSTS student_subject;

DROP TABLE IF EXITSTS teaching_load;
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

-- ------------------------------ GRUPOS ------------------------------------------------
CREATE TABLE groups (
    group_id INT AUTO_INCREMENT,
    subject_id INT NOT NULL,
    group_name VARCHAR(40) NOT NULL,
    activity VARCHAR(15) NOT NULL,
    academic_year YEAR NOT NULL,
    PRIMARY KEY (group_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)  -- 1:N (1) asignatura corresponde a (muchos) grupos
);

CREATE TABLE students_groups (
    student_group_id INT AUTO_INCREMENT,
    student_id INT NOT NULL,
    group_id INT NOT NULL,
    PRIMARY KEY (student_group_id),
    CONSTRAINT uq_students_groups UNIQUE (student_id, group_id), -- Restricción: -uq_students_groups(nombre de la nueva restricción)  -UNIQUE: exige q lo de dentro sea único, e este caso la combinación de dentro

    FOREIGN KEY (student_id) REFERENCES students(student_id),  -- N:M (muchos) estudiante corresponde a (muchos) grupos_estudiantes
    FOREIGN KEY (group_id) REFERENCES groups(group_id)  -- N:M (muchos) grupo corresponde a (muchos) grupos_estudiantes
    -- 1:N y N:M se escribe igual en FK pero la diferencia es que N:M aparece ambas id en nuestra tabla
);



-- -------------------------------- NOTAS -----------------------------------------
CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT,
    student_id INT NOT NULL,
    group_id INT NOT NULL,
    grade_value DECIMAL(4,2) NOT NULL,
    exam_call VARCHAR(20) NOT NULL,
    with_honors BOOLEAN NOT NULL DEFAULT 0, -- 0 o 1
    PRIMARY KEY (grade_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),  -- N:M
    FOREIGN KEY (group_id) REFERENCES groups(group_id) -- N:M
);


-- --------------------------------ASIGNATURAS -------------------------------
CREATE TABLE students_subjects (
    student_subject_id INT AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    PRIMARY KEY (student_subject_id),
    CONSTRAINT uq_students_subjects UNIQUE (student_id, subject_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id), -- N:M
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) -- N:M
);


-- ----------------------------------------- CARGAS ------------------------
CREATE TABLE teaching_loads (
    teaching_load_id INT AUTO_INCREMENT,
    professor_id INT NOT NULL,
    group_id INT NOT NULL,
    credits DECIMAL(4,1) NOT NULL,
    PRIMARY KEY (teaching_load_id),
    CONSTRAINT uq_teaching_loads UNIQUE (professor_id, group_id),
    FOREIGN KEY (professor_id) REFERENCES professors(professor_id),
    FOREIGN KEY (group_id) REFERENCES groups(group_id)
);








-- ------------------ LAB 2: -------------------------------------------------------------------
------------------- RESTRICCIONES ---------------------------------------------------------------
ALTER TABLE people
    ADD CONSTRAINT ck_people_rn12_age CHECK (age BETWEEN 16 AND 70),  -- edad en ese rango
    ADD CONSTRAINT ck_people_rn14_dni CHECK (dni REGEXP '^[0-9]{8}[A-Za-z]$'), -- dni REGEXP: dni debe de cumplir con una expresión regular(REGEXP)
                                                                               -- '^[0-9]{8}[A-Za-z]$': 
                                                                               -- ^: "El texto tiene que EMPEZAR exactamente aquí".
                                                                               -- [0-9]{8}: Haya exactamente 8 números (del 0 al 9)
                                                                               -- [A-Za-z]: Obliga a que justo después haya una sola letra, mayúscula (A-Z) o minúscula (a-z).
                                                                               -- $: "Y aquí TERMINA el texto". Es decir, no puede haber más números, letras ni espacios después.
    ADD CONSTRAINT uq_people_dni UNIQUE (dni),  -- dni no se puede repetir
    ADD CONSTRAINT uq_people_email UNIQUE (email); -- email no se puede repetir



ALTER TABLE professors
    ADD CONSTRAINT ck_professors_category CHECK (
        category IN ('Ayudante','AyudanteDoctor','Titular','Catedrático')
    );     -- Solamente puede haber esas categorías


ALTER TABLE students
    ADD CONSTRAINT ck_students_access_method CHECK (
        access_method IN ('Selectividad','Ciclo','Mayor','Titulado','Extranjero')
    );    -- Solamente puede haber esas categorías

ALTER TABLE students
    ADD CONSTRAINT ck_students_access_method CHECK (
        access_method IN ('Selectividad','Ciclo','Mayor','Titulado','Extranjero')
    );

ALTER TABLE degrees
    ADD CONSTRAINT ck_degrees_rn13_duration CHECK (duration_years BETWEEN 3 AND 6), -- Duración sea entre 3 y 6
    ADD CONSTRAINT uq_degrees_name UNIQUE (degree_name); -- No dos grados con el mismo nombre

ALTER TABLE subjects
    ADD CONSTRAINT ck_subjects_rn10_credits CHECK (credits IN (6, 12)),  -- 6 o 12
    ADD CONSTRAINT ck_subjects_rn16_course CHECK (course BETWEEN 1 AND 6), -- entre 1 y 6
    ADD CONSTRAINT ck_subjects_type CHECK (subject_type IN ('Formación Básica','Obligatoria','Optativa')),
    ADD CONSTRAINT uq_subjects_name UNIQUE (subject_name),
    ADD CONSTRAINT uq_subjects_acronym UNIQUE (acronym);

ALTER TABLE groups
    ADD CONSTRAINT ck_groups_rn15_year CHECK (academic_year BETWEEN 2000 AND 2100),
    ADD CONSTRAINT ck_groups_activity CHECK (activity IN ('Teoría','Laboratorio')),
    ADD CONSTRAINT uq_groups_name UNIQUE (subject_id, group_name, academic_year);

ALTER TABLE teaching_loads
    ADD CONSTRAINT ck_teaching_loads_credits CHECK (credits > 0);  -- Créditos positivos

    ADD CONSTRAINT ck_grades_rn11_value CHECK (grade_value BETWEEN 0 AND 10),
    ADD CONSTRAINT ck_grades_rn01_with_honors CHECK (with_honors = 0 OR grade_value >= 9), -- matricula de honor con un 9 o más
    ADD CONSTRAINT ck_grades_exam_call CHECK (exam_call IN ('Primera','Segunda','Tercera','Extraordinaria'));