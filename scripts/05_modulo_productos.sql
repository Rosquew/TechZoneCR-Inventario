-- TechZone CR - Avance 2
-- Módulo 03: Gestión de productos
-- Contiene las operaciones CRUD de la tabla productos

USE techzone_cr;

DELIMITER $$

-- Procedimiento 9: Registrar un producto
DROP PROCEDURE IF EXISTS sp_productos_insertar$$

CREATE PROCEDURE sp_productos_insertar(
    IN p_nombre VARCHAR(100),
    IN p_descripcion VARCHAR(200),
    IN p_precio DECIMAL(10,2),
    IN p_stock_inicial INT,
    IN p_stock_minimo INT,
    IN p_categoria_id INT,
    IN p_proveedor_id INT,
    OUT p_producto_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_categoria_existe INT DEFAULT 0;
    DECLARE v_proveedor_existe INT DEFAULT 0;
    DECLARE v_producto_duplicado INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_producto_id = NULL;
        SET p_mensaje = 'Ocurrió un error al registrar el producto';
    END;

    SET p_producto_id = NULL;
    SET p_mensaje = '';

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SET p_mensaje = 'El nombre del producto es obligatorio';
        LEAVE procedimiento;
    END IF;

    IF p_precio IS NULL OR p_precio <= 0 THEN
        SET p_mensaje = 'El precio debe ser mayor que cero';
        LEAVE procedimiento;
    END IF;

    IF p_stock_inicial IS NULL OR p_stock_inicial < 0 THEN
        SET p_mensaje = 'El stock inicial no puede ser negativo';
        LEAVE procedimiento;
    END IF;

    IF p_stock_minimo IS NULL OR p_stock_minimo < 0 THEN
        SET p_mensaje = 'El stock mínimo no puede ser negativo';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_categoria_existe
    FROM categorias
    WHERE categoria_id = p_categoria_id;

    IF v_categoria_existe = 0 THEN
        SET p_mensaje = 'La categoría indicada no existe';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_proveedor_existe
    FROM proveedores
    WHERE proveedor_id = p_proveedor_id;

    IF v_proveedor_existe = 0 THEN
        SET p_mensaje = 'El proveedor indicado no existe';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_producto_duplicado
    FROM productos
    WHERE nombre = TRIM(p_nombre);

    IF v_producto_duplicado > 0 THEN
        SET p_mensaje = 'Ya existe un producto con ese nombre';
        LEAVE procedimiento;
    END IF;

    START TRANSACTION;

    INSERT INTO productos (
        nombre,
        descripcion,
        precio,
        stock,
        stock_minimo,
        categoria_id,
        proveedor_id
    )
    VALUES (
        TRIM(p_nombre),
        NULLIF(TRIM(p_descripcion), ''),
        p_precio,
        p_stock_inicial,
        p_stock_minimo,
        p_categoria_id,
        p_proveedor_id
    );

    SET p_producto_id = LAST_INSERT_ID();

    IF p_stock_inicial > 0 THEN

        INSERT INTO movimientos_inventario (
            producto_id,
            tipo,
            cantidad,
            observacion
        )
        VALUES (
            p_producto_id,
            'ENTRADA',
            p_stock_inicial,
            'Inventario inicial del producto'
        );

    END IF;

    COMMIT;

    SET p_mensaje = 'Producto registrado correctamente';

END$$

-- Procedimiento 10: Listar los productos
DROP PROCEDURE IF EXISTS sp_productos_listar$$

CREATE PROCEDURE sp_productos_listar()
BEGIN

    SELECT
        p.producto_id,
        p.nombre,
        p.descripcion,
        p.precio,
        p.stock,
        p.stock_minimo,
        c.nombre AS categoria,
        pr.nombre AS proveedor,
        CASE
            WHEN p.stock <= p.stock_minimo THEN 'STOCK BAJO'
            ELSE 'STOCK DISPONIBLE'
        END AS estado_stock
    FROM productos p
    INNER JOIN categorias c
        ON p.categoria_id = c.categoria_id
    INNER JOIN proveedores pr
        ON p.proveedor_id = pr.proveedor_id
    ORDER BY p.nombre;

END$$

-- Procedimiento 11: Actualizar un producto
DROP PROCEDURE IF EXISTS sp_productos_actualizar$$

CREATE PROCEDURE sp_productos_actualizar(
    IN p_producto_id INT,
    IN p_nombre VARCHAR(100),
    IN p_descripcion VARCHAR(200),
    IN p_precio DECIMAL(10,2),
    IN p_stock_minimo INT,
    IN p_categoria_id INT,
    IN p_proveedor_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_producto_existe INT DEFAULT 0;
    DECLARE v_categoria_existe INT DEFAULT 0;
    DECLARE v_proveedor_existe INT DEFAULT 0;
    DECLARE v_producto_duplicado INT DEFAULT 0;

    SET p_mensaje = '';

    IF p_producto_id IS NULL OR p_producto_id <= 0 THEN
        SET p_mensaje = 'El identificador del producto no es válido';
        LEAVE procedimiento;
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SET p_mensaje = 'El nombre del producto es obligatorio';
        LEAVE procedimiento;
    END IF;

    IF p_precio IS NULL OR p_precio <= 0 THEN
        SET p_mensaje = 'El precio debe ser mayor que cero';
        LEAVE procedimiento;
    END IF;

    IF p_stock_minimo IS NULL OR p_stock_minimo < 0 THEN
        SET p_mensaje = 'El stock mínimo no puede ser negativo';
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

    SELECT COUNT(*)
    INTO v_categoria_existe
    FROM categorias
    WHERE categoria_id = p_categoria_id;

    IF v_categoria_existe = 0 THEN
        SET p_mensaje = 'La categoría indicada no existe';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_proveedor_existe
    FROM proveedores
    WHERE proveedor_id = p_proveedor_id;

    IF v_proveedor_existe = 0 THEN
        SET p_mensaje = 'El proveedor indicado no existe';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_producto_duplicado
    FROM productos
    WHERE nombre = TRIM(p_nombre)
      AND producto_id <> p_producto_id;

    IF v_producto_duplicado > 0 THEN
        SET p_mensaje = 'Ya existe otro producto con ese nombre';
        LEAVE procedimiento;
    END IF;

    UPDATE productos
    SET
        nombre = TRIM(p_nombre),
        descripcion = NULLIF(TRIM(p_descripcion), ''),
        precio = p_precio,
        stock_minimo = p_stock_minimo,
        categoria_id = p_categoria_id,
        proveedor_id = p_proveedor_id
    WHERE producto_id = p_producto_id;

    SET p_mensaje = 'Producto actualizado correctamente';

END$$

-- Procedimiento 12: Eliminar un producto
DROP PROCEDURE IF EXISTS sp_productos_eliminar$$

CREATE PROCEDURE sp_productos_eliminar(
    IN p_producto_id INT,
    OUT p_mensaje VARCHAR(200)
)
procedimiento: BEGIN

    DECLARE v_producto_existe INT DEFAULT 0;
    DECLARE v_detalles_venta INT DEFAULT 0;
    DECLARE v_movimientos INT DEFAULT 0;

    SET p_mensaje = '';

    IF p_producto_id IS NULL OR p_producto_id <= 0 THEN
        SET p_mensaje = 'El identificador del producto no es válido';
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

    SELECT COUNT(*)
    INTO v_detalles_venta
    FROM detalle_venta
    WHERE producto_id = p_producto_id;

    IF v_detalles_venta > 0 THEN
        SET p_mensaje =
            'No se puede eliminar el producto porque aparece en ventas registradas';
        LEAVE procedimiento;
    END IF;

    SELECT COUNT(*)
    INTO v_movimientos
    FROM movimientos_inventario
    WHERE producto_id = p_producto_id;

    IF v_movimientos > 0 THEN
        SET p_mensaje =
            'No se puede eliminar el producto porque posee movimientos de inventario';
        LEAVE procedimiento;
    END IF;

    DELETE FROM productos
    WHERE producto_id = p_producto_id;

    SET p_mensaje = 'Producto eliminado correctamente';

END$$

DELIMITER ;

