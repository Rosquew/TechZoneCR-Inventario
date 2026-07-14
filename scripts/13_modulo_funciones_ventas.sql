-- TechZone CR - Avance 2
-- Módulo 09: Funciones de ventas y clientes

USE techzone_cr;

DELIMITER $$

-- Función 6: Obtener el total de una venta
DROP FUNCTION IF EXISTS fn_venta_total$$

CREATE FUNCTION fn_venta_total(
    p_venta_id INT
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN

    DECLARE v_total DECIMAL(12,2) DEFAULT 0;

    SELECT COALESCE(MAX(total), 0)
    INTO v_total
    FROM ventas
    WHERE venta_id = p_venta_id;

    RETURN v_total;

END$$

-- Función 7: Obtener la cantidad de ventas de un cliente
DROP FUNCTION IF EXISTS fn_cliente_cantidad_ventas$$

CREATE FUNCTION fn_cliente_cantidad_ventas(
    p_cliente_id INT
)
RETURNS INT
READS SQL DATA
BEGIN

    DECLARE v_cantidad INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_cantidad
    FROM ventas
    WHERE cliente_id = p_cliente_id;

    RETURN v_cantidad;

END$$

-- Función 8: Obtener el total comprado por un cliente
DROP FUNCTION IF EXISTS fn_cliente_total_comprado$$

CREATE FUNCTION fn_cliente_total_comprado(
    p_cliente_id INT
)
RETURNS DECIMAL(14,2)
READS SQL DATA
BEGIN

    DECLARE v_total DECIMAL(14,2) DEFAULT 0;

    SELECT COALESCE(SUM(total), 0)
    INTO v_total
    FROM ventas
    WHERE cliente_id = p_cliente_id;

    RETURN v_total;

END$$

-- Función 9: Obtener el total vendido en un mes y año
DROP FUNCTION IF EXISTS fn_ventas_total_mes$$

CREATE FUNCTION fn_ventas_total_mes(
    p_mes INT,
    p_anio INT
)
RETURNS DECIMAL(16,2)
READS SQL DATA
BEGIN

    DECLARE v_total DECIMAL(16,2) DEFAULT 0;

    IF p_mes IS NULL
       OR p_mes < 1
       OR p_mes > 12
       OR p_anio IS NULL
       OR p_anio <= 0 THEN

        RETURN 0;

    END IF;

    SELECT COALESCE(SUM(total), 0)
    INTO v_total
    FROM ventas
    WHERE MONTH(fecha_venta) = p_mes
      AND YEAR(fecha_venta) = p_anio;

    RETURN v_total;

END$$

-- Función 10: Obtener las unidades vendidas de un producto
DROP FUNCTION IF EXISTS fn_producto_unidades_vendidas$$

CREATE FUNCTION fn_producto_unidades_vendidas(
    p_producto_id INT
)
RETURNS INT
READS SQL DATA
BEGIN

    DECLARE v_unidades INT DEFAULT 0;

    SELECT COALESCE(SUM(cantidad), 0)
    INTO v_unidades
    FROM detalle_venta
    WHERE producto_id = p_producto_id;

    RETURN v_unidades;

END$$

DELIMITER ;