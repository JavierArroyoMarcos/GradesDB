--
-- Autor: Javier Arroyo Marcos
-- Fecha: 17/11
-- Descripción: 
-- Se incluye en: 
--
SET FOREIGN_KEY_CHECKS = 0; -- Interruptor para q las tablas se puedan borrar sin problemas
DELETE FROM people; -- Elimina los datos si ya existía 
DELETE FROM professors;  -- Primero se pone los datos de la tabla principal y después la secundaria
DELETE FROM students;
SET FOREIGN_KEY_CHECKS = 1;


-- DROP para tablas: DDL
-- DELETE para datos: DML

	-- Añado valores a la tabla recién creada
INSERT INTO people (person_id, dni, first_name, last_name, age, email) VALUES
    (1, '00000001A', 'David', 'Ruiz', 50, 'druiz@us.es'),  -- Profesor
    (2, '00000002B', 'Inma', 'Hernández', 40, 'inmahernandez@us.es'), -- Profesor
    (3, '00000003C', 'Fernando', 'Sola', 28, 'fsola@us.es'), -- Profesor
    (4, '00000004D', 'Daniel', 'Ayala', 32, 'dayala1@us.es'), -- Profesor
    (5, '00000005E', 'Pepe', 'Calderón', 43, 'pepecalderon@us.es'), -- Profesor
    (6, '10000006F', 'David', 'Romero', 22, 'david.romero@alum.us.es'),  -- Estudiante
    (7, '10000007G', 'Lucía', 'Molina', 21, 'lucia.molina@alum.us.es'), -- Estudiante
    (8, '10000008H', 'Hugo', 'Paredes', 20, 'hugo.paredes@alum.us.es'), -- Estudiante
    (9, '10000009J', 'Sara', 'Campos', 21, 'sara.campos@alum.us.es'), -- Estudiante
    (10, '10000010K', 'Mario', 'Galán', 22, 'mario.galan@alum.us.es'), -- Estudiante
    (11, '10000011L', 'Elena', 'Torres', 21, 'elena.torres@alum.us.es'), -- Estudiante
    (12, '10000012M', 'Rubén', 'Durán', 20, 'ruben.duran@alum.us.es'), -- Estudiante
    (13, '10000013N', 'Claudia', 'Soto', 23, 'claudia.soto@alum.us.es'), -- Estudiante
    (14, '10000014P', 'Iván', 'Cuesta', 22, 'ivan.cuesta@alum.us.es'), -- Estudiante
    (15, '10000015Q', 'Noelia', 'Rey', 21, 'noelia.rey@alum.us.es'), -- Estudiante
    (16, '10000016R', 'Pablo', 'Vidal', 22, 'pablo.vidal@alum.us.es'), -- Estudiante 
    (17, '10000017S', 'Alicia', 'Muñoz', 21, 'alicia.munoz@alum.us.es'), -- Estudiante
    (18, '10000018T', 'Sergio', 'Izquierdo', 22, 'sergio.izquierdo@alum.us.es'), -- Estudiante
    (19, '10000019U', 'Nerea', 'Saiz', 20, 'nerea.saiz@alum.us.es'), -- Estudiante
    (20, '10000020V', 'Álvaro', 'León', 23, 'alvaro.leon@alum.us.es'), -- Estudiante
    (21, '10000021W', 'Julia', 'Benito', 21, 'julia.benito@alum.us.es'), -- Estudiante
    (22, '10000022X', 'Tomás', 'Rubio', 22, 'tomas.rubio@alum.us.es'), -- Estudiante
    (23, '10000023Y', 'Irene', 'Salas', 21, 'irene.salas@alum.us.es'), -- Estudiante
    (24, '10000024Z', 'Álex', 'Delgado', 22, 'alex.delgado@alum.us.es'), -- Estudiante
    (25, '10000025A', 'Paula', 'Bermejo', 21, 'paula.bermejo@alum.us.es'); -- Estudiante


INSERT INTO professors (professor_id, category) VALUES
    (1, 'Catedrático'),
    (2, 'Titular'),
    (3, 'AyudanteDoctor'),
    (4, 'Titular'),
    (5, 'Ayudante');

INSERT INTO students (student_id, access_method) VALUES
    (6, 'Selectividad'),
    (7, 'Selectividad'),
    (8, 'Selectividad'),
    (9, 'Selectividad'),
    (10, 'Selectividad'),
    (11, 'Selectividad'),
    (12, 'Selectividad'),
    (13, 'Selectividad'),
    (14, 'Selectividad'),
    (15, 'Selectividad'),
    (16, 'Selectividad'),
    (17, 'Selectividad'),
    (18, 'Selectividad'),
    (19, 'Selectividad'),
    (20, 'Selectividad'),
    (21, 'Selectividad'),
    (22, 'Selectividad'),
    (23, 'Selectividad'),
    (24, 'Selectividad'),
    (25, 'Selectividad');

