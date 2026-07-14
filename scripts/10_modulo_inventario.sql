-- TechZone CR - Avance 2
-- Módulo 07: Gestión de movimientos de inventario
-- Contiene las operaciones CRUD de movimientos_inventario

USE techzone_cr;

DELIMITER $$

-- Procedimiento 25: Registrar un movimiento de inventario
DROP PROCEDURE IF EXISTS sp_inventario_insertar$$

CREATE PROCEDURE sp_inventario_insertar(
    IN p_producto_id INT,
    IN p_tipo VARCHAR(10),
    IN p_cantidad INT,
    IN p_observacion VARCHAR(200),
    OUT p_movimiento_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_producto_existe INT DEFAULT 0;
    DECLARE v_stock_actual INT DEFAULT 0;
    DECLARE v_tipo VARCHAR(10);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_movimiento_id = NULL;
        SET p_mensaje = 'Ocurrió un error al registrar el movimiento';
    END;

    SET p_movimiento_id = NULL;
    SET p_mensaje = '';
    SET v_tipo = UPPER(TRIM(p_tipo));

    IF p_producto_id IS NULL OR p_producto_id <= 0 THEN
        SET p_mensaje = 'El identificador del producto no es válido';
        LEAVE procedimiento;
    END IF;

    IF v_tipo NOT IN ('ENTRADA', 'SALIDA') THEN
        SET p_mensaje = 'El tipo debe ser ENTRADA o SALIDA';
        LEAVE procedimiento;
    END IF;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SET p_mensaje = 'La cantidad debe ser mayor que cero';
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

    START TRANSACTION;

    SELECT stock
    INTO v_stock_actual
    FROM productos
    WHERE producto_id = p_producto_id
    FOR UPDATE;

    IF v_tipo = 'SALIDA' AND p_cantidad > v_stock_actual THEN
        ROLLBACK;
        SET p_mensaje = 'No existe suficiente stock para registrar la salida';
        LEAVE procedimiento;
    END IF;

    IF v_tipo = 'ENTRADA' THEN

        UPDATE productos
        SET stock = stock + p_cantidad
        WHERE producto_id = p_producto_id;

    ELSE

        UPDATE productos
        SET stock = stock - p_cantidad
        WHERE producto_id = p_producto_id;

    END IF;

    INSERT INTO movimientos_inventario (
        producto_id,
        tipo,
        cantidad,
        observacion
    )
    VALUES (
        p_producto_id,
        v_tipo,
        p_cantidad,
        NULLIF(TRIM(p_observacion), '')
    );

    SET p_movimiento_id = LAST_INSERT_ID();

    COMMIT;

    SET p_mensaje = 'Movimiento registrado correctamente';

END$$

-- Procedimiento 26: Listar movimientos de inventario
DROP PROCEDURE IF EXISTS sp_inventario_listar$$

CREATE PROCEDURE sp_inventario_listar(
    IN p_producto_id INT
)
BEGIN

    SELECT
        m.movimiento_id,
        m.producto_id,
        p.nombre AS producto,
        m.tipo,
        m.cantidad,
        m.fecha,
        m.observacion
    FROM movimientos_inventario m
    INNER JOIN productos p
        ON m.producto_id = p.producto_id
    WHERE p_producto_id IS NULL
       OR p_producto_id = 0
       OR m.producto_id = p_producto_id
    ORDER BY
        m.fecha DESC,
        m.movimiento_id DESC;

END$$

-- Procedimiento 27: Actualizar un movimiento de inventario
DROP PROCEDURE IF EXISTS sp_inventario_actualizar$$

CREATE PROCEDURE sp_inventario_actualizar(
    IN p_movimiento_id INT,
    IN p_producto_id INT,
    IN p_tipo VARCHAR(10),
    IN p_cantidad INT,
    IN p_observacion VARCHAR(200),
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_movimiento_existe INT DEFAULT 0;
    DECLARE v_producto_existe INT DEFAULT 0;
    DECLARE v_producto_anterior INT;
    DECLARE v_tipo_anterior VARCHAR(10);
    DECLARE v_cantidad_anterior INT;
    DECLARE v_stock_anterior INT DEFAULT 0;
    DECLARE v_stock_nuevo INT DEFAULT 0;
    DECLARE v_tipo VARCHAR(10);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Ocurrió un error al actualizar el movimiento';
    END;

    SET p_mensaje = '';
    SET v_tipo = UPPER(TRIM(p_tipo));

    IF p_movimiento_id IS NULL OR p_movimiento_id <= 0 THEN
        SET p_mensaje = 'El identificador del movimiento no es válido';
        LEAVE procedimiento;
    END IF;

    IF p_producto_id IS NULL OR p_producto_id <= 0 THEN
        SET p_mensaje = 'El identificador del producto no es válido';
        LEAVE procedimiento;
    END IF;

    IF v_tipo NOT IN ('ENTRADA', 'SALIDA') THEN
        SET p_mensaje = 'El tipo debe ser ENTRADA o SALIDA';
        LEAVE procedimiento;
    END IF;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SET p_mensaje = 'La cantidad debe ser mayor que cero';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_movimiento_existe
    FROM movimientos_inventario
    WHERE movimiento_id = p_movimiento_id;

    IF v_movimiento_existe = 0 THEN
        SET p_mensaje = 'El movimiento indicado no existe';
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
        producto_id,
        tipo,
        cantidad
    INTO
        v_producto_anterior,
        v_tipo_anterior,
        v_cantidad_anterior
    FROM movimientos_inventario
    WHERE movimiento_id = p_movimiento_id;

    START TRANSACTION;

    SELECT stock
    INTO v_stock_anterior
    FROM productos
    WHERE producto_id = v_producto_anterior
    FOR UPDATE;

    IF v_tipo_anterior = 'ENTRADA' THEN

        IF v_stock_anterior < v_cantidad_anterior THEN
            ROLLBACK;
            SET p_mensaje =
                'No se puede modificar la entrada porque parte del stock ya fue utilizado';
            LEAVE procedimiento;
        END IF;

        UPDATE productos
        SET stock = stock - v_cantidad_anterior
        WHERE producto_id = v_producto_anterior;

    ELSE

        UPDATE productos
        SET stock = stock + v_cantidad_anterior
        WHERE producto_id = v_producto_anterior;

    END IF;

    SELECT stock
    INTO v_stock_nuevo
    FROM productos
    WHERE producto_id = p_producto_id
    FOR UPDATE;

    IF v_tipo = 'SALIDA' AND p_cantidad > v_stock_nuevo THEN
        ROLLBACK;
        SET p_mensaje =
            'No existe suficiente stock para aplicar el movimiento actualizado';
        LEAVE procedimiento;
    END IF;

    IF v_tipo = 'ENTRADA' THEN

        UPDATE productos
        SET stock = stock + p_cantidad
        WHERE producto_id = p_producto_id;

    ELSE

        UPDATE productos
        SET stock = stock - p_cantidad
        WHERE producto_id = p_producto_id;

    END IF;

    UPDATE movimientos_inventario
    SET
        producto_id = p_producto_id,
        tipo = v_tipo,
        cantidad = p_cantidad,
        observacion = NULLIF(TRIM(p_observacion), '')
    WHERE movimiento_id = p_movimiento_id;

    COMMIT;

    SET p_mensaje = 'Movimiento actualizado correctamente';

END$$

-- Procedimiento 28: Eliminar un movimiento de inventario
DROP PROCEDURE IF EXISTS sp_inventario_eliminar$$

CREATE PROCEDURE sp_inventario_eliminar(
    IN p_movimiento_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_movimiento_existe INT DEFAULT 0;
    DECLARE v_producto_id INT;
    DECLARE v_tipo VARCHAR(10);
    DECLARE v_cantidad INT;
    DECLARE v_stock_actual INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Ocurrió un error al eliminar el movimiento';
    END;

    SET p_mensaje = '';

    IF p_movimiento_id IS NULL OR p_movimiento_id <= 0 THEN
        SET p_mensaje = 'El identificador del movimiento no es válido';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_movimiento_existe
    FROM movimientos_inventario
    WHERE movimiento_id = p_movimiento_id;

    IF v_movimiento_existe = 0 THEN
        SET p_mensaje = 'El movimiento indicado no existe';
        LEAVE procedimiento;
    END IF;

    SELECT
        producto_id,
        tipo,
        cantidad
    INTO
        v_producto_id,
        v_tipo,
        v_cantidad
    FROM movimientos_inventario
    WHERE movimiento_id = p_movimiento_id;

    START TRANSACTION;

    SELECT stock
    INTO v_stock_actual
    FROM productos
    WHERE producto_id = v_producto_id
    FOR UPDATE;

    IF v_tipo = 'ENTRADA' THEN

        IF v_stock_actual < v_cantidad THEN
            ROLLBACK;
            SET p_mensaje =
                'No se puede eliminar la entrada porque parte del stock ya fue utilizado';
            LEAVE procedimiento;
        END IF;

        UPDATE productos
        SET stock = stock - v_cantidad
        WHERE producto_id = v_producto_id;

    ELSE

        UPDATE productos
        SET stock = stock + v_cantidad
        WHERE producto_id = v_producto_id;

    END IF;

    DELETE FROM movimientos_inventario
    WHERE movimiento_id = p_movimiento_id;

    COMMIT;

    SET p_mensaje = 'Movimiento eliminado correctamente';

END$$

DELIMITER ;