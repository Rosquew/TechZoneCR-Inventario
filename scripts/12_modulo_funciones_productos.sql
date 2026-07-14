-- TechZone CR - Avance 2
-- Módulo 08: Funciones de productos e inventario

USE techzone_cr;

DELIMITER $$

-- Función 1: Obtener la cantidad total de productos
DROP FUNCTION IF EXISTS fn_productos_total$$

CREATE FUNCTION fn_productos_total()
RETURNS INT
READS SQL DATA
BEGIN

    DECLARE v_total INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_total
    FROM productos;

    RETURN v_total;

END$$

-- Función 2: Obtener el stock de un producto
DROP FUNCTION IF EXISTS fn_producto_stock$$

CREATE FUNCTION fn_producto_stock(
    p_producto_id INT
)
RETURNS INT
READS SQL DATA
BEGIN

    DECLARE v_stock INT DEFAULT NULL;

    SELECT MAX(stock)
    INTO v_stock
    FROM productos
    WHERE producto_id = p_producto_id;

    RETURN v_stock;

END$$

-- Función 3: Obtener el estado del stock de un producto
DROP FUNCTION IF EXISTS fn_producto_estado_stock$$

CREATE FUNCTION fn_producto_estado_stock(
    p_producto_id INT
)
RETURNS VARCHAR(30)
READS SQL DATA
BEGIN

    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_stock_minimo INT DEFAULT 0;
    DECLARE v_estado VARCHAR(30);

    SELECT
        COUNT(*),
        COALESCE(MAX(stock), 0),
        COALESCE(MAX(stock_minimo), 0)
    INTO
        v_existe,
        v_stock,
        v_stock_minimo
    FROM productos
    WHERE producto_id = p_producto_id;

    IF v_existe = 0 THEN
        SET v_estado = 'NO EXISTE';
    ELSEIF v_stock = 0 THEN
        SET v_estado = 'AGOTADO';
    ELSEIF v_stock <= v_stock_minimo THEN
        SET v_estado = 'STOCK BAJO';
    ELSE
        SET v_estado = 'DISPONIBLE';
    END IF;

    RETURN v_estado;

END$$

-- Función 4: Calcular el valor del inventario de un producto
DROP FUNCTION IF EXISTS fn_producto_valor_inventario$$

CREATE FUNCTION fn_producto_valor_inventario(
    p_producto_id INT
)
RETURNS DECIMAL(14,2)
READS SQL DATA
BEGIN

    DECLARE v_valor DECIMAL(14,2) DEFAULT NULL;

    SELECT MAX(precio * stock)
    INTO v_valor
    FROM productos
    WHERE producto_id = p_producto_id;

    RETURN v_valor;

END$$

-- Función 5: Calcular el valor total del inventario
DROP FUNCTION IF EXISTS fn_inventario_valor_total$$

CREATE FUNCTION fn_inventario_valor_total()
RETURNS DECIMAL(16,2)
READS SQL DATA
BEGIN

    DECLARE v_valor_total DECIMAL(16,2) DEFAULT 0;

    SELECT COALESCE(SUM(precio * stock), 0)
    INTO v_valor_total
    FROM productos;

    RETURN v_valor_total;

END$$

DELIMITER ;