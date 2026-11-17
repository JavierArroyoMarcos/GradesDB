--
-- Autor: Javier Arroyo Marcos
-- Fecha: 17/11
-- Descripción: 
-- Se incluye en: 
--


DROP TABLE IF EXISTS people; -- Elimina la tabla si ya existía 

CREATE TABLE people (       
    person_id INT AUTO_INCREMENT, -- Crea una columna de números enteros que se numera automáticamente (1, 2, 3...).
    dni CHAR(9) NOT NULL,         -- Deja un hueco de 9 caracteres. No puede dejarse en blanco (NOT NULL).
    first_name VARCHAR(100) NOT NULL, -- Texto de hasta 100 caracteres. Más que Char
    last_name VARCHAR(150) NOT NULL,  
    age TINYINT NOT NULL,         -- Número entero pequeño (0-255)
    email VARCHAR(255) NOT NULL,  
    PRIMARY KEY (person_id)       -- Define 'person_id' como el identificador único principal de cada registro en la tabla.
);                           