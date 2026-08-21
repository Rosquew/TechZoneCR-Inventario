def listar_ventas(conexion):
    cursor = conexion.cursor()

    try:
        cursor.callproc("sp_ventas_listar")

        for resultado in cursor.stored_results():
            ventas = resultado.fetchall()

            print("\n--- Ventas registradas ---")

            if not ventas:
                print("No hay ventas registradas.")
                return

            for venta in ventas:
                print(
                    f"ID: {venta[0]} | "
                    f"Fecha: {venta[1]} | "
                    f"Cliente: {venta[3]} | "
                    f"Productos: {venta[4]} | "
                    f"Total: ₡{venta[5]:,.2f}"
                )

    except Exception as error:
        print(f"Error al listar las ventas: {error}")

    finally:
        cursor.close()


def registrar_venta(conexion):
    try:
        cliente_id = int(input("ID de cliente: "))

    except ValueError:
        print("El ID del cliente debe ser un número.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_ventas_insertar",
            [
                cliente_id,
                None,
                0,
                ""
            ]
        )

        conexion.commit()

        print(resultado[3])

        if resultado[2] is not None:
            print(f"ID de la venta registrada: {resultado[2]}")

    except Exception as error:
        conexion.rollback()
        print(f"Error al registrar la venta: {error}")

    finally:
        cursor.close()


def actualizar_venta(conexion):
    try:
        venta_id = int(input("ID de la venta: "))
        cliente_id = int(input("Nuevo ID del cliente: "))

    except ValueError:
        print("Los identificadores deben ser números.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_ventas_actualizar",
            [
                venta_id,
                cliente_id,
                None,
                ""
            ]
        )

        conexion.commit()
        print(resultado[3])

    except Exception as error:
        conexion.rollback()
        print(f"Error al actualizar la venta: {error}")

    finally:
        cursor.close()


def eliminar_venta(conexion):
    try:
        venta_id = int(input("ID de la venta: "))

    except ValueError:
        print("El ID debe ser un número.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_ventas_eliminar",
            [
                venta_id,
                ""
            ]
        )

        conexion.commit()
        print(resultado[1])

    except Exception as error:
        conexion.rollback()
        print(f"Error al eliminar la venta: {error}")

    finally:
        cursor.close()


def agregar_producto_venta(conexion):
    try:
        venta_id = int(input("ID de la venta: "))
        producto_id = int(input("ID del producto: "))
        cantidad = int(input("Cantidad: "))

    except ValueError:
        print("Los identificadores y la cantidad deben ser números.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_detalle_venta_insertar",
            [
                venta_id,
                producto_id,
                cantidad,
                0,
                ""
            ]
        )

        conexion.commit()

        print(resultado[4])

        if resultado[3] is not None:
            print(f"ID del detalle registrado: {resultado[3]}")

    except Exception as error:
        conexion.rollback()
        print(f"Error al agregar el producto: {error}")

    finally:
        cursor.close()


def listar_detalles_venta(conexion):
    try:
        venta_id = int(
            input("ID de la venta, o 0 para mostrar todas: ")
        )

    except ValueError:
        print("El ID debe ser un número.")
        return

    cursor = conexion.cursor()

    try:
        cursor.callproc(
            "sp_detalle_venta_listar",
            [venta_id]
        )

        for resultado in cursor.stored_results():
            detalles = resultado.fetchall()

            print("\n--- Detalles de ventas ---")

            if not detalles:
                print("No hay detalles registrados.")
                return

            for detalle in detalles:
                print(
                    f"Detalle: {detalle[0]} | "
                    f"Venta: {detalle[1]} | "
                    f"Producto: {detalle[3]} | "
                    f"Cantidad: {detalle[4]} | "
                    f"Precio: ₡{detalle[5]:,.2f} | "
                    f"Subtotal: ₡{detalle[6]:,.2f}"
                )

    except Exception as error:
        print(f"Error al listar los detalles: {error}")

    finally:
        cursor.close()


def actualizar_detalle_venta(conexion):
    try:
        detalle_id = int(input("ID del detalle: "))
        producto_id = int(input("Nuevo ID del producto: "))
        cantidad = int(input("Nueva cantidad: "))

    except ValueError:
        print("Los identificadores y la cantidad deben ser números.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_detalle_venta_actualizar",
            [
                detalle_id,
                producto_id,
                cantidad,
                ""
            ]
        )

        conexion.commit()
        print(resultado[3])

    except Exception as error:
        conexion.rollback()
        print(f"Error al actualizar el detalle: {error}")

    finally:
        cursor.close()


def eliminar_detalle_venta(conexion):
    try:
        detalle_id = int(input("ID del detalle: "))

    except ValueError:
        print("El ID debe ser un número.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_detalle_venta_eliminar",
            [
                detalle_id,
                ""
            ]
        )

        conexion.commit()
        print(resultado[1])

    except Exception as error:
        conexion.rollback()
        print(f"Error al eliminar el detalle: {error}")

    finally:
        cursor.close()
