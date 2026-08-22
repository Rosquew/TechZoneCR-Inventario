# Sistema de Gestión de Inventario - TechZone CR

Este proyecto corresponde al desarrollo de un sistema de gestión de inventario para la empresa ficticia TechZone CR, realizado como parte del curso Lenguajes de Base de Datos.

El sistema permite administrar categorías, proveedores, productos, clientes, ventas y movimientos de inventario mediante una interfaz gráfica desarrollada en Python con Tkinter. La información se almacena en una base de datos MySQL y las principales operaciones se realizan mediante procedimientos almacenados.

## Funcionalidades principales

- Gestión de categorías.
- Gestión de proveedores.
- Gestión de productos.
- Gestión de clientes.
- Registro y administración de ventas.
- Registro y administración del detalle de las ventas.
- Control de entradas y salidas de inventario.
- Consulta de reportes.
- Operaciones CRUD mediante procedimientos almacenados.
- Uso de funciones, vistas, triggers y cursores en MySQL.
- Conexión entre Python y MySQL.
- Interfaz gráfica desarrollada con Tkinter.

## Base de datos

El sistema utiliza una base de datos MySQL llamada:

```text
techzone_cr
```

Los archivos necesarios para crear y configurar la base de datos se encuentran en la carpeta:

```text
scripts
```

Los scripts deben ejecutarse en MySQL Workbench siguiendo el orden numérico en el que se encuentran organizados.

Estos archivos contienen los elementos necesarios para crear las tablas, procedimientos almacenados, funciones, vistas, triggers, cursores y datos utilizados por el sistema.

Las principales tablas son:

- `categorias`
- `proveedores`
- `productos`
- `clientes`
- `ventas`
- `detalle_venta`
- `movimientos_inventario`

## Configuración de conexión

La configuración para conectarse con MySQL se realiza mediante el archivo:

```text
python/config.py
```

Este archivo no se incluye directamente en el repositorio porque contiene la contraseña utilizada para acceder a MySQL.

Como referencia se incluye:

```text
python/config.example
```

Se debe crear un archivo llamado `config.py` dentro de la carpeta `python` con una configuración similar a la siguiente:

```python
DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "COLOQUE_SU_CONTRASENA",
    "database": "techzone_cr"
}
```

La contraseña debe modificarse de acuerdo con la configuración de MySQL del equipo donde se ejecutará el proyecto.

## Requisitos

Para ejecutar el proyecto se necesita:

- Python 3.
- MySQL Server.
- MySQL Workbench.
- mysql-connector-python.
- Tkinter.

Las dependencias necesarias se encuentran en:

```text
python/requirements.txt
```

## Cómo ejecutar el proyecto

1. Iniciar MySQL Server.
2. Abrir MySQL Workbench.
3. Ejecutar los archivos de la carpeta `scripts` siguiendo su orden numérico.
4. Verificar que la base de datos `techzone_cr` se haya creado correctamente.
5. Crear el archivo `config.py` dentro de la carpeta `python`, utilizando `config.example` como referencia.
6. Colocar el usuario y la contraseña correspondientes a MySQL.
7. Abrir una terminal dentro de la carpeta `python`.
8. Instalar las dependencias:

```bash
pip install -r requirements.txt
```

9. Ejecutar la interfaz gráfica:

```bash
python interfaz.py
```

Al iniciar correctamente se mostrará el menú principal del sistema TechZone CR y un mensaje indicando que la conexión con MySQL se realizó correctamente.

## Estructura del proyecto

```text
TechZoneCR-Inventario/
│
├── README.md
├── .gitignore
│
├── python/
│   ├── interfaz.py
│   ├── main.py
│   ├── config.example
│   ├── requirements.txt
│   │
│   ├── db/
│   │   └── conexion.py
│   │
│   └── modulos/
│       ├── categorias.py
│       ├── proveedores.py
│       ├── productos.py
│       ├── clientes.py
│       ├── ventas.py
│       ├── inventario.py
│       └── reportes.py
│
└── scripts/
    └── Archivos SQL del proyecto
```

### Carpeta `python`

Contiene el código de la aplicación y los archivos necesarios para realizar la conexión con MySQL.

- `interfaz.py`: interfaz gráfica desarrollada con Tkinter.
- `main.py`: versión del sistema utilizada desde consola.
- `config.example`: ejemplo de la configuración de conexión.
- `requirements.txt`: dependencias necesarias para ejecutar el proyecto.

### Carpeta `python/db`

Contiene el archivo encargado de establecer la conexión entre Python y MySQL.

- `conexion.py`

### Carpeta `python/modulos`

Contiene los módulos utilizados para trabajar con las diferentes áreas del sistema.

- `categorias.py`
- `proveedores.py`
- `productos.py`
- `clientes.py`
- `ventas.py`
- `inventario.py`
- `reportes.py`

### Carpeta `scripts`

Contiene los archivos SQL utilizados para construir y configurar la base de datos.

## Tecnologías utilizadas

- Python.
- Tkinter.
- MySQL.
- MySQL Workbench.
- mysql-connector-python.
- SQL.
- Git.
- GitHub.

## Integrantes

- Kevin Montero Fernández.
- Danny Castro Méndez.
- Mariana Rodríguez Orellana.

## Proyecto académico

Proyecto desarrollado para el curso **Lenguajes de Base de Datos, 2026**.
