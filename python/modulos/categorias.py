--funciones CRUD para gestionar categorías en la base de datos, todas usando stored procedures
def listar_categorias(conexion):
    cursor = conexion.cursor()

    try:
        cursor.callproc("sp_categorias_listar")

        for resultado in cursor.stored_results():
            categorias = resultado.fetchall()

            print("\n--- Categorías registradas ---")

            if not categorias:
                print("No hay categorías registradas.")
                return

            for categoria in categorias:
                print(
                    f"ID: {categoria[0]} | "
                    f"Nombre: {categoria[1]} | "
                    f"Descripción: {categoria[2] or 'Sin descripción'}"
                )

    except Exception as error:
        print(f"Error al listar categorías: {error}")

    finally:
        cursor.close()


def registrar_categoria(conexion):
    nombre = input("Nombre de la categoría: ")
    descripcion = input("Descripción: ")

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_categorias_insertar",
            [
                nombre,
                descripcion,
                0,
                ""
            ]
        )

        conexion.commit()

        print(resultado[3])

        if resultado[2] is not None:
            print(f"ID de la categoría registrada: {resultado[2]}")

    except Exception as error:
        conexion.rollback()
        print(f"Error al registrar la categoría: {error}")

    finally:
        cursor.close()


def actualizar_categoria(conexion):
    try:
        categoria_id = int(input("ID de la categoría: "))

    except ValueError:
        print("El ID debe ser un número.")
        return

    nombre = input("Nuevo nombre: ")
    descripcion = input("Nueva descripción: ")

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_categorias_actualizar",
            [
                categoria_id,
                nombre,
                descripcion,
                ""
            ]
        )

        conexion.commit()
        print(resultado[3])

    except Exception as error:
        conexion.rollback()
        print(f"Error al actualizar la categoría: {error}")

    finally:
        cursor.close()


def eliminar_categoria(conexion):
    try:
        categoria_id = int(input("ID de la categoría: "))

    except ValueError:
        print("El ID debe ser un número.")
        return

    cursor = conexion.cursor()

    try:
        resultado = cursor.callproc(
            "sp_categorias_eliminar",
            [
                categoria_id,
                ""
            ]
        )

        conexion.commit()
        print(resultado[1])

    except Exception as error:
        conexion.rollback()
        print(f"Error al eliminar la categoría: {error}")

    finally:
        cursor.close()
