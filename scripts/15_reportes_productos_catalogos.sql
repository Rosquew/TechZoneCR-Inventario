-- TechZone CR - Avance 2https://github.com/Rosquew/TechZoneCR-Inventario/blob/main/scripts/15_reportes_productos_catalogos.sql
-- Reportes de productos y catálogos con cursores

USE techzone_cr;

DELIMITER $$

-- Reportes relacionadoss con productos
DROP PROCEDURE IF EXISTS sp_reporte_productos$$

CREATE PROCEDURE sp_reporte_productos()
BEGIN

    DECLARE terminado INT DEFAULT 0;

    DECLARE v_nombre VARCHAR(100);
    DECLARE v_stock INT;
    DECLARE v_stock_minimo INT;

    DECLARE v_productos TEXT DEFAULT '';
    DECLARE v_stock_bajo TEXT DEFAULT '';
    DECLARE v_agotados TEXT DEFAULT '';

    -- Cursor 1: Todos los productos
    DECLARE cur_productos CURSOR FOR
        SELECT nombre, stock
        FROM productos
        ORDER BY nombre;

    -- Cursor 2: Productos con stock bajo
    DECLARE cur_stock_bajo CURSOR FOR
        SELECT nombre, stock, stock_minimo
        FROM productos
        WHERE stock <= stock_minimo
          AND stock > 0
        ORDER BY nombre;

    -- Cursor 3: Productos agotados
    DECLARE cur_agotados CURSOR FOR
        SELECT nombre
        FROM productos
        WHERE stock = 0
        ORDER BY nombre;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET terminado = 1;

    -- Recorrer todos los productos
    OPEN cur_productos;

    productos_loop: LOOP

        FETCH cur_productos
        INTO v_nombre, v_stock;

        IF terminado = 1 THEN
            LEAVE productos_loop;
        END IF;

        SET v_productos = CONCAT(
            v_productos,
            IF(v_productos = '', '', CHAR(10)),
            v_nombre,
            ' - Stock: ',
            v_stock
        );

    END LOOP;

    CLOSE cur_productos;

    -- Recorrer productos con stock bajo
    SET terminado = 0;

    OPEN cur_stock_bajo;

    stock_loop: LOOP

        FETCH cur_stock_bajo
        INTO v_nombre, v_stock, v_stock_minimo;

        IF terminado = 1 THEN
            LEAVE stock_loop;
        END IF;

        SET v_stock_bajo = CONCAT(
            v_stock_bajo,
            IF(v_stock_bajo = '', '', CHAR(10)),
            v_nombre,
            ' - Stock: ',
            v_stock,
            ' - Mínimo: ',
            v_stock_minimo
        );

    END LOOP;

    CLOSE cur_stock_bajo;

    -- Recorrer productos agotados
    SET terminado = 0;

    OPEN cur_agotados;

    agotados_loop: LOOP

        FETCH cur_agotados
        INTO v_nombre;

        IF terminado = 1 THEN
            LEAVE agotados_loop;
        END IF;

        SET v_agotados = CONCAT(
            v_agotados,
            IF(v_agotados = '', '', CHAR(10)),
            v_nombre
        );

    END LOOP;

    CLOSE cur_agotados;

    SELECT
        IF(v_productos = '', 'No hay productos', v_productos)
            AS lista_productos,

        IF(v_stock_bajo = '', 'No hay productos con stock bajo', v_stock_bajo)
            AS productos_stock_bajo,

        IF(v_agotados = '', 'No hay productos agotados', v_agotados)
            AS productos_agotados;

END$$

-- Reportes de categorías, proveedores y clientes
DROP PROCEDURE IF EXISTS sp_reporte_catalogos$$

CREATE PROCEDURE sp_reporte_catalogos()
BEGIN

    DECLARE terminado INT DEFAULT 0;

    DECLARE v_nombre VARCHAR(100);
    DECLARE v_correo VARCHAR(100);
    DECLARE v_cantidad INT;

    DECLARE v_categorias TEXT DEFAULT '';
    DECLARE v_proveedores TEXT DEFAULT '';
    DECLARE v_clientes TEXT DEFAULT '';

    -- Cursor 4: Categorías y cantidad de productos
    DECLARE cur_categorias CURSOR FOR
        SELECT
            c.nombre,
            COUNT(p.producto_id)
        FROM categorias c
        LEFT JOIN productos p
            ON c.categoria_id = p.categoria_id
        GROUP BY c.categoria_id, c.nombre
        ORDER BY c.nombre;

    -- Cursor 5: Proveedores y cantidad de productos
    DECLARE cur_proveedores CURSOR FOR
        SELECT
            pr.nombre,
            COUNT(p.producto_id)
        FROM proveedores pr
        LEFT JOIN productos p
            ON pr.proveedor_id = p.proveedor_id
        GROUP BY pr.proveedor_id, pr.nombre
        ORDER BY pr.nombre;

    -- Cursor 6: Clientes registrados
    DECLARE cur_clientes CURSOR FOR
        SELECT nombre, correo
        FROM clientes
        ORDER BY nombre;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET terminado = 1;

    -- Recorrer categorías
    OPEN cur_categorias;

    categorias_loop: LOOP

        FETCH cur_categorias
        INTO v_nombre, v_cantidad;

        IF terminado = 1 THEN
            LEAVE categorias_loop;
        END IF;

        SET v_categorias = CONCAT(
            v_categorias,
            IF(v_categorias = '', '', CHAR(10)),
            v_nombre,
            ' - Productos: ',
            v_cantidad
        );

    END LOOP;

    CLOSE cur_categorias;

    -- Recorrer proveedores
    SET terminado = 0;

    OPEN cur_proveedores;

    proveedores_loop: LOOP

        FETCH cur_proveedores
        INTO v_nombre, v_cantidad;

        IF terminado = 1 THEN
            LEAVE proveedores_loop;
        END IF;

        SET v_proveedores = CONCAT(
            v_proveedores,
            IF(v_proveedores = '', '', CHAR(10)),
            v_nombre,
            ' - Productos: ',
            v_cantidad
        );

    END LOOP;

    CLOSE cur_proveedores;

    -- Recorrer clientes
    SET terminado = 0;

    OPEN cur_clientes;

    clientes_loop: LOOP

        FETCH cur_clientes
        INTO v_nombre, v_correo;

        IF terminado = 1 THEN
            LEAVE clientes_loop;
        END IF;

        SET v_clientes = CONCAT(
            v_clientes,
            IF(v_clientes = '', '', CHAR(10)),
            v_nombre,
            ' - ',
            COALESCE(v_correo, 'Sin correo')
        );

    END LOOP;

    CLOSE cur_clientes;

    SELECT
        IF(v_categorias = '', 'No hay categorías', v_categorias)
            AS resumen_categorias,

        IF(v_proveedores = '', 'No hay proveedores', v_proveedores)
            AS resumen_proveedores,

        IF(v_clientes = '', 'No hay clientes', v_clientes)
            AS lista_clientes;

END$$

DELIMITER ;
