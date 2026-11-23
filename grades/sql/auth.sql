--
-- Autor: Javier Arroyo Marcos
-- Fecha: 23/11
-- Descripción: Añadir sistema login a la tabla people
-- Se incluye en: Lab 6
--

-- 1 Añadir columnas y reglas
ALTER TABLE people
  ADD COLUMN password VARCHAR(128),
  ADD COLUMN role     VARCHAR(10),
  ADD CONSTRAINT ck_people_rnf01_role CHECK (role IN ('admin', 'teacher', 'student'));

-- 2 Rellenar contraseñas
UPDATE people SET password = SUBSTRING_INDEX(email, '@', 1);  -- contraseña.

-- 3 Hacer la contraseña obligatorio
ALTER TABLE people MODIFY password VARCHAR(128) NOT NULL;
-- SUBSTRING_INDEX(email, '@', 1): Corta un texto   email(texto original)  @(separador donde se hace el corte)   1(dominio de la izquierda)

-- 4. Asignar el rol a cada persona según su tabla (student, teacher o admin)
UPDATE people SET role = 'student'   -- Alumnos
  WHERE person_id IN (SELECT student_id FROM students);
UPDATE people SET role = 'teacher'  -- Profesores
  WHERE person_id IN (SELECT professor_id FROM professors);
UPDATE people SET role = 'admin' WHERE person_id = 1;  -- Administrador. Dado q en nuestros datos actuales no hay personal ni docente usamos la persona 1.