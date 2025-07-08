
-- 3. Script para creación de procedimientos almacenados

DELIMITER $$

-- 1. Procedimiento: Obtener funciones compradas de un cliente
CREATE PROCEDURE sp_funciones_cliente(IN p_id_cliente INT)
BEGIN
  SELECT p.titulo, f.fecha_funcion, f.hora_inicio
  FROM Venta v
  JOIN BoletoVenta bv ON bv.id_venta = v.id_venta
  JOIN Funcion f ON f.id_funcion = bv.id_funcion
  JOIN Pelicula p ON p.id_pelicula = f.id_pelicula
  WHERE v.id_cliente = p_id_cliente;
END $$

-- 2a. Insertar Cliente con validaciones
CREATE PROCEDURE sp_insert_cliente(
  IN p_nombre VARCHAR(50),
  IN p_ap_paterno VARCHAR(50),
  IN p_ap_materno VARCHAR(50),
  IN p_fecha_nac DATE,
  IN p_correo VARCHAR(100)
)
BEGIN
  DECLARE edad INT;
  DECLARE existe INT;
  SET edad = TIMESTAMPDIFF(YEAR, p_fecha_nac, CURDATE());
  IF edad < 18 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente menor de edad';
  END IF;
  SELECT COUNT(*) INTO existe FROM ContactoCliente WHERE valor = p_correo;
  IF existe > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Correo ya existente';
  END IF;
  INSERT INTO Cliente(nombre, apellido_paterno, apellido_materno, fecha_nacimiento) 
    VALUES(p_nombre, p_ap_paterno, p_ap_materno, p_fecha_nac);
  INSERT INTO ContactoCliente(id_cliente, tipo, valor) 
    VALUES(LAST_INSERT_ID(), 'correo', p_correo);
END $$

-- 2b. Insertar Complejo
CREATE PROCEDURE sp_insert_complejo(IN p_nombre VARCHAR(100),
                                               IN p_ciudad VARCHAR(100),
                                               IN p_estado VARCHAR(100),
                                               IN p_direccion VARCHAR(255))
BEGIN
  DECLARE existe INT;
  SELECT COUNT(*) INTO existe FROM Complejo WHERE nombre = p_nombre;
  IF existe > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre de complejo existente';
  END IF;
  INSERT INTO Complejo(nombre, ciudad, estado, direccion)
  VALUES(p_nombre, p_ciudad, p_estado, p_direccion);
END $$

-- 2c. Insertar Producto
CREATE PROCEDURE sp_insert_producto(IN p_nombre VARCHAR(100),
                                               IN p_tipo ENUM('alimento','promocional'),
                                               IN p_precio DECIMAL(6,2),
                                               IN p_existencias INT)
BEGIN
  IF p_existencias > 5 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existencias máximas superadas';
  END IF;
  INSERT INTO Producto(nombre, tipo, precio, existencias)
  VALUES(p_nombre, p_tipo, p_precio, p_existencias);
END $$

-- 2d. Insertar Funcion
CREATE PROCEDURE sp_insert_funcion(
  IN p_id_sala INT,
  IN p_id_pelicula INT,
  IN p_fecha DATE,
  IN p_hora_inicio TIME,
  IN p_hora_fin TIME,
  IN p_precio DECIMAL(6,2)
)
BEGIN
  DECLARE existe INT;
  SELECT COUNT(*) INTO existe
    FROM Funcion
    WHERE id_sala = p_id_sala AND fecha_funcion = p_fecha AND hora_inicio = p_hora_inicio;
  IF existe > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una función en esa sala y horario';
  END IF;
  INSERT INTO Funcion(id_sala, id_pelicula, fecha_funcion, hora_inicio, hora_fin, precio_boleto)
  VALUES(p_id_sala, p_id_pelicula, p_fecha, p_hora_inicio, p_hora_fin, p_precio);
END $$

-- 3. Procedimientos de eliminación (genéricos usando SQL dinámico)
CREATE PROCEDURE sp_delete_empleado(IN p_id INT)
BEGIN
  DELETE FROM Empleado WHERE id_empleado = p_id;
END $$

CREATE PROCEDURE sp_delete_producto(IN p_id INT)
BEGIN
  DELETE FROM Producto WHERE id_producto = p_id;
END $$

-- 4. Procedimientos de modificación (ejemplo para cliente y producto)
CREATE PROCEDURE sp_update_cliente_correo(IN p_id_cliente INT, IN p_nuevo_correo VARCHAR(100))
BEGIN
  UPDATE ContactoCliente SET valor = p_nuevo_correo
  WHERE id_cliente = p_id_cliente AND tipo = 'correo';
END $$

CREATE PROCEDURE sp_update_producto_precio(IN p_id_producto INT, IN p_precio DECIMAL(6,2))
BEGIN
  UPDATE Producto SET precio = p_precio WHERE id_producto = p_id_producto;
END $$

-- 5. Procedimiento clientes con boletos para función específica
CREATE PROCEDURE sp_clientes_funcion_fecha(
  IN p_id_funcion INT,
  IN p_fecha DATE
)
BEGIN
  SELECT DISTINCT c.*
  FROM Venta v
  JOIN BoletoVenta bv ON bv.id_venta = v.id_venta
  JOIN Cliente c ON c.id_cliente = v.id_cliente
  WHERE bv.id_funcion = p_id_funcion AND DATE(v.fecha_venta) = p_fecha;
END $$

-- 6. Procedimiento datos clientes por complejo
CREATE PROCEDURE sp_clientes_complejo(
  IN p_id_complejo INT
)
BEGIN
  SELECT DISTINCT c.*
  FROM Venta v
  JOIN Cliente c ON c.id_cliente = v.id_cliente
  WHERE v.id_complejo = p_id_complejo;
END $$

DELIMITER ;
