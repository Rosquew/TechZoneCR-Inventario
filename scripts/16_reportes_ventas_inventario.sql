-- TechZone CR - Avance 2
-- Reportes de ventas e inventario con cursores

USE techzone_cr;

DELIMITER $$

-- Reportes relacionados con ventas
DROP PROCEDURE IF EXISTS sp_reporte_ventas$$

CREATE PROCEDURE sp_reporte_ventas()
BEGIN

    DECLARE terminado INT DEFAULT 0;

    DECLARE v_venta_id INT;
    DECLARE v_cliente VARCHAR(100);
    DECLARE v_producto VARCHAR(100);
    DECLARE v_cantidad INT;
    DECLARE v_anio INT;
    DECLARE v_mes INT;
    DECLARE v_total DECIMAL(16,2);

    DECLARE v_ventas TEXT DEFAULT '';
    DECLARE v_detalles TEXT DEFAULT '';
    DECLARE v_ventas_mes TEXT DEFAULT '';

    -- Cursor 7: Ventas registradas
    DECLARE cur_ventas CURSOR FOR
        SELECT
            v.venta_id,
            c.nombre,
            v.total
        FROM ventas v
        INNER JOIN clientes c
            ON v.cliente_id = c.cliente_id
        ORDER BY v.venta_id;

    -- Cursor 8: Detalles de ventas
    DECLARE cur_detalles CURSOR FOR
        SELECT
            dv.venta_id,
            p.nombre,
            dv.cantidad
        FROM detalle_venta dv
        INNER JOIN productos p
            ON dv.producto_id = p.producto_id
        ORDER BY dv.venta_id, p.nombre;

    -- Cursor 9: Ventas agrupadas por mes
    DECLARE cur_ventas_mes CURSOR FOR
        SELECT
            YEAR(fecha_venta),
            MONTH(fecha_venta),
            SUM(total)
        FROM ventas
        GROUP BY
            YEAR(fecha_venta),
            MONTH(fecha_venta)
        ORDER BY
            YEAR(fecha_venta),
            MONTH(fecha_venta);

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET terminado = 1;

    -- Recorrer ventas
    OPEN cur_ventas;

    ventas_loop: LOOP

        FETCH cur_ventas
        INTO v_venta_id, v_cliente, v_total;

        IF terminado = 1 THEN
            LEAVE ventas_loop;
        END IF;

        SET v_ventas = CONCAT(
            v_ventas,
            IF(v_ventas = '', '', CHAR(10)),
            'Venta ',
            v_venta_id,
            ' - ',
            v_cliente,
            ' - Total: ',
            FORMAT(v_total, 2)
        );

    END LOOP;

    CLOSE cur_ventas;

    -- Recorrer detalles
    SET terminado = 0;

    OPEN cur_detalles;

    detalles_loop: LOOP

        FETCH cur_detalles
        INTO v_venta_id, v_producto, v_cantidad;

        IF terminado = 1 THEN
            LEAVE detalles_loop;
        END IF;

        SET v_detalles = CONCAT(
            v_detalles,
            IF(v_detalles = '', '', CHAR(10)),
            'Venta ',
            v_venta_id,
            ' - ',
            v_producto,
            ' - Cantidad: ',
            v_cantidad
        );

    END LOOP;

    CLOSE cur_detalles;

    -- Recorrer ventas por mes
    SET terminado = 0;

    OPEN cur_ventas_mes;

    ventas_mes_loop: LOOP

        FETCH cur_ventas_mes
        INTO v_anio, v_mes, v_total;

        IF terminado = 1 THEN
            LEAVE ventas_mes_loop;
        END IF;

        SET v_ventas_mes = CONCAT(
            v_ventas_mes,
            IF(v_ventas_mes = '', '', CHAR(10)),
            v_mes,
            '/',
            v_anio,
            ' - Total: ',
            FORMAT(v_total, 2)
        );

    END LOOP;

    CLOSE cur_ventas_mes;

    SELECT
        IF(v_ventas = '', 'No hay ventas registradas', v_ventas)
            AS lista_ventas,

        IF(v_detalles = '', 'No hay detalles de ventas', v_detalles)
            AS detalles_ventas,

        IF(v_ventas_mes = '', 'No hay ventas por mes', v_ventas_mes)
            AS ventas_por_mes;

END$$

-- Reportes relacionados con movimientos de inventario
DROP PROCEDURE IF EXISTS sp_reporte_inventario$$

CREATE PROCEDURE sp_reporte_inventario()
BEGIN

    DECLARE terminado INT DEFAULT 0;

    DECLARE v_producto VARCHAR(100);
    DECLARE v_tipo VARCHAR(10);
    DECLARE v_cantidad INT;

    DECLARE v_movimientos TEXT DEFAULT '';
    DECLARE v_entradas TEXT DEFAULT '';
    DECLARE v_salidas TEXT DEFAULT '';

    -- Cursor 10: Todos los movimientos
    DECLARE cur_movimientos CURSOR FOR
        SELECT
            p.nombre,
            m.tipo,
            m.cantidad
        FROM movimientos_inventario m
        INNER JOIN productos p
            ON m.producto_id = p.producto_id
        ORDER BY m.fecha;

    -- Cursor 11: Entradas de inventario
    DECLARE cur_entradas CURSOR FOR
        SELECT
            p.nombre,
            m.cantidad
        FROM movimientos_inventario m
        INNER JOIN productos p
            ON m.producto_id = p.producto_id
        WHERE m.tipo = 'ENTRADA'
        ORDER BY m.fecha;

    -- Cursor 12: Salidas de inventario
    DECLARE cur_salidas CURSOR FOR
        SELECT
            p.nombre,
            m.cantidad
        FROM movimientos_inventario m
        INNER JOIN productos p
            ON m.producto_id = p.producto_id
        WHERE m.tipo = 'SALIDA'
        ORDER BY m.fecha;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET terminado = 1;

    -- Recorrer movimientos
    OPEN cur_movimientos;

    movimientos_loop: LOOP

        FETCH cur_movimientos
        INTO v_producto, v_tipo, v_cantidad;

        IF terminado = 1 THEN
            LEAVE movimientos_loop;
        END IF;

        SET v_movimientos = CONCAT(
            v_movimientos,
            IF(v_movimientos = '', '', CHAR(10)),
            v_producto,
            ' - ',
            v_tipo,
            ' - Cantidad: ',
            v_cantidad
        );

    END LOOP;

    CLOSE cur_movimientos;

    -- Recorrer entradas
    SET terminado = 0;

    OPEN cur_entradas;

    entradas_loop: LOOP

        FETCH cur_entradas
        INTO v_producto, v_cantidad;

        IF terminado = 1 THEN
            LEAVE entradas_loop;
        END IF;

        SET v_entradas = CONCAT(
            v_entradas,
            IF(v_entradas = '', '', CHAR(10)),
            v_producto,
            ' - Entrada: ',
            v_cantidad
        );

    END LOOP;

    CLOSE cur_entradas;

    -- Recorrer salidas
    SET terminado = 0;

    OPEN cur_salidas;

    salidas_loop: LOOP

        FETCH cur_salidas
        INTO v_producto, v_cantidad;

        IF terminado = 1 THEN
            LEAVE salidas_loop;
        END IF;

        SET v_salidas = CONCAT(
            v_salidas,
            IF(v_salidas = '', '', CHAR(10)),
            v_producto,
            ' - Salida: ',
            v_cantidad
        );

    END LOOP;

    CLOSE cur_salidas;

    SELECT
        IF(v_movimientos = '', 'No hay movimientos registrados', v_movimientos)
            AS movimientos,

        IF(v_entradas = '', 'No hay entradas registradas', v_entradas)
            AS entradas,

        IF(v_salidas = '', 'No hay salidas registradas', v_salidas)
            AS salidas;

END$$

DELIMITER ;
