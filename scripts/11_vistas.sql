-- TechZone CR - Avance 2
-- Script 11: Creación de vistas

USE techzone_cr;

-- Vista 1: Información completa de los productos
CREATE OR REPLACE VIEW vw_productos_completos AS
SELECT
    p.producto_id,
    p.nombre AS producto,
    p.descripcion,
    p.precio,
    p.stock,
    p.stock_minimo,
    c.categoria_id,
    c.nombre AS categoria,
    pr.proveedor_id,
    pr.nombre AS proveedor,
    CASE
        WHEN p.stock = 0 THEN 'AGOTADO'
        WHEN p.stock <= p.stock_minimo THEN 'STOCK BAJO'
        ELSE 'DISPONIBLE'
    END AS estado_stock
FROM productos p
INNER JOIN categorias c
    ON p.categoria_id = c.categoria_id
INNER JOIN proveedores pr
    ON p.proveedor_id = pr.proveedor_id;

-- Vista 2: Productos de stock bajo
CREATE OR REPLACE VIEW vw_productos_bajo_stock AS
SELECT
    p.producto_id,
    p.nombre AS producto,
    p.stock,
    p.stock_minimo,
    c.nombre AS categoria,
    pr.nombre AS proveedor
FROM productos p
INNER JOIN categorias c
    ON p.categoria_id = c.categoria_id
INNER JOIN proveedores pr
    ON p.proveedor_id = pr.proveedor_id
WHERE p.stock <= p.stock_minimo;

-- Vista 3: Productos agotados
CREATE OR REPLACE VIEW vw_productos_agotados AS
SELECT
    p.producto_id,
    p.nombre AS producto,
    c.nombre AS categoria,
    pr.nombre AS proveedor,
    p.stock_minimo
FROM productos p
INNER JOIN categorias c
    ON p.categoria_id = c.categoria_id
INNER JOIN proveedores pr
    ON p.proveedor_id = pr.proveedor_id
WHERE p.stock = 0;

-- Vista 4: Valor monetario del inventario por producto
CREATE OR REPLACE VIEW vw_valor_inventario_producto AS
SELECT
    producto_id,
    nombre AS producto,
    precio,
    stock,
    precio * stock AS valor_inventario
FROM productos;

-- Vista 5: Resumen del inventario por categoría
CREATE OR REPLACE VIEW vw_resumen_inventario_categoria AS
SELECT
    c.categoria_id,
    c.nombre AS categoria,
    COUNT(p.producto_id) AS cantidad_productos,
    COALESCE(SUM(p.stock), 0) AS unidades_disponibles,
    COALESCE(SUM(p.precio * p.stock), 0) AS valor_inventario
FROM categorias c
LEFT JOIN productos p
    ON c.categoria_id = p.categoria_id
GROUP BY
    c.categoria_id,
    c.nombre;

-- Vista 6: Resumen del inventario por proveedor
CREATE OR REPLACE VIEW vw_resumen_inventario_proveedor AS
SELECT
    pr.proveedor_id,
    pr.nombre AS proveedor,
    COUNT(p.producto_id) AS cantidad_productos,
    COALESCE(SUM(p.stock), 0) AS unidades_disponibles,
    COALESCE(SUM(p.precio * p.stock), 0) AS valor_inventario
FROM proveedores pr
LEFT JOIN productos p
    ON pr.proveedor_id = p.proveedor_id
GROUP BY
    pr.proveedor_id,
    pr.nombre;

-- Vista 7: Resumen general de las ventas
CREATE OR REPLACE VIEW vw_ventas_resumen AS
SELECT
    v.venta_id,
    v.fecha_venta,
    c.cliente_id,
    c.nombre AS cliente,
    COUNT(dv.detalle_id) AS cantidad_lineas,
    COALESCE(SUM(dv.cantidad), 0) AS unidades_vendidas,
    v.total
FROM ventas v
INNER JOIN clientes c
    ON v.cliente_id = c.cliente_id
LEFT JOIN detalle_venta dv
    ON v.venta_id = dv.venta_id
GROUP BY
    v.venta_id,
    v.fecha_venta,
    c.cliente_id,
    c.nombre,
    v.total;

-- Vista 8: Detalle completo de las ventas
CREATE OR REPLACE VIEW vw_ventas_detalle AS
SELECT
    v.venta_id,
    v.fecha_venta,
    c.nombre AS cliente,
    dv.detalle_id,
    p.producto_id,
    p.nombre AS producto,
    dv.cantidad,
    dv.precio_unitario,
    dv.subtotal
FROM ventas v
INNER JOIN clientes c
    ON v.cliente_id = c.cliente_id
INNER JOIN detalle_venta dv
    ON v.venta_id = dv.venta_id
INNER JOIN productos p
    ON dv.producto_id = p.producto_id;

-- Vista 9: Compras acumuladas por cliente
CREATE OR REPLACE VIEW vw_ventas_por_cliente AS
SELECT
    c.cliente_id,
    c.nombre AS cliente,
    c.correo,
    COUNT(v.venta_id) AS cantidad_ventas,
    COALESCE(SUM(v.total), 0) AS total_comprado,
    MAX(v.fecha_venta) AS ultima_compra
FROM clientes c
LEFT JOIN ventas v
    ON c.cliente_id = v.cliente_id
GROUP BY
    c.cliente_id,
    c.nombre,
    c.correo;

-- Vista 10: Historial detallado de movimientos de inventario
CREATE OR REPLACE VIEW vw_movimientos_inventario AS
SELECT
    m.movimiento_id,
    m.fecha,
    m.tipo,
    m.cantidad,
    m.observacion,
    p.producto_id,
    p.nombre AS producto,
    c.nombre AS categoria,
    pr.nombre AS proveedor
FROM movimientos_inventario m
INNER JOIN productos p
    ON m.producto_id = p.producto_id
INNER JOIN categorias c
    ON p.categoria_id = c.categoria_id
INNER JOIN proveedores pr
    ON p.proveedor_id = pr.proveedor_id;
