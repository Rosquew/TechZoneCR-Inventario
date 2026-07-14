-- TechZone CR - Avance 2
-- Módulo 02: Gestión de proveedores
-- Contiene las operaciones CRUD de la tabla proveedores
-- Encargada: Mariana
USE techzone_cr;

DELIMITER $$

-- Procedimiento 5: Registrar un proveedor
DROP PROCEDURE IF EXISTS sp_proveedores_insertar$$

CREATE PROCEDURE sp_proveedores_insertar(
    IN p_nombre VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_correo VARCHAR(100),
    IN p_direccion VARCHAR(150),
    OUT p_proveedor_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_correo VARCHAR(100);
    DECLARE v_duplicado INT DEFAULT 0;

    SET p_proveedor_id = NULL;
    SET p_mensaje = '';
    SET v_correo = NULLIF(TRIM(p_correo), '');

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SET p_mensaje = 'El nombre del proveedor es obligatorio';
        LEAVE procedimiento;
    END IF;

    IF v_correo IS NOT NULL THEN

        SELECT COUNT(*)
        INTO v_duplicado
        FROM proveedores
        WHERE correo = v_correo;

        IF v_duplicado > 0 THEN
            SET p_mensaje = 'Ya existe un proveedor con ese correo';
            LEAVE procedimiento;
        END IF;

    END IF;

    INSERT INTO proveedores (
        nombre,
        telefono,
        correo,
        direccion
    )
    VALUES (
        TRIM(p_nombre),
        NULLIF(TRIM(p_telefono), ''),
        v_correo,
        NULLIF(TRIM(p_direccion), '')
    );

    SET p_proveedor_id = LAST_INSERT_ID();
    SET p_mensaje = 'Proveedor registrado correctamente';

END$$

-- Procedimiento 6: Listar los proveedores
DROP PROCEDURE IF EXISTS sp_proveedores_listar$$

CREATE PROCEDURE sp_proveedores_listar()
BEGIN

    SELECT
        proveedor_id,
        nombre,
        telefono,
        correo,
        direccion
    FROM proveedores
    ORDER BY nombre;

END$$

-- Procedimiento 7: Actualizar un proveedor
DROP PROCEDURE IF EXISTS sp_proveedores_actualizar$$

CREATE PROCEDURE sp_proveedores_actualizar(
    IN p_proveedor_id INT,
    IN p_nombre VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_correo VARCHAR(100),
    IN p_direccion VARCHAR(150),
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_duplicado INT DEFAULT 0;
    DECLARE v_correo VARCHAR(100);

    SET p_mensaje = '';
    SET v_correo = NULLIF(TRIM(p_correo), '');

    IF p_proveedor_id IS NULL OR p_proveedor_id <= 0 THEN
        SET p_mensaje = 'El identificador del proveedor no es válido';
        LEAVE procedimiento;
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SET p_mensaje = 'El nombre del proveedor es obligatorio';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_existe
    FROM proveedores
    WHERE proveedor_id = p_proveedor_id;

    IF v_existe = 0 THEN
        SET p_mensaje = 'El proveedor indicado no existe';
        LEAVE procedimiento;
    END IF;

    IF v_correo IS NOT NULL THEN

        SELECT COUNT(*)
        INTO v_duplicado
        FROM proveedores
        WHERE correo = v_correo
          AND proveedor_id <> p_proveedor_id;

        IF v_duplicado > 0 THEN
            SET p_mensaje = 'Ya existe otro proveedor con ese correo';
            LEAVE procedimiento;
        END IF;

    END IF;

    UPDATE proveedores
    SET
        nombre = TRIM(p_nombre),
        telefono = NULLIF(TRIM(p_telefono), ''),
        correo = v_correo,
        direccion = NULLIF(TRIM(p_direccion), '')
    WHERE proveedor_id = p_proveedor_id;

    SET p_mensaje = 'Proveedor actualizado correctamente';

END$$

-- Procedimiento 8: Eliminar un proveedor
DROP PROCEDURE IF EXISTS sp_proveedores_eliminar$$

CREATE PROCEDURE sp_proveedores_eliminar(
    IN p_proveedor_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_productos INT DEFAULT 0;

    SET p_mensaje = '';

    IF p_proveedor_id IS NULL OR p_proveedor_id <= 0 THEN
        SET p_mensaje = 'El identificador del proveedor no es válido';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_existe
    FROM proveedores
    WHERE proveedor_id = p_proveedor_id;

    IF v_existe = 0 THEN
        SET p_mensaje = 'El proveedor indicado no existe';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_productos
    FROM productos
    WHERE proveedor_id = p_proveedor_id;

    IF v_productos > 0 THEN
        SET p_mensaje =
            'No se puede eliminar el proveedor porque tiene productos asociados';
        LEAVE procedimiento;
    END IF;

    DELETE FROM proveedores
    WHERE proveedor_id = p_proveedor_id;

    SET p_mensaje = 'Proveedor eliminado correctamente';

END$$

DELIMITER ;

