-- TechZone CR - Avance 2
-- Script 01: Creación de las tablas del proyecto

USE techzone_cr;

-- Tabla categorias
CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    descripcion VARCHAR(200),

    CONSTRAINT pk_categorias
        PRIMARY KEY (categoria_id),

    CONSTRAINT uq_categorias_nombre
        UNIQUE (nombre)
);

-- Tabla proveedores
CREATE TABLE proveedores (
    proveedor_id INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion VARCHAR(150),

    CONSTRAINT pk_proveedores
        PRIMARY KEY (proveedor_id),

    CONSTRAINT uq_proveedores_correo
        UNIQUE (correo)
);

-- Tabla productos
CREATE TABLE productos (
    producto_id INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200),
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 5,
    categoria_id INT NOT NULL,
    proveedor_id INT NOT NULL,

    CONSTRAINT pk_productos
        PRIMARY KEY (producto_id),

    CONSTRAINT chk_productos_precio
        CHECK (precio >= 0),

    CONSTRAINT chk_productos_stock
        CHECK (stock >= 0),

    CONSTRAINT chk_productos_stock_minimo
        CHECK (stock_minimo >= 0),

    CONSTRAINT fk_productos_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categorias (categoria_id),

    CONSTRAINT fk_productos_proveedor
        FOREIGN KEY (proveedor_id)
        REFERENCES proveedores (proveedor_id)
);

-- Tabla clientes
CREATE TABLE clientes (
    cliente_id INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100),
    telefono VARCHAR(20),

    CONSTRAINT pk_clientes
        PRIMARY KEY (cliente_id),

    CONSTRAINT uq_clientes_correo
        UNIQUE (correo)
);

-- Tabla ventas
CREATE TABLE ventas (
    venta_id INT AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL DEFAULT 0,

    CONSTRAINT pk_ventas
        PRIMARY KEY (venta_id),

    CONSTRAINT chk_ventas_total
        CHECK (total >= 0),

    CONSTRAINT fk_ventas_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes (cliente_id)
);

-- Tabla detalle_venta
CREATE TABLE detalle_venta (
    detalle_id INT AUTO_INCREMENT,
    venta_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,

    subtotal DECIMAL(12,2)
        GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,

    CONSTRAINT pk_detalle_venta
        PRIMARY KEY (detalle_id),

    CONSTRAINT uq_detalle_venta_producto
        UNIQUE (venta_id, producto_id),

    CONSTRAINT chk_detalle_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT chk_detalle_precio
        CHECK (precio_unitario >= 0),

    CONSTRAINT fk_detalle_venta
        FOREIGN KEY (venta_id)
        REFERENCES ventas (venta_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos (producto_id)
);

-- Tabla movimientos_inventario
CREATE TABLE movimientos_inventario (
    movimiento_id INT AUTO_INCREMENT,
    producto_id INT NOT NULL,
    tipo ENUM('ENTRADA', 'SALIDA') NOT NULL,
    cantidad INT NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observacion VARCHAR(200),

    CONSTRAINT pk_movimientos_inventario
        PRIMARY KEY (movimiento_id),

    CONSTRAINT chk_movimiento_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT fk_movimiento_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos (producto_id)
);
