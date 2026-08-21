-- TechZone CR - Avance 2
-- Triggers para controlar ventas e inventario

USE techzone_cr;

DELIMITER $$

-- Trigger 1: Validar stock antes de insertar un detalle
DROP TRIGGER IF EXISTS trg_detalle_bi_validar_stock$$

CREATE TRIGGER trg_detalle_bi_validar_stock
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN

    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_precio DECIMAL(10,2) DEFAULT 0;

    IF NEW.cantidad IS NULL OR NEW.cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad debe ser mayor que cero';
    END IF;

    SELECT
        COUNT(*),
        COALESCE(MAX(stock), 0),
        COALESCE(MAX(precio), 0)
    INTO
        v_existe,
        v_stock,
        v_precio
    FROM productos
    WHERE producto_id = NEW.producto_id;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto indicado no existe';
    END IF;

    IF NEW.cantidad > v_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existe suficiente stock para realizar la venta';
    END IF;

    SET NEW.precio_unitario = v_precio;

END$$

-- Trigger 2: Procesar la inserción del  detalle
DROP TRIGGER IF EXISTS trg_detalle_ai_procesar$$

CREATE TRIGGER trg_detalle_ai_procesar
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN

    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE producto_id = NEW.producto_id;

    UPDATE ventas
    SET total = total + NEW.subtotal
    WHERE venta_id = NEW.venta_id;

    INSERT INTO movimientos_inventario (
        producto_id,
        tipo,
        cantidad,
        observacion
    )
    VALUES (
        NEW.producto_id,
        'SALIDA',
        NEW.cantidad,
        CONCAT('Venta número ', NEW.venta_id)
    );

END$$

-- Trigger 3: Validar stock antes de actualizar un detalle
DROP TRIGGER IF EXISTS trg_detalle_bu_validar_stock$$

CREATE TRIGGER trg_detalle_bu_validar_stock
BEFORE UPDATE ON detalle_venta
FOR EACH ROW
BEGIN

    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_stock_disponible INT DEFAULT 0;
    DECLARE v_precio DECIMAL(10,2) DEFAULT 0;

    IF NEW.cantidad IS NULL OR NEW.cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad debe ser mayor que cero';
    END IF;

    SELECT
        COUNT(*),
        COALESCE(MAX(stock), 0),
        COALESCE(MAX(precio), 0)
    INTO
        v_existe,
        v_stock,
        v_precio
    FROM productos
    WHERE producto_id = NEW.producto_id;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto indicado no existe';
    END IF;

    IF NEW.producto_id = OLD.producto_id THEN
        SET v_stock_disponible = v_stock + OLD.cantidad;
    ELSE
        SET v_stock_disponible = v_stock;
    END IF;

    IF NEW.cantidad > v_stock_disponible THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No existe suficiente stock para actualizar el detalle';
    END IF;

    SET NEW.precio_unitario = v_precio;

END$$

-- Trigger 4: Procesar la actualización de un detalle
DROP TRIGGER IF EXISTS trg_detalle_au_procesar$$

CREATE TRIGGER trg_detalle_au_procesar
AFTER UPDATE ON detalle_venta
FOR EACH ROW
BEGIN

    DECLARE v_diferencia INT DEFAULT 0;

    IF NEW.producto_id = OLD.producto_id THEN

        SET v_diferencia = NEW.cantidad - OLD.cantidad;

        IF v_diferencia > 0 THEN

            UPDATE productos
            SET stock = stock - v_diferencia
            WHERE producto_id = NEW.producto_id;

            INSERT INTO movimientos_inventario (
                producto_id,
                tipo,
                cantidad,
                observacion
            )
            VALUES (
                NEW.producto_id,
                'SALIDA',
                v_diferencia,
                CONCAT('Actualización de venta número ', NEW.venta_id)
            );

        ELSEIF v_diferencia < 0 THEN

            UPDATE productos
            SET stock = stock + ABS(v_diferencia)
            WHERE producto_id = NEW.producto_id;

            INSERT INTO movimientos_inventario (
                producto_id,
                tipo,
                cantidad,
                observacion
            )
            VALUES (
                NEW.producto_id,
                'ENTRADA',
                ABS(v_diferencia),
                CONCAT('Reducción de cantidad en venta número ', NEW.venta_id)
            );

        END IF;

    ELSE

        UPDATE productos
        SET stock = stock + OLD.cantidad
        WHERE producto_id = OLD.producto_id;

        INSERT INTO movimientos_inventario (
            producto_id,
            tipo,
            cantidad,
            observacion
        )
        VALUES (
            OLD.producto_id,
            'ENTRADA',
            OLD.cantidad,
            CONCAT('Cambio de producto en venta número ', OLD.venta_id)
        );

        UPDATE productos
        SET stock = stock - NEW.cantidad
        WHERE producto_id = NEW.producto_id;

        INSERT INTO movimientos_inventario (
            producto_id,
            tipo,
            cantidad,
            observacion
        )
        VALUES (
            NEW.producto_id,
            'SALIDA',
            NEW.cantidad,
            CONCAT('Nuevo producto en venta número ', NEW.venta_id)
        );

    END IF;

    IF NEW.venta_id = OLD.venta_id THEN

        UPDATE ventas
        SET total = GREATEST(
            total - OLD.subtotal + NEW.subtotal,
            0
        )
        WHERE venta_id = NEW.venta_id;

    ELSE

        UPDATE ventas
        SET total = GREATEST(total - OLD.subtotal, 0)
        WHERE venta_id = OLD.venta_id;

        UPDATE ventas
        SET total = total + NEW.subtotal
        WHERE venta_id = NEW.venta_id;

    END IF;

END$$

-- Trigger 5: Revertir stock y total al eliminar un detalle
DROP TRIGGER IF EXISTS trg_detalle_ad_revertir$$

CREATE TRIGGER trg_detalle_ad_revertir
AFTER DELETE ON detalle_venta
FOR EACH ROW
BEGIN

    UPDATE productos
    SET stock = stock + OLD.cantidad
    WHERE producto_id = OLD.producto_id;

    UPDATE ventas
    SET total = GREATEST(total - OLD.subtotal, 0)
    WHERE venta_id = OLD.venta_id;

    INSERT INTO movimientos_inventario (
        producto_id,
        tipo,
        cantidad,
        observacion
    )
    VALUES (
        OLD.producto_id,
        'ENTRADA',
        OLD.cantidad,
        CONCAT('Eliminación de detalle de venta número ', OLD.venta_id)
    );

END$$

DELIMITER ;
