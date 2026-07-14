def ejecutar_reporte(conexion, procedimiento, titulo):
    cursor = conexion.cursor()

    try:
        cursor.callproc(procedimiento)

        print(f"\n--- {titulo} ---")

        numero_resultado = 1
        encontro_datos = False

        for resultado in cursor.stored_results():
            columnas = resultado.column_names
            filas = resultado.fetchall()

            if filas:
                encontro_datos = True

                print(f"\nResultado {numero_resultado}")

                for fila in filas:
                    datos = []

                    for posicion in range(len(columnas)):
                        datos.append(
                            f"{columnas[posicion]}: {fila[posicion]}"
                        )

                    print(" | ".join(datos))

                numero_resultado += 1

        if not encontro_datos:
            print("No se encontraron datos para este reporte.")

    except Exception as error:
        print(f"Error al generar el reporte: {error}")

    finally:
        cursor.close()


def reporte_productos(conexion):
    ejecutar_reporte(
        conexion,
        "sp_reporte_productos",
        "Reporte de productos"
    )


def reporte_catalogos(conexion):
    ejecutar_reporte(
        conexion,
        "sp_reporte_catalogos",
        "Reporte de categorías y proveedores"
    )


def reporte_ventas(conexion):
    ejecutar_reporte(
        conexion,
        "sp_reporte_ventas",
        "Reporte de ventas"
    )


def reporte_inventario(conexion):
    ejecutar_reporte(
        conexion,
        "sp_reporte_inventario",
        "Reporte de inventario"
    )


def reporte_general(conexion):
    ejecutar_reporte(
        conexion,
        "sp_reporte_general",
        "Reporte general de TechZone CR"
    )