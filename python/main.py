from db.conexion import obtener_conexion

from modulos.categorias import (
    listar_categorias,
    registrar_categoria,
    actualizar_categoria,
    eliminar_categoria
)

from modulos.proveedores import (
    listar_proveedores,
    registrar_proveedor,
    actualizar_proveedor,
    eliminar_proveedor
)

from modulos.productos import (
    listar_productos,
    registrar_producto,
    actualizar_producto,
    eliminar_producto
)

from modulos.clientes import (
    listar_clientes,
    registrar_cliente,
    actualizar_cliente,
    eliminar_cliente
)

from modulos.ventas import (
    listar_ventas,
    registrar_venta,
    actualizar_venta,
    eliminar_venta,
    agregar_producto_venta,
    listar_detalles_venta,
    actualizar_detalle_venta,
    eliminar_detalle_venta
)

from modulos.inventario import (
    listar_movimientos,
    registrar_movimiento,
    actualizar_movimiento,
    eliminar_movimiento
)

from modulos.reportes import (
    reporte_productos,
    reporte_catalogos,
    reporte_ventas,
    reporte_inventario,
    reporte_general
)


def menu_categorias(conexion):
    while True:
        print("\n--- Gestión de categorías ---")
        print("1. Listar categorías")
        print("2. Registrar categoría")
        print("3. Actualizar categoría")
        print("4. Eliminar categoría")
        print("0. Volver al menú principal")

        opcion = input("Seleccione una opción: ")

        if opcion == "1":
            listar_categorias(conexion)
        elif opcion == "2":
            registrar_categoria(conexion)
        elif opcion == "3":
            actualizar_categoria(conexion)
        elif opcion == "4":
            eliminar_categoria(conexion)
        elif opcion == "0":
            break
        else:
            print("Opción no válida.")


def menu_proveedores(conexion):
    while True:
        print("\n--- Gestión de proveedores ---")
        print("1. Listar proveedores")
        print("2. Registrar proveedor")
        print("3. Actualizar proveedor")
        print("4. Eliminar proveedor")
        print("0. Volver al menú principal")

        opcion = input("Seleccione una opción: ")

        if opcion == "1":
            listar_proveedores(conexion)
        elif opcion == "2":
            registrar_proveedor(conexion)
        elif opcion == "3":
            actualizar_proveedor(conexion)
        elif opcion == "4":
            eliminar_proveedor(conexion)
        elif opcion == "0":
            break
        else:
            print("Opción no válida.")


def menu_productos(conexion):
    while True:
        print("\n--- Gestión de productos ---")
        print("1. Listar productos")
        print("2. Registrar producto")
        print("3. Actualizar producto")
        print("4. Eliminar producto")
        print("0. Volver al menú principal")

        opcion = input("Seleccione una opción: ")

        if opcion == "1":
            listar_productos(conexion)
        elif opcion == "2":
            registrar_producto(conexion)
        elif opcion == "3":
            actualizar_producto(conexion)
        elif opcion == "4":
            eliminar_producto(conexion)
        elif opcion == "0":
            break
        else:
            print("Opción no válida.")


def menu_clientes(conexion):
    while True:
        print("\n--- Gestión de clientes ---")
        print("1. Listar clientes")
        print("2. Registrar cliente")
        print("3. Actualizar cliente")
        print("4. Eliminar cliente")
        print("0. Volver al menú principal")

        opcion = input("Seleccione una opción: ")

        if opcion == "1":
            listar_clientes(conexion)
        elif opcion == "2":
            registrar_cliente(conexion)
        elif opcion == "3":
            actualizar_cliente(conexion)
        elif opcion == "4":
            eliminar_cliente(conexion)
        elif opcion == "0":
            break
        else:
            print("Opción no válida.")


def menu_ventas(conexion):
    while True:
        print("\n--- Gestión de ventas ---")
        print("1. Listar ventas")
        print("2. Registrar venta")
        print("3. Actualizar venta")
        print("4. Eliminar venta")
        print("5. Agregar producto a una venta")
        print("6. Listar detalles de ventas")
        print("7. Actualizar detalle de una venta")
        print("8. Eliminar detalle de una venta")
        print("0. Volver al menú principal")

        opcion = input("Seleccione una opción: ")

        if opcion == "1":
            listar_ventas(conexion)
        elif opcion == "2":
            registrar_venta(conexion)
        elif opcion == "3":
            actualizar_venta(conexion)
        elif opcion == "4":
            eliminar_venta(conexion)
        elif opcion == "5":
            agregar_producto_venta(conexion)
        elif opcion == "6":
            listar_detalles_venta(conexion)
        elif opcion == "7":
            actualizar_detalle_venta(conexion)
        elif opcion == "8":
            eliminar_detalle_venta(conexion)
        elif opcion == "0":
            break
        else:
            print("Opción no válida.")


def menu_inventario(conexion):
    while True:
        print("\n--- Gestión de inventario ---")
        print("1. Listar movimientos")
        print("2. Registrar movimiento")
        print("3. Actualizar movimiento")
        print("4. Eliminar movimiento")
        print("0. Volver al menú principal")

        opcion = input("Seleccione una opción: ")

        if opcion == "1":
            listar_movimientos(conexion)
        elif opcion == "2":
            registrar_movimiento(conexion)
        elif opcion == "3":
            actualizar_movimiento(conexion)
        elif opcion == "4":
            eliminar_movimiento(conexion)
        elif opcion == "0":
            break
        else:
            print("Opción no válida.")


def menu_reportes(conexion):
    while True:
        print("\n--- Reportes ---")
        print("1. Reporte de productos")
        print("2. Reporte de categorías y proveedores")
        print("3. Reporte de ventas")
        print("4. Reporte de inventario")
        print("5. Reporte general")
        print("0. Volver al menú principal")

        opcion = input("Seleccione una opción: ")

        if opcion == "1":
            reporte_productos(conexion)
        elif opcion == "2":
            reporte_catalogos(conexion)
        elif opcion == "3":
            reporte_ventas(conexion)
        elif opcion == "4":
            reporte_inventario(conexion)
        elif opcion == "5":
            reporte_general(conexion)
        elif opcion == "0":
            break
        else:
            print("Opción no válida.")


def main():
    conexion = obtener_conexion()

    if conexion is None:
        print("No fue posible conectar con la base de datos.")
        return

    print("Conexión realizada correctamente con TechZone CR.")

    try:
        while True:
            print("\n=== TechZone CR ===")
            print("1. Gestión de categorías")
            print("2. Gestión de proveedores")
            print("3. Gestión de productos")
            print("4. Gestión de clientes")
            print("5. Gestión de ventas")
            print("6. Gestión de inventario")
            print("7. Reportes")
            print("0. Salir")

            opcion = input("Seleccione una opción: ")

            if opcion == "1":
                menu_categorias(conexion)
            elif opcion == "2":
                menu_proveedores(conexion)
            elif opcion == "3":
                menu_productos(conexion)
            elif opcion == "4":
                menu_clientes(conexion)
            elif opcion == "5":
                menu_ventas(conexion)
            elif opcion == "6":
                menu_inventario(conexion)
            elif opcion == "7":
                menu_reportes(conexion)
            elif opcion == "0":
                print("Sistema finalizado.")
                break
            else:
                print("Opción no válida.")

    finally:
        conexion.close()


if __name__ == "__main__":
    main()