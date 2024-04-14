-- Creación de tablas principales
CREATE TABLE Estudiantes (
    estudiante_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    fecha_nacimiento DATE,
    direccion TEXT,
    contacto VARCHAR(20),
    datos_academicos TEXT,
    estado_matricula boolean
);

CREATE TABLE Cursos (
    curso_id SERIAL PRIMARY KEY,
    nombre_curso VARCHAR(100),
    descripcion TEXT,
    horarios TEXT,
    requisitos TEXT,
	cupos_disponibles INT
);

CREATE TABLE Profesores (
    profesor_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    especialidad TEXT,
    horarios TEXT,
    contacto VARCHAR(20)
);

CREATE TABLE Calificaciones (
    calificacion_id SERIAL PRIMARY KEY,
    estudiante_id INT REFERENCES Estudiantes(estudiante_id),
    curso_id INT REFERENCES Cursos(curso_id),
    nota DECIMAL(4,2),
    fecha DATE,
    observaciones TEXT
);

CREATE TABLE Horarios (
    horario_id SERIAL PRIMARY KEY,
    curso_id INT REFERENCES Cursos(curso_id),
    dia_semana VARCHAR(10),
    hora TIME,
    aula VARCHAR(10)
);

-- Creación de tablas auxiliares
CREATE TABLE Departamentos_Academicos (
    departamento_id SERIAL PRIMARY KEY,
    nombre_departamento VARCHAR(100)
);

CREATE TABLE Matriculas (
    matricula_id SERIAL PRIMARY KEY,
    estudiante_id INT REFERENCES Estudiantes(estudiante_id),
    curso_id INT REFERENCES Cursos(curso_id),
    fecha_matricula DATE,
    estado VARCHAR(20)
);

CREATE TABLE Eventos_Academicos (
    evento_id SERIAL PRIMARY KEY,
    nombre_evento VARCHAR(100),
    fecha DATE,
    descripcion TEXT
);

-- Creación de tabla para la gestión de biblioteca
CREATE TABLE Biblioteca (
    libro_id SERIAL PRIMARY KEY,
    titulo VARCHAR(200),
    autor VARCHAR(100),
    cantidad_disponible INT,
    cantidad_prestada INT
);

--Creación de la tabla Boletines
CREATE TABLE Boletines (
    boletin_id SERIAL PRIMARY KEY,
    estudiante_id INT,
    fecha_emision DATE,
    rendimiento_academico TEXT,
    comentarios TEXT,
    FOREIGN KEY (estudiante_id) REFERENCES Estudiantes(estudiante_id)
);


--Creacion de la tabla Prestamos

CREATE TABLE Prestamos (
    prestamo_id SERIAL PRIMARY KEY,
    libro_id INT REFERENCES Biblioteca(libro_id),
    estudiante_id INT REFERENCES Estudiantes(estudiante_id),
    fecha_prestamo DATE,
    fecha_devolucion DATE,
    estado VARCHAR(20) 
);


ALTER TABLE Cursos
ADD COLUMN cantidad_estudiantes INT DEFAULT 0;

-- Agregar una columna a la tabla Profesores para almacenar el ID del curso que imparte el profesor
ALTER TABLE Profesores
ADD COLUMN curso_id INT,
ADD CONSTRAINT fk_curso_id
    FOREIGN KEY (curso_id)
    REFERENCES Cursos(curso_id);

-- Creación de usuarios
CREATE ROLE admin_user WITH LOGIN PASSWORD 'admin_password';
CREATE ROLE teacher_user WITH LOGIN PASSWORD 'teacher_password';
CREATE ROLE student_user WITH LOGIN PASSWORD 'student_password';

-- Otorgar privilegios a los usuarios en las tablas necesarias
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO admin_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO teacher_user;
GRANT SELECT, INSERT, UPDATE ON Estudiantes, Matriculas TO student_user;


--Crear función para actualizar la cantidad de estudiantes matriculados en un curso:
CREATE OR REPLACE FUNCTION actualizar_cantidad_estudiantes()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Cursos
    SET cantidad_estudiantes = (
        SELECT COUNT(*)
        FROM Matriculas
        WHERE curso_id = NEW.curso_id
    )
    WHERE curso_id = NEW.curso_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER actualizar_cantidad_estudiantes_trigger
AFTER INSERT OR DELETE ON Matriculas
FOR EACH ROW
EXECUTE FUNCTION actualizar_cantidad_estudiantes();


--Crear función para verificar la edad del estudiante al momento de la matrícula:
CREATE OR REPLACE FUNCTION verificar_edad_estudiante()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT fecha_nacimiento FROM Estudiantes WHERE estudiante_id = NEW.estudiante_id) > current_date - interval '18 years' THEN
        RAISE EXCEPTION 'El estudiante debe ser mayor de edad para matricularse.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verificar_edad_estudiante_trigger
BEFORE INSERT ON Matriculas
FOR EACH ROW
EXECUTE FUNCTION verificar_edad_estudiante();

--Crear función para verificar la disponibilidad de cupos en el curso:
CREATE OR REPLACE FUNCTION verificar_disponibilidad_cupos()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM Matriculas WHERE curso_id = NEW.curso_id) >= (SELECT cupos_disponibles FROM Cursos WHERE curso_id = NEW.curso_id) THEN
        RAISE EXCEPTION 'El curso ya tiene el máximo número de estudiantes matriculados.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verificar_disponibilidad_cupos_trigger
BEFORE INSERT ON Matriculas
FOR EACH ROW
EXECUTE FUNCTION verificar_disponibilidad_cupos();


--Índices:
--Vamos a crear índices en columnas que se utilicen frecuentemente en consultas para mejorar la velocidad de búsqueda.

-- Índice en la columna curso_id de la tabla Matriculas
CREATE INDEX idx_matriculas_curso_id ON Matriculas (curso_id);

-- Índice en la columna estudiante_id de la tabla Matriculas
CREATE INDEX idx_matriculas_estudiante_id ON Matriculas (estudiante_id);

-- Índice en la columna nombre de la tabla Estudiantes
CREATE INDEX idx_estudiantes_nombre ON Estudiantes (nombre);

-- Índice en la columna nombre_curso de la tabla Cursos
CREATE INDEX idx_cursos_nombre_curso ON Cursos (nombre_curso);


--Vamos a usar una función de ventana para calcular el promedio de calificaciones por curso.
CREATE VIEW PromedioCalificaciones AS
SELECT
    curso_id,
    AVG(nota) OVER (PARTITION BY curso_id) AS promedio_calificaciones
FROM
    Calificaciones;

-- Consulta para obtener el rendimiento académico promedio por estudiante
CREATE VIEW RendimientoEstudiantes AS
SELECT estudiante_id, AVG(nota) AS rendimiento_academico_promedio
FROM Calificaciones
GROUP BY estudiante_id;


--Cláusula WITH:
--Utilizaremos la cláusula WITH para simplificar consultas complejas y mejorar la legibilidad del código.
WITH EstudiantesMatriculados AS (
    SELECT
        curso_id,
        COUNT(*) AS num_estudiantes_matriculados
    FROM
        Matriculas
    GROUP BY
        curso_id
)
SELECT
    C.nombre_curso,
    EM.num_estudiantes_matriculados
FROM
    Cursos C
JOIN
    EstudiantesMatriculados EM ON C.curso_id = EM.curso_id;


--30 ejemplos para la tabla "Estudiantes":
INSERT INTO Estudiantes (nombre, fecha_nacimiento, direccion, contacto, datos_academicos) VALUES
('María Martínez', '2002-03-15', 'Calle 1, Ciudad A', '555-1234', 'Estudiante de segundo año'),
('Juan García', '2001-06-20', 'Avenida 2, Ciudad B', '555-5678', 'Estudiante de primer año'),
('Luis Hernández', '2000-09-25', 'Carrera 3, Ciudad C', '555-9012', 'Estudiante de tercer año'),
('Ana López', '2003-12-10', 'Calle 4, Ciudad D', '555-3456', 'Estudiante de cuarto año'),
('Pedro Sánchez', '2002-07-05', 'Avenida 5, Ciudad E', '555-7890', 'Estudiante de segundo año'),
('Laura Rodríguez', '2001-02-28', 'Calle 6, Ciudad F', '555-2345', 'Estudiante de primer año'),
('Carlos Pérez', '2000-05-15', 'Avenida 7, Ciudad G', '555-6789', 'Estudiante de tercer año'),
('Sofía Gómez', '2003-10-20', 'Carrera 8, Ciudad H', '555-3210', 'Estudiante de segundo año'),
('Diego González', '2001-08-01', 'Calle 9, Ciudad I', '555-8901', 'Estudiante de cuarto año'),
('Fernanda Torres', '2000-11-12', 'Avenida 10, Ciudad J', '555-4321', 'Estudiante de tercer año'),
('Pablo Castro', '2002-04-17', 'Calle 11, Ciudad K', '555-6789', 'Estudiante de primer año'),
('Carmen Ruiz', '2001-07-25', 'Avenida 12, Ciudad L', '555-0987', 'Estudiante de segundo año'),
('Javier Medina', '2000-09-30', 'Carrera 13, Ciudad M', '555-2345', 'Estudiante de tercer año'),
('Lucía Díaz', '2003-01-05', 'Calle 14, Ciudad N', '555-5678', 'Estudiante de cuarto año'),
('Mario Vargas', '2001-05-18', 'Avenida 15, Ciudad O', '555-9012', 'Estudiante de primer año'),
('Andrea Castro', '2000-08-22', 'Carrera 16, Ciudad P', '555-3456', 'Estudiante de tercer año'),
('Gabriel Molina', '2003-11-27', 'Calle 17, Ciudad Q', '555-7890', 'Estudiante de segundo año'),
('Valeria Jiménez', '2002-02-03', 'Avenida 18, Ciudad R', '555-1234', 'Estudiante de cuarto año'),
('Daniel Ramírez', '2001-06-10', 'Carrera 19, Ciudad S', '555-5678', 'Estudiante de segundo año'),
('Natalia Herrera', '2000-10-16', 'Calle 20, Ciudad T', '555-9012', 'Estudiante de tercer año'),
('Ricardo Silva', '2003-03-20', 'Avenida 21, Ciudad U', '555-2345', 'Estudiante de primer año'),
('Camila Rojas', '2002-05-26', 'Carrera 22, Ciudad V', '555-6789', 'Estudiante de segundo año'),
('Julián Mendoza', '2001-08-29', 'Calle 23, Ciudad W', '555-0987', 'Estudiante de cuarto año'),
('Isabella Guzmán', '2000-12-05', 'Avenida 24, Ciudad X', '555-3210', 'Estudiante de tercer año'),
('Santiago Ortega', '2003-01-11', 'Carrera 25, Ciudad Y', '555-5678', 'Estudiante de segundo año'),
('Paula Núñez', '2001-04-08', 'Calle 26, Ciudad Z', '555-8901', 'Estudiante de primer año'),
('Mateo Reyes', '2000-07-14', 'Avenida 27, Ciudad AA', '555-2345', 'Estudiante de tercer año'),
('Valentina Medina', '2003-09-21', 'Carrera 28, Ciudad BB', '555-6789', 'Estudiante de segundo año'),
('Emilio Vargas', '2002-02-27', 'Calle 29, Ciudad CC', '555-9012', 'Estudiante de cuarto año'),
('Sergio Martinez','2002-02-09','Calle 30 , Ciudad DD', '555-5521','Estudiante de tercer año');

--Para la tabla “Cursos":
INSERT INTO Cursos (nombre_curso, descripcion, horarios, requisitos) VALUES
('Física', 'Curso de física básica', 'Lunes y Miércoles 8:00-10:00', 'Ninguno'),
('Química', 'Curso de química orgánica', 'Martes y Jueves 10:00-12:00', 'Ninguno'),
('Literatura', 'Curso de literatura universal', 'Viernes 14:00-16:00', 'Ninguno'),
('Programación', 'Curso de programación en Python', 'Lunes y Miércoles 16:00-18:00', 'Conocimientos básicos de informática'),
('Música', 'Curso de teoría musical', 'Martes y Jueves 14:00-16:00', 'Ninguno'),
('Dibujo', 'Curso de dibujo artístico', 'Miércoles y Viernes 16:00-18:00', 'Ninguno'),
('Geografía', 'Curso de geografía mundial', 'Lunes y Jueves 14:00-16:00', 'Ninguno'),
('Educación Física', 'Curso de educación física', 'Martes y Viernes 8:00-10:00', 'Ninguno'),
('Filosofía', 'Curso de filosofía antigua y moderna', 'Miércoles 10:00-12:00', 'Ninguno'),
('Arqueología', 'Curso de arqueología', 'Jueves 16:00-18:00', 'Ninguno'),
('Economía', 'Curso de economía básica', 'Lunes 10:00-12:00', 'Ninguno'),
('Psicología', 'Curso de psicología general', 'Miércoles y Viernes 14:00-16:00', 'Ninguno'),
('Sociología', 'Curso de sociología contemporánea', 'Jueves 10:00-12:00', 'Ninguno'),
('Estadística', 'Curso de estadística aplicada', 'Viernes 10:00-12:00', 'Ninguno'),
('Ciencias Políticas', 'Curso de ciencias políticas', 'Lunes y Miércoles 14:00-16:00', 'Ninguno'),
('Antropología', 'Curso de antropología cultural', 'Martes 16:00-18:00', 'Ninguno'),
('Arquitectura', 'Curso de historia de la arquitectura', 'Miércoles 14:00-16:00', 'Ninguno'),
('Nutrición', 'Curso de nutrición y salud', 'Jueves 8:00-10:00', 'Ninguno'),
('Biografías', 'Curso de biografías de personajes históricos', 'Viernes 16:00-18:00', 'Ninguno'),
('Cine', 'Curso de análisis cinematográfico', 'Lunes y Jueves 16:00-18:00', 'Ninguno'),
('Ecología', 'Curso de ecología ambiental', 'Martes 10:00-12:00', 'Ninguno'),
('Literatura Infantil', 'Curso de literatura infantil', 'Miércoles 16:00-18:00', 'Ninguno'),
('Marketing', 'Curso de marketing digital', 'Jueves 14:00-16:00', 'Ninguno'),
('Derecho', 'Curso de introducción al derecho', 'Viernes 10:00-12:00', 'Ninguno'),
('Teatro', 'Curso de teatro clásico', 'Lunes y Miércoles 10:00-12:00', 'Ninguno'),
('Medicina', 'Curso de introducción a la medicina', 'Martes y Jueves 8:00-10:00', 'Ninguno'),
('Historia del Arte', 'Curso de historia del arte', 'Miércoles y Viernes 10:00-12:00', 'Ninguno'),
('Robótica', 'Curso de robótica aplicada', 'Jueves y Viernes 16:00-18:00', 'Conocimientos básicos de electrónica'),
('Literatura Latinoamericana', 'Curso de literatura latinoamericana', 'Lunes 16:00-18:00', 'Ninguno'),
('Fotografía', 'Curso de fotografía digital', 'Martes y Miércoles 14:00-16:00', 'Ninguno');


--Y ahora para la tabla “Matriculas":
INSERT INTO Matriculas (estudiante_id, curso_id, fecha_matricula, estado) VALUES
(1, 1, '2024-03-01', 'Activa'),
(2, 2, '2024-03-05', 'Activa'),
(3, 3, '2024-03-10', 'Activa'),
(4, 4, '2024-03-15', 'Activa'),
(5, 5, '2024-03-20', 'Activa'),
(6, 6, '2024-03-25', 'Activa'),
(7, 7, '2024-04-01', 'Activa'),
(8, 8, '2024-04-05', 'Activa'),
(9, 9, '2024-04-10', 'Activa'),
(10, 10, '2024-04-15', 'Activa'),
(11, 11, '2024-04-20', 'Activa'),
(12, 12, '2024-04-25', 'Activa'),
(13, 13, '2024-05-01', 'Activa'),
(14, 14, '2024-05-05', 'Activa'),
(15, 15, '2024-05-10', 'Activa'),
(16, 16, '2024-05-15', 'Activa'),
(17, 17, '2024-05-20', 'Activa'),
(18, 18, '2024-05-25', 'Activa'),
(19, 19, '2024-06-01', 'Activa'),
(20, 20, '2024-06-05', 'Activa'),
(21, 21, '2024-06-10', 'Activa'),
(22, 22, '2024-06-15', 'Activa'),
(23, 23, '2024-06-20', 'Activa'),
(24, 24, '2024-06-25', 'Activa'),
(25, 25, '2024-07-01', 'Activa'),
(26, 26, '2024-07-05', 'Activa'),
(27, 27, '2024-07-10', 'Activa'),
(28, 28, '2024-07-15', 'Activa'),
(29, 29, '2024-07-20', 'Activa'),
(30, 30, '2024-07-25', 'Activa');

--Vista materializada:
--Vamos a crear una vista materializada para almacenar el número de estudiantes matriculados en cada curso.
CREATE MATERIALIZED VIEW NumeroEstudiantesMatriculados AS
SELECT
    curso_id,
    COUNT(*) AS num_estudiantes_matriculados
FROM
    Matriculas
GROUP BY
    curso_id;

--Implementación de sentencias preparadas:
-- Creación de una sentencia preparada para obtener estudiantes matriculados en un curso
PREPARE obtener_estudiantes_matriculados (INT) AS
SELECT E.*
FROM Estudiantes E
INNER JOIN Matriculas M ON E.estudiante_id = M.estudiante_id
WHERE M.curso_id = $1;

-- Ejecución de la sentencia preparada para obtener estudiantes matriculados en un curso específico (curso_id = 1)
EXECUTE obtener_estudiantes_matriculados(1);

-- Limpieza de la sentencia preparada después de su uso
DEALLOCATE obtener_estudiantes_matriculados;


--Funcionalidades Adicionales:
CREATE OR REPLACE FUNCTION calcular_rendimiento_academico(estudiante_id INT)
RETURNS DECIMAL(4,2) AS $$
DECLARE
    rendimiento DECIMAL(4,2);
BEGIN
    SELECT AVG(nota) INTO rendimiento
    FROM Calificaciones
    WHERE estudiante_id = calcular_rendimiento_academico.estudiante_id;
    
    RETURN rendimiento;
END;
$$ LANGUAGE plpgsql;


--Luego, podemos utilizar esta función para generar automáticamente los boletines académicos al insertar una nueva entrada en la tabla Boletines:
CREATE OR REPLACE FUNCTION generar_boletin_academico()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Boletines (estudiante_id, fecha_emision, rendimiento_academico, comentarios)
    VALUES (NEW.estudiante_id, current_date, calcular_rendimiento_academico(NEW.estudiante_id), 'Rendimiento académico generado automáticamente.');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generar_boletin_academico_trigger
AFTER INSERT ON Calificaciones
FOR EACH ROW
EXECUTE FUNCTION generar_boletin_academico();

-- --Manejo de situaciones de error:
-- -- Intento de inserción de calificación fuera del rango permitido
-- INSERT INTO Calificaciones (estudiante_id, curso_id, nota, fecha, observaciones) VALUES (1, 1, 110, '2024-03-01', 'Fuera del rango');
-- --Intentaremos matricular a un estudiante en un curso que ya está lleno:
-- -- Simulación de un curso lleno
-- UPDATE Cursos SET cupo_maximo = 0 WHERE curso_id = 1;

-- -- Intento de matricular a un estudiante en un curso lleno
-- INSERT INTO Matriculas (estudiante_id, curso_id, fecha_matricula, estado) VALUES (2, 1, '2024-03-01', 'Activa');
