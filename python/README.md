Sistema de Gestión de Inventario - TechZone CR

Este proyecto corresponde al desarrollo de un sistema de gestión de inventario para la empresa ficticia TechZone CR, realizado como parte del curso Lenguajes de Base de Datos.

El sistema permite administrar categorías, proveedores, productos, clientes, ventas y movimientos de inventario mediante una interfaz gráfica desarrollada en Python con Tkinter. La información se almacena en una base de datos MySQL y las principales operaciones se realizan mediante procedimientos almacenados.

Funcionalidades principales
Gestión de categorías.
Gestión de proveedores.
Gestión de productos.
Gestión de clientes.
Registro y administración de ventas.
Registro y administración del detalle de las ventas.
Control de entradas y salidas de inventario.
Actualización automática de información relacionada con ventas e inventario.
Consulta de diferentes reportes.
Uso de procedimientos almacenados para las operaciones CRUD.
Uso de funciones, vistas, triggers y cursores en MySQL.
Conexión entre Python y MySQL.
Interfaz gráfica desarrollada con Tkinter.
Base de datos

El sistema utiliza una base de datos MySQL llamada:

techzone_cr

Los archivos necesarios para crear la base de datos se encuentran dentro de la carpeta:

scripts

Los scripts deben ejecutarse en MySQL Workbench siguiendo el orden numérico en el que se encuentran organizados.

Estos archivos permiten crear las tablas, procedimientos almacenados, funciones, vistas, triggers, cursores y demás componentes utilizados por el sistema.

Las principales tablas de la base de datos son:

categorias
proveedores
productos
clientes
ventas
detalle_venta
movimientos_inventario
Configuración de conexión

La configuración utilizada para conectarse con MySQL se encuentra en:

python/config.py

Por seguridad, este archivo no se incluye directamente en el repositorio debido a que contiene la contraseña utilizada para acceder a MySQL.

En el proyecto se incluye el archivo:

python/config.example

Este archivo puede utilizarse como referencia para crear el archivo config.py.

La configuración debe tener una estructura similar a la siguiente:

DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "contraseña_mysql",
    "database": "techzone_cr"
}


La contraseña debe modificarse de acuerdo con la configuración de MySQL utilizada en el equipo donde se ejecutará el sistema.

Requisitos

Para ejecutar el proyecto se necesita tener instalado:

Python 3.
MySQL Server.
MySQL Workbench.
mysql-connector-python.
Tkinter, incluido normalmente con la instalación de Python.

Las dependencias de Python también se encuentran indicadas en el archivo:

python/requirements.txt

Para instalarlas se puede utilizar:

pip install -r requirements.txt

Cómo ejecutar el proyecto
Iniciar MySQL Server.
Abrir MySQL Workbench.
Ejecutar los archivos de la carpeta scripts siguiendo su orden correspondiente.
Verificar que la base de datos techzone_cr haya sido creada correctamente.
Crear el archivo config.py dentro de la carpeta python utilizando config.example como referencia.
Colocar en config.py el usuario y contraseña correspondientes a MySQL.
Abrir una terminal dentro de la carpeta python.
Instalar las dependencias utilizando:
pip install -r requirements.txt

Ejecutar la interfaz gráfica utilizando:
python interfaz.py


Al iniciar correctamente, se mostrará el menú principal de TechZone CR y el mensaje indicando que la conexión con MySQL se realizó correctamente.

Estructura del proyecto
python

Contiene el código utilizado para conectar la aplicación con MySQL y ejecutar las diferentes funciones del sistema.

Archivos principales:

interfaz.py: contiene la interfaz gráfica desarrollada con Tkinter.
main.py: contiene la versión del sistema utilizada desde consola.
config.py: contiene la configuración local de conexión con MySQL.
config.example: ejemplo de la configuración necesaria.
requirements.txt: contiene las dependencias necesarias para ejecutar el proyecto.
python/db

Contiene el archivo encargado de establecer la conexión con MySQL.

conexion.py
python/modulos

Contiene los módulos utilizados para trabajar con las diferentes áreas del sistema.

categorias.py
proveedores.py
productos.py
clientes.py
ventas.py
inventario.py
reportes.py
scripts

Contiene los archivos SQL utilizados para construir y configurar la base de datos.

Dentro de estos scripts se encuentran los elementos necesarios para crear las tablas, procedimientos almacenados, funciones, vistas, triggers, cursores y datos utilizados por el sistema.

Tecnologías utilizadas
Python
Tkinter
MySQL
MySQL Workbench
mysql-connector-python
SQL
Git
GitHub
Integrantes
Kevin Montero Fernández
Danny Castro Méndez
Mariana Rodríguez Orellana
Proyecto académico

Proyecto desarrollado para el curso Lenguajes de Base de Datos, 2026.