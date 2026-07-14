def listar_productos(conexion):
    cursor = conexion.cursor()

    try:
        cursor.callproc("sp_productos_listar")

        for resultado in cursor.stored_results():
            productos = resultado.fetchall()

            print("\n--- Productos registrados ---")

            for producto in productos:
                print(
                    f"ID: {producto[0]} | "
                    f"Nombre: {producto[1]} | "
                    f"Precio: ₡{producto[3]} | "
                    f"Stock: {producto[4]} | "
                    f"Stock mínimo: {producto[5]} | "
                    f"Categoría: {producto[6]} | "
                    f"Proveedor: {producto[7]}"
                )

    except Exception as error:
        print(f"Error al listar productos: {error}")

    finally:
        cursor.close()


def registrar_producto(conexion):
    try:
        nombre = input("Nombre del producto: ")
        descripcion = input("Descripción: ")
        precio = float(input("Precio en colones: "))
        stock = int(input("Stock inicial: "))
        stock_minimo = int(input("Stock mínimo: "))
        categoria_id = int(input("ID de la categoría: "))
        proveedor_id = int(input("ID del proveedor: "))

    except ValueError:
        print("Precio, stock e identificadores deben ser números.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_productos_insertar",
            [
                nombre,
                descripcion,
                precio,
                stock,
                stock_minimo,
                categoria_id,
                proveedor_id,
                0,
                ""
            ]
        )

        conexion.commit()

        print(resultado[8])

        if resultado[7] is not None:
            print(f"ID del producto registrado: {resultado[7]}")

    except Exception as error:
        conexion.rollback()
        print(f"Error al registrar el producto: {error}")

    finally:
        cursor.close()


def actualizar_producto(conexion):
    try:
        producto_id = int(input("ID del producto: "))
        nombre = input("Nuevo nombre: ")
        descripcion = input("Nueva descripción: ")
        precio = float(input("Nuevo precio: "))
        stock_minimo = int(input("Nuevo stock mínimo: "))
        categoria_id = int(input("ID de la categoría: "))
        proveedor_id = int(input("ID del proveedor: "))

    except ValueError:
        print("Precio e identificadores deben ser números.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_productos_actualizar",
            [
                producto_id,
                nombre,
                descripcion,
                precio,
                stock_minimo,
                categoria_id,
                proveedor_id,
                ""
            ]
        )

        conexion.commit()
        print(resultado[7])

    except Exception as error:
        conexion.rollback()
        print(f"Error al actualizar el producto: {error}")

    finally:
        cursor.close()


def eliminar_producto(conexion):
    try:
        producto_id = int(input("ID del producto: "))

    except ValueError:
        print("El ID debe ser un número.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_productos_eliminar",
            [producto_id, ""]
        )

        conexion.commit()
        print(resultado[1])

    except Exception as error:
        conexion.rollback()
        print(f"Error al eliminar el producto: {error}")

    finally:
        cursor.close()