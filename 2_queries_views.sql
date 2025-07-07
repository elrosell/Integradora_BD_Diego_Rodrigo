
-- 2. Script para creación de consultas y vistas

-- Consulta 1: Ver todos los clientes con más de 3 visitas y menos de 5 en un mes
SELECT c.*, COUNT(v.id_venta) AS visitas_mes
FROM Cliente c
JOIN Venta v ON v.id_cliente = c.id_cliente
WHERE YEAR(v.fecha_venta) = YEAR(CURDATE()) AND MONTH(v.fecha_venta) = MONTH(CURDATE())
GROUP BY c.id_cliente
HAVING visitas_mes > 3 AND visitas_mes < 5;

-- Consulta 2: Clientes que cumplen años agrupados por mes
SELECT MONTH(fecha_nacimiento) AS mes, GROUP_CONCAT(CONCAT(nombre, ' ', apellido_paterno) SEPARATOR ', ') AS clientes
FROM Cliente
GROUP BY mes;

-- Consulta 3: Funciones con palabras clave Terror, Muerte, Miedo
SELECT f.*
FROM Funcion f
JOIN Pelicula p ON p.id_pelicula = f.id_pelicula
WHERE p.titulo REGEXP 'TERROR|MUERTE|MIEDO';

-- Consulta 4: Total de ventas agrupado por complejo
SELECT co.nombre, SUM(v.total) AS total_ventas
FROM Venta v
JOIN Complejo co ON co.id_complejo = v.id_complejo
GROUP BY co.id_complejo;

-- Consulta 5: Funciones de enero 2024 a mayo 2025
SELECT * FROM Funcion
WHERE fecha_funcion BETWEEN '2024-01-01' AND '2025-05-31';

-- Consulta 6: Clientes > 30 años
SELECT *, TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) AS edad
FROM Cliente
HAVING edad > 30;

-- Consulta 7: Total clientes por complejo
SELECT co.nombre, COUNT(DISTINCT v.id_cliente) AS total_clientes
FROM Venta v
JOIN Complejo co ON co.id_complejo = v.id_complejo
GROUP BY co.id_complejo;

-- Consulta 8: Cliente con mayor antigüedad por sucursal
SELECT sub.*
FROM (
  SELECT v.id_complejo, cl.*, MIN(v.fecha_venta) AS primera_compra,
       ROW_NUMBER() OVER (PARTITION BY v.id_complejo ORDER BY MIN(v.fecha_venta)) AS rn
  FROM Venta v
  JOIN Cliente cl ON cl.id_cliente = v.id_cliente
  GROUP BY v.id_complejo, cl.id_cliente
) sub
WHERE rn = 1;

-- Consulta 9: Cliente que ha visto más películas AA
SELECT v.id_cliente, c.nombre, c.apellido_paterno, COUNT(*) AS total_AA
FROM Venta v
JOIN BoletoVenta bv ON bv.id_venta = v.id_venta
JOIN Funcion f ON f.id_funcion = bv.id_funcion
JOIN Pelicula p ON p.id_pelicula = f.id_pelicula
JOIN Cliente c ON c.id_cliente = v.id_cliente
WHERE p.clasificacion = 'AA'
GROUP BY v.id_cliente
ORDER BY total_AA DESC
LIMIT 1;

-- Consulta 10: Total boletos vendidos por sucursal en 2024
SELECT co.nombre, SUM(bv.cantidad) AS total_boletos
FROM Venta v
JOIN BoletoVenta bv ON bv.id_venta = v.id_venta
JOIN Complejo co ON co.id_complejo = v.id_complejo
WHERE YEAR(v.fecha_venta) = 2024
GROUP BY co.id_complejo;

-- Vista 1: Funciones del día de hoy
CREATE OR REPLACE VIEW vw_funciones_hoy AS
SELECT p.titulo AS pelicula, p.genero, p.duracion_min, co.nombre AS complejo,
       f.fecha_funcion, f.hora_inicio
FROM Funcion f
JOIN Pelicula p ON p.id_pelicula = f.id_pelicula
JOIN Sala s ON s.id_sala = f.id_sala
JOIN Complejo co ON co.id_complejo = s.id_complejo
WHERE f.fecha_funcion = CURDATE()
ORDER BY f.hora_inicio DESC;

-- Vista 2: Función más vendida por complejo en abril
CREATE OR REPLACE VIEW vw_funcion_mas_vendida_abril AS
WITH ventas_abril AS (
  SELECT s.id_complejo, f.id_funcion, SUM(bv.cantidad) AS boletos_vendidos
  FROM BoletoVenta bv
  JOIN Funcion f ON f.id_funcion = bv.id_funcion
  JOIN Sala s ON s.id_sala = f.id_sala
  WHERE MONTH(f.fecha_funcion) = 4 AND YEAR(f.fecha_funcion) = YEAR(CURDATE())
  GROUP BY s.id_complejo, f.id_funcion
)
SELECT v.id_complejo, f.id_funcion, p.titulo, v.boletos_vendidos
FROM ventas_abril v
JOIN Funcion f ON f.id_funcion = v.id_funcion
JOIN Pelicula p ON p.id_pelicula = f.id_pelicula
JOIN (
  SELECT id_complejo, MAX(boletos_vendidos) AS max_boletos
  FROM ventas_abril
  GROUP BY id_complejo
) m ON m.id_complejo = v.id_complejo AND m.max_boletos = v.boletos_vendidos;
