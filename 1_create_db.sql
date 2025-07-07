
-- 1. Script para creación de BD, tablas e inserción de registros.
DROP DATABASE IF EXISTS cineplus;
CREATE DATABASE cineplus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cineplus;

-- Tabla Complejo
CREATE TABLE Complejo (
    id_complejo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    ciudad VARCHAR(100),
    estado VARCHAR(100),
    direccion VARCHAR(255)
);

-- Tabla Sala
CREATE TABLE Sala (
    id_sala INT AUTO_INCREMENT PRIMARY KEY,
    id_complejo INT NOT NULL,
    nombre VARCHAR(50),
    tipo ENUM('2D','3D','4D','VIP') DEFAULT '2D',
    capacidad INT,
    espacios_especiales INT DEFAULT 2,
    UNIQUE(nombre, id_complejo),
    FOREIGN KEY (id_complejo) REFERENCES Complejo(id_complejo)
);

-- Tabla Empleado
CREATE TABLE Empleado (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    id_complejo INT NOT NULL,
    nombre VARCHAR(50),
    apellido_paterno VARCHAR(50),
    apellido_materno VARCHAR(50),
    fecha_nacimiento DATE,
    rfc VARCHAR(13) UNIQUE,
    fecha_contratacion DATE,
    FOREIGN KEY (id_complejo) REFERENCES Complejo(id_complejo)
);

-- Tabla Cliente
CREATE TABLE Cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido_paterno VARCHAR(50),
    apellido_materno VARCHAR(50),
    fecha_nacimiento DATE,
    fecha_alta DATE DEFAULT CURRENT_DATE
);

-- Tabla ContactoCliente
CREATE TABLE ContactoCliente (
    id_contacto INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    tipo ENUM('telefono','correo') NOT NULL,
    valor VARCHAR(100),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

-- Tabla DireccionCliente
CREATE TABLE DireccionCliente (
    id_direccion INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    calle VARCHAR(100),
    num_ext VARCHAR(10),
    num_int VARCHAR(10),
    colonia VARCHAR(100),
    municipio VARCHAR(100),
    estado VARCHAR(100),
    cp VARCHAR(10),
    pais VARCHAR(50),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

-- Tabla Pelicula
CREATE TABLE Pelicula (
    id_pelicula INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150),
    genero VARCHAR(50),
    duracion_min INT,
    clasificacion ENUM('AA','A','B','B15','C','D'),
    restriccion_min_edad INT NULL
);

-- Tabla Funcion
CREATE TABLE Funcion (
    id_funcion INT AUTO_INCREMENT PRIMARY KEY,
    id_sala INT,
    id_pelicula INT,
    fecha_funcion DATE,
    hora_inicio TIME,
    hora_fin TIME,
    precio_boleto DECIMAL(6,2),
    UNIQUE(id_sala, fecha_funcion, hora_inicio),
    FOREIGN KEY (id_sala) REFERENCES Sala(id_sala),
    FOREIGN KEY (id_pelicula) REFERENCES Pelicula(id_pelicula)
);

-- Tabla Producto
CREATE TABLE Producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    tipo ENUM('alimento','promocional'),
    precio DECIMAL(6,2),
    existencias INT CHECK (existencias <= 5)
);

-- Tabla Venta
CREATE TABLE Venta (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    id_empleado INT,
    id_complejo INT,
    fecha_venta DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
    FOREIGN KEY (id_complejo) REFERENCES Complejo(id_complejo)
);

-- Tabla BoletoVenta
CREATE TABLE BoletoVenta (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    id_funcion INT,
    cantidad INT CHECK (cantidad BETWEEN 1 AND 5),
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
    FOREIGN KEY (id_funcion) REFERENCES Funcion(id_funcion)
);

-- Tabla ProductoVenta
CREATE TABLE ProductoVenta (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    id_producto INT,
    cantidad INT CHECK (cantidad BETWEEN 1 AND 5),
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

-- Inserts de ejemplo (5 registros cada tabla)
INSERT INTO Complejo(nombre, ciudad, estado, direccion) VALUES
('CINE+ Centro', 'Ciudad de México', 'CDMX', 'Av. Reforma 100'),
('CINE+ Norte', 'Monterrey', 'Nuevo León', 'Calz. Universidad 200'),
('CINE+ Sur', 'Guadalajara', 'Jalisco', 'Av. Vallarta 300'),
('CINE+ Playa', 'Cancún', 'Quintana Roo', 'Blvd. Kukulcán 400'),
('CINE+ Bajío', 'León', 'Guanajuato', 'Blvd. Aeropuerto 500');

INSERT INTO Sala(id_complejo, nombre, tipo, capacidad) VALUES
(1, 'Sala 1', '2D', 120),
(1, 'Sala 2', 'VIP', 80),
(2, 'Sala 1', '3D', 100),
(3, 'Sala 1', '4D', 90),
(4, 'Sala 1', '2D', 110);

INSERT INTO Empleado(id_complejo, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, rfc, fecha_contratacion) VALUES
(1, 'Luis', 'Pérez', 'Lopez', '1990-05-10', 'PEL900510ABC', '2020-01-01'),
(1, 'Ana', 'García', 'Martínez', '1985-03-20', 'GAMA850320DEF', '2019-06-15'),
(2, 'Carlos', 'Hernández', 'Soto', '1992-07-08', 'HESC920708GHI', '2021-09-10'),
(3, 'María', 'Rodríguez', 'Ruiz', '1998-11-30', 'RORU981130JKL', '2024-02-20'),
(4, 'José', 'López', 'Gómez', '1980-12-01', 'LOGO801201MNO', '2018-08-05');

INSERT INTO Cliente(nombre, apellido_paterno, apellido_materno, fecha_nacimiento) VALUES
('Juan', 'Torres', 'Diaz', '1995-02-15'),
('Lucía', 'Mendoza', 'Jiménez', '2000-06-22'),
('Pedro', 'Ramírez', 'Santos', '1988-10-03'),
('Sofía', 'Hernández', 'Luna', '1975-01-18'),
('Miguel', 'Castro', 'Núñez', '2010-09-25'); -- menor para validación

INSERT INTO ContactoCliente(id_cliente, tipo, valor) VALUES
(1, 'correo', 'juan.torres@example.com'),
(1, 'telefono', '5551234567'),
(2, 'correo', 'lucia.mj@example.com'),
(3, 'telefono', '8189876543'),
(4, 'correo', 'sofia.hl@example.com');

INSERT INTO Pelicula(titulo, genero, duracion_min, clasificacion, restriccion_min_edad) VALUES
('Terror en la Noche', 'Terror', 110, 'C', 18),
('Amor de Verano', 'Romance', 95, 'B', 15),
('Mundo Dino', 'Infantil', 100, 'AA', NULL),
('Carrera Mortal', 'Acción', 105, 'B15', 15),
('La Risa Final', 'Comedia', 98, 'A', NULL);

INSERT INTO Funcion(id_sala, id_pelicula, fecha_funcion, hora_inicio, hora_fin, precio_boleto) VALUES
(1, 1, '2025-07-08', '20:00:00', '21:50:00', 120.00),
(2, 2, '2025-07-08', '18:30:00', '20:05:00', 150.00),
(3, 3, '2025-07-08', '16:00:00', '17:40:00', 100.00),
(4, 4, '2025-07-08', '19:00:00', '20:45:00', 130.00),
(5, 5, '2025-07-08', '17:00:00', '18:38:00', 110.00);

INSERT INTO Producto(nombre, tipo, precio, existencias) VALUES
('Combo Palomitas', 'alimento', 80.00, 5),
('Vaso Coleccionable Dino', 'promocional', 60.00, 5),
('Refresco 1L', 'alimento', 45.00, 5),
('Llaveros Película', 'promocional', 35.00, 5),
('Nachos', 'alimento', 70.00, 5);
