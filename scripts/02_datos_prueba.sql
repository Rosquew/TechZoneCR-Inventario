-- TechZone CR - Avance 2
-- Script 02: Inserción de datos de prueba

USE techzone_cr;

-- Datos de categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Laptops', 'Computadoras portátiles'),
('Periféricos', 'Teclados, mouse y accesorios'),
('Componentes', 'Memorias, discos y piezas internas'),
('Monitores', 'Pantallas y dispositivos de visualización'),
('Dispositivos móviles', 'Teléfonos y tabletas');

-- Datos de proveedores
INSERT INTO proveedores (nombre, telefono, correo, direccion) VALUES
('TechDistribuidora CR', '2222-1000', 'ventas@techdist.cr', 'San José, Costa Rica'),
('Componentes del Valle', '2233-2000', 'info@compvalle.cr', 'Heredia, Costa Rica'),
('Periféricos Express', '2244-3000', 'contacto@perifex.cr', 'Alajuela, Costa Rica'),
('Soluciones Digitales CR', '2255-4000', 'ventas@solucionesdigitales.cr', 'Cartago, Costa Rica');

-- Datos de productos
INSERT INTO productos (
    nombre,
    descripcion,
    precio,
    stock,
    stock_minimo,
    categoria_id,
    proveedor_id
) VALUES
('Laptop HP 15', 'Intel i5, 8 GB RAM, 512 GB SSD', 450000.00, 25, 5, 1, 1),
('Laptop Lenovo IdeaPad', 'Ryzen 5, 16 GB RAM, 256 GB SSD', 520000.00, 15, 3, 1, 1),
('Mouse Logitech M185', 'Mouse inalámbrico compacto', 8500.00, 80, 10, 2, 3),
('Teclado Redragon K552', 'Teclado mecánico RGB', 35000.00, 40, 8, 2, 3),
('SSD Kingston 480 GB', 'Unidad SATA III de 2.5 pulgadas', 28000.00, 60, 15, 3, 2),
('RAM Kingston 8 GB DDR4', 'Memoria de 3200 MHz', 22000.00, 50, 10, 3, 2),
('Monitor Samsung 24 pulgadas', 'Monitor Full HD IPS', 95000.00, 20, 4, 4, 1),
('Monitor LG 27 pulgadas', 'Monitor QHD IPS', 185000.00, 3, 5, 4, 1),
('Tablet Samsung Galaxy Tab', 'Pantalla de 10.5 pulgadas y 128 GB', 210000.00, 12, 3, 5, 4),
('Cargador USB-C 65 W', 'Cargador rápido para laptops y teléfonos', 24000.00, 35, 7, 2, 3);

-- Datos de clientes
INSERT INTO clientes (nombre, correo, telefono) VALUES
('Carlos Rodríguez', 'carlos.rodriguez@crmail.com', '8701-2233'),
('Sofía Méndez', 'sofia.mendez@crmail.com', '8888-4455'),
('Empresa Digital S.A.', 'compras@digital.cr', '2501-9900'),
('María Fernández', 'maria.fernandez@crmail.com', '8312-7788'),
('Andrés Vargas', 'andres.vargas@crmail.com', '8600-1144');

SELECT 'Datos de prueba insertados correctamente' AS resultado;

SELECT 'Categorias' AS tabla, COUNT(*) AS registros
FROM categorias

UNION ALL

SELECT 'Proveedores', COUNT(*)
FROM proveedores

UNION ALL

SELECT 'Productos', COUNT(*)
FROM productos

UNION ALL

SELECT 'Clientes', COUNT(*)
FROM clientes;