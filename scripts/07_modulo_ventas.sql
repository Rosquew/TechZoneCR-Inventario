-- TechZone CR - Avance 2
-- Módulo 05: Gestión de ventas
-- Contiene las operaciones CRUD de la tabla ventas

USE techzone_cr;

DELIMITER $$

-- Procedimiento 17: Registrar una venta
DROP PROCEDURE IF EXISTS sp_ventas_insertar$$

CREATE PROCEDURE sp_ventas_insertar(
    IN p_cliente_id INT,
    IN p_fecha_venta DATETIME,
    OUT p_venta_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_cliente_existe INT DEFAULT 0;

    SET p_venta_id = NULL;
    SET p_mensaje = '';

    IF p_cliente_id IS NULL OR p_cliente_id <= 0 THEN
        SET p_mensaje = 'El identificador del cliente no es válido';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_cliente_existe
    FROM clientes
    WHERE cliente_id = p_cliente_id;

    IF v_cliente_existe = 0 THEN
        SET p_mensaje = 'El cliente indicado no existe';
        LEAVE procedimiento;
    END IF;

    INSERT INTO ventas (
        cliente_id,
        fecha_venta,
        total
    )
    VALUES (
        p_cliente_id,
        COALESCE(p_fecha_venta, CURRENT_TIMESTAMP),
        0
    );

    SET p_venta_id = LAST_INSERT_ID();
    SET p_mensaje = 'Venta registrada correctamente';

END$$

-- Procedimiento 18: Listar las ventas
DROP PROCEDURE IF EXISTS sp_ventas_listar$$

CREATE PROCEDURE sp_ventas_listar()
BEGIN

    SELECT
        v.venta_id,
        v.fecha_venta,
        v.cliente_id,
        c.nombre AS cliente,
        COUNT(dv.detalle_id) AS cantidad_productos,
        v.total
    FROM ventas v
    INNER JOIN clientes c
        ON v.cliente_id = c.cliente_id
    LEFT JOIN detalle_venta dv
        ON v.venta_id = dv.venta_id
    GROUP BY
        v.venta_id,
        v.fecha_venta,
        v.cliente_id,
        c.nombre,
        v.total
    ORDER BY v.fecha_venta DESC;

END$$

-- Procedimiento 19: Actualizar una venta
DROP PROCEDURE IF EXISTS sp_ventas_actualizar$$

CREATE PROCEDURE sp_ventas_actualizar(
    IN p_venta_id INT,
    IN p_cliente_id INT,
    IN p_fecha_venta DATETIME,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_venta_existe INT DEFAULT 0;
    DECLARE v_cliente_existe INT DEFAULT 0;

    SET p_mensaje = '';

    IF p_venta_id IS NULL OR p_venta_id <= 0 THEN
        SET p_mensaje = 'El identificador de la venta no es válido';
        LEAVE procedimiento;
    END IF;

    IF p_cliente_id IS NULL OR p_cliente_id <= 0 THEN
        SET p_mensaje = 'El identificador del cliente no es válido';
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
    INTO v_cliente_existe
    FROM clientes
    WHERE cliente_id = p_cliente_id;

    IF v_cliente_existe = 0 THEN
        SET p_mensaje = 'El cliente indicado no existe';
        LEAVE procedimiento;
    END IF;

    UPDATE ventas
    SET
        cliente_id = p_cliente_id,
        fecha_venta = COALESCE(p_fecha_venta, fecha_venta)
    WHERE venta_id = p_venta_id;

    SET p_mensaje = 'Venta actualizada correctamente';

END$$

-- Procedimiento 20: Eliminar una venta vacía
DROP PROCEDURE IF EXISTS sp_ventas_eliminar$$

CREATE PROCEDURE sp_ventas_eliminar(
    IN p_venta_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_venta_existe INT DEFAULT 0;
    DECLARE v_detalles INT DEFAULT 0;

    SET p_mensaje = '';

    IF p_venta_id IS NULL OR p_venta_id <= 0 THEN
        SET p_mensaje = 'El identificador de la venta no es válido';
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
    INTO v_detalles
    FROM detalle_venta
    WHERE venta_id = p_venta_id;

    IF v_detalles > 0 THEN
        SET p_mensaje =
            'No se puede eliminar la venta porque contiene productos asociados';
        LEAVE procedimiento;
    END IF;

    DELETE FROM ventas
    WHERE venta_id = p_venta_id;

    SET p_mensaje = 'Venta eliminada correctamente';

END$$

DELIMITER ;