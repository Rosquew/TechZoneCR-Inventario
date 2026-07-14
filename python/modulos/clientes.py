def listar_clientes(conexion):
    cursor = conexion.cursor()

    try:
        cursor.callproc("sp_clientes_listar")

        for resultado in cursor.stored_results():
            clientes = resultado.fetchall()

            print("\n--- Clientes registrados ---")

            for cliente in clientes:
                print(
                    f"ID: {cliente[0]} | "
                    f"Nombre: {cliente[1]} | "
                    f"Correo: {cliente[2] or 'Sin correo'} | "
                    f"Teléfono: {cliente[3] or 'Sin teléfono'}"
                )

    except Exception as error:
        print(f"Error al listar clientes: {error}")

    finally:
        cursor.close()


def registrar_cliente(conexion):
    nombre = input("Nombre del cliente: ")
    correo = input("Correo: ")
    telefono = input("Teléfono: ")

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_clientes_insertar",
            [nombre, correo, telefono, 0, ""]
        )

        conexion.commit()

        print(resultado[4])

        if resultado[3] is not None:
            print(f"ID del cliente registrado: {resultado[3]}")

    except Exception as error:
        conexion.rollback()
        print(f"Error al registrar el cliente: {error}")

    finally:
        cursor.close()


def actualizar_cliente(conexion):
    try:
        cliente_id = int(input("ID del cliente: "))
    except ValueError:
        print("El ID debe ser un número.")
        return

    nombre = input("Nuevo nombre: ")
    correo = input("Nuevo correo: ")
    telefono = input("Nuevo teléfono: ")

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_clientes_actualizar",
            [cliente_id, nombre, correo, telefono, ""]
        )

        conexion.commit()
        print(resultado[4])

    except Exception as error:
        conexion.rollback()
        print(f"Error al actualizar el cliente: {error}")

    finally:
        cursor.close()


def eliminar_cliente(conexion):
    try:
        cliente_id = int(input("ID del cliente: "))
    except ValueError:
        print("El ID debe ser un número.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_clientes_eliminar",
            [cliente_id, ""]
        )

        conexion.commit()
        print(resultado[1])

    except Exception as error:
        conexion.rollback()
        print(f"Error al eliminar el cliente: {error}")

    finally:
        cursor.close()