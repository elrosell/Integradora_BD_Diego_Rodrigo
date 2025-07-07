
-- 4. Script para llamada de procedimientos

-- Ejemplos de uso
CALL sp_insert_cliente('Roberto','Silva','Mora','1990-03-03','roberto.silva@example.com');
CALL sp_insert_complejo('CINE+ Querétaro','Querétaro','Querétaro','Av. 5 de Febrero 600');
CALL sp_insert_producto('Gorra Edición', 'promocional', 120.00, 5);
CALL sp_insert_funcion(1, 2, '2025-07-10','21:00:00','22:40:00', 140.00);

CALL sp_funciones_cliente(1);

CALL sp_update_producto_precio(1, 85.00);
CALL sp_delete_producto(5);
