-- TechZone CR - Avance 2
-- Módulo de funciones para reportes

USE techzone_cr;

DELIMITER $$

-- Cuenta  productos de una categoría
DROP FUNCTION IF EXISTS fn_categoria_total_productos$$

CREATE FUNCTION fn_categoria_total_productos(
    p_categoria_id INT
)
RETURNS INT
READS SQL DATA
BEGIN

    DECLARE v_total INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_total
    FROM productos
    WHERE categoria_id = p_categoria_id;

    RETURN v_total;

END$$

-- Cuenta los productos de un proveedor
DROP FUNCTION IF EXISTS fn_proveedor_total_productos$$

CREATE FUNCTION fn_proveedor_total_productos(
    p_proveedor_id INT
)
RETURNS INT
READS SQL DATA
BEGIN

    DECLARE v_total INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_total
    FROM productos
    WHERE proveedor_id = p_proveedor_id;

    RETURN v_total;

END$$

-- Cuenta los productos con stock bajo
DROP FUNCTION IF EXISTS fn_productos_stock_bajo$$

CREATE FUNCTION fn_productos_stock_bajo()
RETURNS INT
READS SQL DATA
BEGIN

    DECLARE v_total INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_total
    FROM productos
    WHERE stock <= stock_minimo;

    RETURN v_total;

END$$

-- Calcula el total vendido entre dos fechas
DROP FUNCTION IF EXISTS fn_ventas_total_rango$$

CREATE FUNCTION fn_ventas_total_rango(
    p_fecha_inicio DATE,
    p_fecha_fin DATE
)
RETURNS DECIMAL(16,2)
READS SQL DATA
BEGIN

    DECLARE v_total DECIMAL(16,2) DEFAULT 0;

    IF p_fecha_inicio IS NULL
       OR p_fecha_fin IS NULL
       OR p_fecha_inicio > p_fecha_fin THEN

        RETURN 0;

    END IF;

    SELECT COALESCE(SUM(total), 0)
    INTO v_total
    FROM ventas
    WHERE DATE(fecha_venta)
          BETWEEN p_fecha_inicio AND p_fecha_fin;

    RETURN v_total;

END$$

-- Obtiene el nombre del producto más vendido
DROP FUNCTION IF EXISTS fn_producto_mas_vendido$$

CREATE FUNCTION fn_producto_mas_vendido()
RETURNS VARCHAR(100)
READS SQL DATA
BEGIN

    DECLARE v_producto VARCHAR(100) DEFAULT 'SIN VENTAS';

    SELECT COALESCE(
        (
            SELECT p.nombre
            FROM detalle_venta dv
            INNER JOIN productos p
                ON dv.producto_id = p.producto_id
            GROUP BY p.producto_id, p.nombre
            ORDER BY SUM(dv.cantidad) DESC
            LIMIT 1
        ),
        'SIN VENTAS'
    )
    INTO v_producto;

    RETURN v_producto;

END$$

DELIMITER ;
