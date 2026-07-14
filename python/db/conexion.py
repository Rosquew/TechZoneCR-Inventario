import mysql.connector
from mysql.connector import Error

from config import DB_CONFIG


def obtener_conexion():
    try:
        conexion = mysql.connector.connect(**DB_CONFIG)

        if conexion.is_connected():
            return conexion

    except Error as error:
        print(f"Error al conectar con MySQL: {error}")

    return None