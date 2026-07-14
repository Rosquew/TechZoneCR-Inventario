-- TechZone CR - Avance 2
-- Módulo 01: Gestión de categorías
-- Contiene las operaciones CRUD de la tabla categorias

USE techzone_cr;

DELIMITER $$

-- Procedimiento 1: Registrar una categoría
DROP PROCEDURE IF EXISTS sp_categorias_insertar$$

CREATE PROCEDURE sp_categorias_insertar(
    IN p_nombre VARCHAR(80),
    IN p_descripcion VARCHAR(200),
    OUT p_categoria_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_cantidad INT DEFAULT 0;

    SET p_categoria_id = NULL;
    SET p_mensaje = '';

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SET p_mensaje = 'El nombre de la categoría es obligatorio';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_cantidad
    FROM categorias
    WHERE nombre = TRIM(p_nombre);

    IF v_cantidad > 0 THEN
        SET p_mensaje = 'Ya existe una categoría con ese nombre';
        LEAVE procedimiento;
    END IF;

    INSERT INTO categorias (
        nombre,
        descripcion
    )
    VALUES (
        TRIM(p_nombre),
        NULLIF(TRIM(p_descripcion), '')
    );

    SET p_categoria_id = LAST_INSERT_ID();
    SET p_mensaje = 'Categoría registrada correctamente';

END$$

-- Procedimiento 2: Listar las categorías
DROP PROCEDURE IF EXISTS sp_categorias_listar$$

CREATE PROCEDURE sp_categorias_listar()
BEGIN

    SELECT
        categoria_id,
        nombre,
        descripcion
    FROM categorias
    ORDER BY nombre;

END$$

-- Procedimiento 3: Actualizar una categoría
DROP PROCEDURE IF EXISTS sp_categorias_actualizar$$

CREATE PROCEDURE sp_categorias_actualizar(
    IN p_categoria_id INT,
    IN p_nombre VARCHAR(80),
    IN p_descripcion VARCHAR(200),
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_duplicado INT DEFAULT 0;

    SET p_mensaje = '';

    IF p_categoria_id IS NULL OR p_categoria_id <= 0 THEN
        SET p_mensaje = 'El identificador de la categoría no es válido';
        LEAVE procedimiento;
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SET p_mensaje = 'El nombre de la categoría es obligatorio';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_existe
    FROM categorias
    WHERE categoria_id = p_categoria_id;

    IF v_existe = 0 THEN
        SET p_mensaje = 'La categoría indicada no existe';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_duplicado
    FROM categorias
    WHERE nombre = TRIM(p_nombre)
      AND categoria_id <> p_categoria_id;

    IF v_duplicado > 0 THEN
        SET p_mensaje = 'Ya existe otra categoría con ese nombre';
        LEAVE procedimiento;
    END IF;

    UPDATE categorias
    SET
        nombre = TRIM(p_nombre),
        descripcion = NULLIF(TRIM(p_descripcion), '')
    WHERE categoria_id = p_categoria_id;

    SET p_mensaje = 'Categoría actualizada correctamente';

END$$

-- Procedimiento 4: Eliminar una categoría
DROP PROCEDURE IF EXISTS sp_categorias_eliminar$$

CREATE PROCEDURE sp_categorias_eliminar(
    IN p_categoria_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_productos INT DEFAULT 0;

    SET p_mensaje = '';

    IF p_categoria_id IS NULL OR p_categoria_id <= 0 THEN
        SET p_mensaje = 'El identificador de la categoría no es válido';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_existe
    FROM categorias
    WHERE categoria_id = p_categoria_id;

    IF v_existe = 0 THEN
        SET p_mensaje = 'La categoría indicada no existe';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_productos
    FROM productos
    WHERE categoria_id = p_categoria_id;

    IF v_productos > 0 THEN
        SET p_mensaje =
            'No se puede eliminar la categoría porque tiene productos asociados';
        LEAVE procedimiento;
    END IF;

    DELETE FROM categorias
    WHERE categoria_id = p_categoria_id;

    SET p_mensaje = 'Categoría eliminada correctamente';

END$$

DELIMITER ;

