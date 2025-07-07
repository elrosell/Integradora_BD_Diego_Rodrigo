
-- 5. Script para creación de triggers

DELIMITER $$

-- Trigger para disminuir existencias al insertar en ProductoVenta
CREATE TRIGGER trg_producto_venta_ai
AFTER INSERT ON ProductoVenta
FOR EACH ROW
BEGIN
  UPDATE Producto
  SET existencias = existencias - NEW.cantidad
  WHERE id_producto = NEW.id_producto;
END $$

-- Trigger para aumentar existencias al eliminar detalle de venta
CREATE TRIGGER trg_producto_venta_ad
AFTER DELETE ON ProductoVenta
FOR EACH ROW
BEGIN
  UPDATE Producto
  SET existencias = existencias + OLD.cantidad
  WHERE id_producto = OLD.id_producto;
END $$

DELIMITER ;
