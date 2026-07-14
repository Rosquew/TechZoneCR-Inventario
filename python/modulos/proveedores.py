def listar_proveedores(conexion):
    cursor = conexion.cursor()

    try:
        cursor.callproc("sp_proveedores_listar")

        for resultado in cursor.stored_results():
            proveedores = resultado.fetchall()

            print("\n--- Proveedores registrados ---")

            for proveedor in proveedores:
                print(
                    f"ID: {proveedor[0]} | "
                    f"Nombre: {proveedor[1]} | "
                    f"Teléfono: {proveedor[2] or 'Sin teléfono'} | "
                    f"Correo: {proveedor[3] or 'Sin correo'} | "
                    f"Dirección: {proveedor[4] or 'Sin dirección'}"
                )

    except Exception as error:
        print(f"Error al listar proveedores: {error}")

    finally:
        cursor.close()


def registrar_proveedor(conexion):
    nombre = input("Nombre del proveedor: ")
    telefono = input("Teléfono: ")
    correo = input("Correo: ")
    direccion = input("Dirección: ")

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_proveedores_insertar",
            [nombre, telefono, correo, direccion, 0, ""]
        )

        conexion.commit()
        print(resultado[5])

    except Exception as error:
        conexion.rollback()
        print(f"Error al registrar el proveedor: {error}")

    finally:
        cursor.close()


def actualizar_proveedor(conexion):
    try:
        proveedor_id = int(input("ID del proveedor: "))
    except ValueError:
        print("El ID debe ser un número.")
        return

    nombre = input("Nuevo nombre: ")
    telefono = input("Nuevo teléfono: ")
    correo = input("Nuevo correo: ")
    direccion = input("Nueva dirección: ")

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_proveedores_actualizar",
            [
                proveedor_id,
                nombre,
                telefono,
                correo,
                direccion,
                ""
            ]
        )

        conexion.commit()
        print(resultado[5])

    except Exception as error:
        conexion.rollback()
        print(f"Error al actualizar el proveedor: {error}")

    finally:
        cursor.close()


def eliminar_proveedor(conexion):
    try:
        proveedor_id = int(input("ID del proveedor: "))
    except ValueError:
        print("El ID debe ser un número.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_proveedores_eliminar",
            [proveedor_id, ""]
        )

        conexion.commit()
        print(resultado[1])

    except Exception as error:
        conexion.rollback()
        print(f"Error al eliminar el proveedor: {error}")

    finally:
        cursor.close()