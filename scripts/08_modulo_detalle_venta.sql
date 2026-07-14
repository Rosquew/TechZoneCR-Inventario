-- TechZone CR - Avance 2
-- Módulo 06: Gestión del detalle de ventas
-- Contiene las operaciones CRUD de la tabla detalle_venta

USE techzone_cr;

DELIMITER $$

-- Procedimiento 21: Agregar un producto a una venta
DROP PROCEDURE IF EXISTS sp_detalle_venta_insertar$$

CREATE PROCEDURE sp_detalle_venta_insertar(
    IN p_venta_id INT,
    IN p_producto_id INT,
    IN p_cantidad INT,
    OUT p_detalle_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_venta_existe INT DEFAULT 0;
    DECLARE v_producto_existe INT DEFAULT 0;
    DECLARE v_producto_repetido INT DEFAULT 0;
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_precio DECIMAL(10,2) DEFAULT 0;

    SET p_detalle_id = NULL;
    SET p_mensaje = '';

    IF p_venta_id IS NULL OR p_venta_id <= 0 THEN
        SET p_mensaje = 'El identificador de la venta no es válido';
        LEAVE procedimiento;
    END IF;

    IF p_producto_id IS NULL OR p_producto_id <= 0 THEN
        SET p_mensaje = 'El identificador del producto no es válido';
        LEAVE procedimiento;
    END IF;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SET p_mensaje = 'La cantidad debe ser mayor que cero';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_venta_existe
    FROM ventas
    WHERE venta_id = p_venta_id;

    IF v_venta_existe = 0 THEN
        SET p_mensaje = 'La venta indicada no existe';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_producto_existe
    FROM productos
    WHERE producto_id = p_producto_id;

    IF v_producto_existe = 0 THEN
        SET p_mensaje = 'El producto indicado no existe';
        LEAVE procedimiento;
    END IF;

    SELECT
        stock,
        precio
    INTO
        v_stock,
        v_precio
    FROM productos
    WHERE producto_id = p_producto_id;

    IF p_cantidad > v_stock THEN
        SET p_mensaje = 'No existe suficiente stock para realizar la venta';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_producto_repetido
    FROM detalle_venta
    WHERE venta_id = p_venta_id
      AND producto_id = p_producto_id;

    IF v_producto_repetido > 0 THEN
        SET p_mensaje = 'El producto ya fue agregado a esta venta';
        LEAVE procedimiento;
    END IF;

    INSERT INTO detalle_venta (
        venta_id,
        producto_id,
        cantidad,
        precio_unitario
    )
    VALUES (
        p_venta_id,
        p_producto_id,
        p_cantidad,
        v_precio
    );

    SET p_detalle_id = LAST_INSERT_ID();
    SET p_mensaje = 'Producto agregado a la venta correctamente';

END$$

-- Procedimiento 22: Listar los detalles de una venta
DROP PROCEDURE IF EXISTS sp_detalle_venta_listar$$

CREATE PROCEDURE sp_detalle_venta_listar(
    IN p_venta_id INT
)
BEGIN

    SELECT
        dv.detalle_id,
        dv.venta_id,
        dv.producto_id,
        p.nombre AS producto,
        dv.cantidad,
        dv.precio_unitario,
        dv.subtotal
    FROM detalle_venta dv
    INNER JOIN productos p
        ON dv.producto_id = p.producto_id
    WHERE p_venta_id IS NULL
       OR dv.venta_id = p_venta_id
    ORDER BY
        dv.venta_id,
        dv.detalle_id;

END$$

-- Procedimiento 23: Actualizar un detalle de venta
DROP PROCEDURE IF EXISTS sp_detalle_venta_actualizar$$

CREATE PROCEDURE sp_detalle_venta_actualizar(
    IN p_detalle_id INT,
    IN p_producto_id INT,
    IN p_cantidad INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_detalle_existe INT DEFAULT 0;
    DECLARE v_producto_existe INT DEFAULT 0;
    DECLARE v_producto_repetido INT DEFAULT 0;
    DECLARE v_venta_id INT;
    DECLARE v_producto_anterior INT;
    DECLARE v_cantidad_anterior INT;
    DECLARE v_stock_actual INT DEFAULT 0;
    DECLARE v_stock_disponible INT DEFAULT 0;
    DECLARE v_precio DECIMAL(10,2) DEFAULT 0;

    SET p_mensaje = '';

    IF p_detalle_id IS NULL OR p_detalle_id <= 0 THEN
        SET p_mensaje = 'El identificador del detalle no es válido';
        LEAVE procedimiento;
    END IF;

    IF p_producto_id IS NULL OR p_producto_id <= 0 THEN
        SET p_mensaje = 'El identificador del producto no es válido';
        LEAVE procedimiento;
    END IF;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SET p_mensaje = 'La cantidad debe ser mayor que cero';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_detalle_existe
    FROM detalle_venta
    WHERE detalle_id = p_detalle_id;

    IF v_detalle_existe = 0 THEN
        SET p_mensaje = 'El detalle de venta indicado no existe';
        LEAVE procedimiento;
    END IF;

    SELECT
        venta_id,
        producto_id,
        cantidad
    INTO
        v_venta_id,
        v_producto_anterior,
        v_cantidad_anterior
    FROM detalle_venta
    WHERE detalle_id = p_detalle_id;

    SELECT COUNT(*)
    INTO v_producto_existe
    FROM productos
    WHERE producto_id = p_producto_id;

    IF v_producto_existe = 0 THEN
        SET p_mensaje = 'El producto indicado no existe';
        LEAVE procedimiento;
    END IF;

    SELECT
        stock,
        precio
    INTO
        v_stock_actual,
        v_precio
    FROM productos
    WHERE producto_id = p_producto_id;

    IF p_producto_id = v_producto_anterior THEN
        SET v_stock_disponible = v_stock_actual + v_cantidad_anterior;
    ELSE
        SET v_stock_disponible = v_stock_actual;
    END IF;

    IF p_cantidad > v_stock_disponible THEN
        SET p_mensaje = 'No existe suficiente stock para actualizar el detalle';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_producto_repetido
    FROM detalle_venta
    WHERE venta_id = v_venta_id
      AND producto_id = p_producto_id
      AND detalle_id <> p_detalle_id;

    IF v_producto_repetido > 0 THEN
        SET p_mensaje = 'El producto ya se encuentra registrado en esta venta';
        LEAVE procedimiento;
    END IF;

    UPDATE detalle_venta
    SET
        producto_id = p_producto_id,
        cantidad = p_cantidad,
        precio_unitario = v_precio
    WHERE detalle_id = p_detalle_id;

    SET p_mensaje = 'Detalle de venta actualizado correctamente';

END$$

-- Procedimiento 24: Eliminar un detalle de venta
DROP PROCEDURE IF EXISTS sp_detalle_venta_eliminar$$

CREATE PROCEDURE sp_detalle_venta_eliminar(
    IN p_detalle_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_detalle_existe INT DEFAULT 0;

    SET p_mensaje = '';

    IF p_detalle_id IS NULL OR p_detalle_id <= 0 THEN
        SET p_mensaje = 'El identificador del detalle no es válido';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_detalle_existe
    FROM detalle_venta
    WHERE detalle_id = p_detalle_id;

    IF v_detalle_existe = 0 THEN
        SET p_mensaje = 'El detalle de venta indicado no existe';
        LEAVE procedimiento;
    END IF;

    DELETE FROM detalle_venta
    WHERE detalle_id = p_detalle_id;

    SET p_mensaje = 'Detalle de venta eliminado correctamente';

END$$

DELIMITER ;