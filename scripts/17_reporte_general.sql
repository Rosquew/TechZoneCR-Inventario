-- TechZone CR - Avance 2
-- Reporte general con cursores

USE techzone_cr;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_reporte_general$$

CREATE PROCEDURE sp_reporte_general()
BEGIN

    DECLARE terminado INT DEFAULT 0;

    DECLARE v_producto VARCHAR(100);
    DECLARE v_cliente VARCHAR(100);
    DECLARE v_valor DECIMAL(16,2);
    DECLARE v_total DECIMAL(16,2);
    DECLARE v_unidades INT;
    DECLARE v_posicion INT DEFAULT 0;

    DECLARE v_valor_inventario TEXT DEFAULT '';
    DECLARE v_compras_clientes TEXT DEFAULT '';
    DECLARE v_productos_vendidos TEXT DEFAULT '';

    -- Cursor 13: Valor del inventario por producto
    DECLARE cur_valor_inventario CURSOR FOR
        SELECT
            nombre,
            precio * stock
        FROM productos
        ORDER BY nombre;

    -- Cursor 14: Total comprado por cliente
    DECLARE cur_compras_clientes CURSOR FOR
        SELECT
            c.nombre,
            COALESCE(SUM(v.total), 0)
        FROM clientes c
        LEFT JOIN ventas v
            ON c.cliente_id = v.cliente_id
        GROUP BY c.cliente_id, c.nombre
        ORDER BY c.nombre;

    -- Cursor 15: Productos más vendidos
    DECLARE cur_productos_vendidos CURSOR FOR
        SELECT
            p.nombre,
            SUM(dv.cantidad)
        FROM detalle_venta dv
        INNER JOIN productos p
            ON dv.producto_id = p.producto_id
        GROUP BY p.producto_id, p.nombre
        ORDER BY SUM(dv.cantidad) DESC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET terminado = 1;

    -- Recorrer valor del inventario
    OPEN cur_valor_inventario;

    valor_loop: LOOP

        FETCH cur_valor_inventario
        INTO v_producto, v_valor;

        IF terminado = 1 THEN
            LEAVE valor_loop;
        END IF;

        SET v_valor_inventario = CONCAT(
            v_valor_inventario,
            IF(v_valor_inventario = '', '', CHAR(10)),
            v_producto,
            ' - Valor: ',
            FORMAT(v_valor, 2)
        );

    END LOOP;

    CLOSE cur_valor_inventario;

    -- Recorrer compras por cliente
    SET terminado = 0;

    OPEN cur_compras_clientes;

    clientes_loop: LOOP

        FETCH cur_compras_clientes
        INTO v_cliente, v_total;

        IF terminado = 1 THEN
            LEAVE clientes_loop;
        END IF;

        SET v_compras_clientes = CONCAT(
            v_compras_clientes,
            IF(v_compras_clientes = '', '', CHAR(10)),
            v_cliente,
            ' - Total comprado: ',
            FORMAT(v_total, 2)
        );

    END LOOP;

    CLOSE cur_compras_clientes;

    -- Recorrer productos vendidos
    SET terminado = 0;
    SET v_posicion = 0;

    OPEN cur_productos_vendidos;

    vendidos_loop: LOOP

        FETCH cur_productos_vendidos
        INTO v_producto, v_unidades;

        IF terminado = 1 THEN
            LEAVE vendidos_loop;
        END IF;

        SET v_posicion = v_posicion + 1;

        SET v_productos_vendidos = CONCAT(
            v_productos_vendidos,
            IF(v_productos_vendidos = '', '', CHAR(10)),
            v_posicion,
            '. ',
            v_producto,
            ' - Unidades vendidas: ',
            v_unidades
        );

    END LOOP;

    CLOSE cur_productos_vendidos;

    SELECT
        IF(
            v_valor_inventario = '',
            'No hay productos',
            v_valor_inventario
        ) AS valor_inventario,

        IF(
            v_compras_clientes = '',
            'No hay clientes',
            v_compras_clientes
        ) AS compras_clientes,

        IF(
            v_productos_vendidos = '',
            'No hay productos vendidos',
            v_productos_vendidos
        ) AS productos_vendidos;

END$$

DELIMITER ;