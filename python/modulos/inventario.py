def listar_movimientos(conexion):
    try:
        producto_id = int(
            input("ID del producto, o 0 para mostrar todos: ")
        )
    except ValueError:
        print("El ID debe ser un número.")
        return

    cursor = conexion.cursor()

    try:
        cursor.callproc(
            "sp_inventario_listar",
            [producto_id]
        )

        for resultado in cursor.stored_results():
            movimientos = resultado.fetchall()

            print("\n--- Movimientos de inventario ---")

            if not movimientos:
                print("No hay movimientos registrados.")
                return

            for movimiento in movimientos:
                print(
                    f"ID: {movimiento[0]} | "
                    f"Producto: {movimiento[2]} | "
                    f"Tipo: {movimiento[3]} | "
                    f"Cantidad: {movimiento[4]} | "
                    f"Fecha: {movimiento[5]} | "
                    f"Observación: {movimiento[6] or 'Sin observación'}"
                )

    except Exception as error:
        print(f"Error al listar movimientos: {error}")

    finally:
        cursor.close()


def registrar_movimiento(conexion):
    try:
        producto_id = int(input("ID del producto: "))
        cantidad = int(input("Cantidad: "))
    except ValueError:
        print("El ID y la cantidad deben ser números.")
        return

    tipo = input("Tipo de movimiento, ENTRADA o SALIDA: ")
    observacion = input("Observación: ")

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_inventario_insertar",
            [
                producto_id,
                tipo,
                cantidad,
                observacion,
                0,
                ""
            ]
        )

        conexion.commit()

        print(resultado[5])

        if resultado[4] is not None:
            print(f"ID del movimiento registrado: {resultado[4]}")

    except Exception as error:
        conexion.rollback()
        print(f"Error al registrar el movimiento: {error}")

    finally:
        cursor.close()


def actualizar_movimiento(conexion):
    try:
        movimiento_id = int(input("ID del movimiento: "))
        producto_id = int(input("ID del producto: "))
        cantidad = int(input("Nueva cantidad: "))
    except ValueError:
        print("Los identificadores y la cantidad deben ser números.")
        return

    tipo = input("Nuevo tipo, ENTRADA o SALIDA: ")
    observacion = input("Nueva observación: ")

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_inventario_actualizar",
            [
                movimiento_id,
                producto_id,
                tipo,
                cantidad,
                observacion,
                ""
            ]
        )

        conexion.commit()
        print(resultado[5])

    except Exception as error:
        conexion.rollback()
        print(f"Error al actualizar el movimiento: {error}")

    finally:
        cursor.close()


def eliminar_movimiento(conexion):
    try:
        movimiento_id = int(input("ID del movimiento: "))
    except ValueError:
        print("El ID debe ser un número.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_inventario_eliminar",
            [movimiento_id, ""]
        )

        conexion.commit()
        print(resultado[1])

    except Exception as error:
        conexion.rollback()
        print(f"Error al eliminar el movimiento: {error}")

    finally:
        cursor.close()