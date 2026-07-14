-- TechZone CR - Avance 2
-- Módulo 04: Gestión de clientes
-- Contiene las operaciones CRUD de la tabla clientes

USE techzone_cr;

DELIMITER $$

-- Procedimiento 13: Registrar un cliente
DROP PROCEDURE IF EXISTS sp_clientes_insertar$$

CREATE PROCEDURE sp_clientes_insertar(
    IN p_nombre VARCHAR(100),
    IN p_correo VARCHAR(100),
    IN p_telefono VARCHAR(20),
    OUT p_cliente_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_correo VARCHAR(100);
    DECLARE v_duplicado INT DEFAULT 0;

    SET p_cliente_id = NULL;
    SET p_mensaje = '';
    SET v_correo = NULLIF(TRIM(p_correo), '');

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SET p_mensaje = 'El nombre del cliente es obligatorio';
        LEAVE procedimiento;
    END IF;

    IF v_correo IS NOT NULL THEN

        SELECT COUNT(*)
        INTO v_duplicado
        FROM clientes
        WHERE correo = v_correo;

        IF v_duplicado > 0 THEN
            SET p_mensaje = 'Ya existe un cliente con ese correo';
            LEAVE procedimiento;
        END IF;

    END IF;

    INSERT INTO clientes (
        nombre,
        correo,
        telefono
    )
    VALUES (
        TRIM(p_nombre),
        v_correo,
        NULLIF(TRIM(p_telefono), '')
    );

    SET p_cliente_id = LAST_INSERT_ID();
    SET p_mensaje = 'Cliente registrado correctamente';

END$$

-- Procedimiento 14: Listar los clientes
DROP PROCEDURE IF EXISTS sp_clientes_listar$$

CREATE PROCEDURE sp_clientes_listar()
BEGIN

    SELECT
        cliente_id,
        nombre,
        correo,
        telefono
    FROM clientes
    ORDER BY nombre;

END$$

-- Procedimiento 15: Actualizar un cliente
DROP PROCEDURE IF EXISTS sp_clientes_actualizar$$

CREATE PROCEDURE sp_clientes_actualizar(
    IN p_cliente_id INT,
    IN p_nombre VARCHAR(100),
    IN p_correo VARCHAR(100),
    IN p_telefono VARCHAR(20),
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_duplicado INT DEFAULT 0;
    DECLARE v_correo VARCHAR(100);

    SET p_mensaje = '';
    SET v_correo = NULLIF(TRIM(p_correo), '');

    IF p_cliente_id IS NULL OR p_cliente_id <= 0 THEN
        SET p_mensaje = 'El identificador del cliente no es válido';
        LEAVE procedimiento;
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SET p_mensaje = 'El nombre del cliente es obligatorio';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_existe
    FROM clientes
    WHERE cliente_id = p_cliente_id;

    IF v_existe = 0 THEN
        SET p_mensaje = 'El cliente indicado no existe';
        LEAVE procedimiento;
    END IF;

    IF v_correo IS NOT NULL THEN

        SELECT COUNT(*)
        INTO v_duplicado
        FROM clientes
        WHERE correo = v_correo
          AND cliente_id <> p_cliente_id;

        IF v_duplicado > 0 THEN
            SET p_mensaje = 'Ya existe otro cliente con ese correo';
            LEAVE procedimiento;
        END IF;

    END IF;

    UPDATE clientes
    SET
        nombre = TRIM(p_nombre),
        correo = v_correo,
        telefono = NULLIF(TRIM(p_telefono), '')
    WHERE cliente_id = p_cliente_id;

    SET p_mensaje = 'Cliente actualizado correctamente';

END$$

-- Procedimiento 16: Eliminar un cliente
DROP PROCEDURE IF EXISTS sp_clientes_eliminar$$

CREATE PROCEDURE sp_clientes_eliminar(
    IN p_cliente_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_ventas INT DEFAULT 0;

    SET p_mensaje = '';

    IF p_cliente_id IS NULL OR p_cliente_id <= 0 THEN
        SET p_mensaje = 'El identificador del cliente no es válido';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_existe
    FROM clientes
    WHERE cliente_id = p_cliente_id;

    IF v_existe = 0 THEN
        SET p_mensaje = 'El cliente indicado no existe';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_ventas
    FROM ventas
    WHERE cliente_id = p_cliente_id;

    IF v_ventas > 0 THEN
        SET p_mensaje =
            'No se puede eliminar el cliente porque tiene ventas registradas';
        LEAVE procedimiento;
    END IF;

    DELETE FROM clientes
    WHERE cliente_id = p_cliente_id;

    SET p_mensaje = 'Cliente eliminado correctamente';

END$$

DELIMITER ;