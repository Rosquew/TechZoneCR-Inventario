import tkinter as tk
from tkinter import ttk, messagebox
from datetime import datetime

from db.conexion import obtener_conexion


class AplicacionTechZone:

    def __init__(self, ventana):
        self.ventana = ventana
        self.ventana.title("TechZone CR - Sistema de Inventario")
        self.ventana.geometry("650x550")
        self.ventana.resizable(False, False)

        self.conexion = obtener_conexion()

        if self.conexion is None:
            messagebox.showerror(
                "Error",
                "No fue posible conectar con la base de datos."
            )
            self.ventana.destroy()
            return

        self.crear_menu()


    # ==================================================
    # FUNCIONES GENERALES
    # ==================================================

    def consultar(self, procedimiento, parametros=None):
        cursor = self.conexion.cursor()
        datos = []

        try:
            if parametros is None:
                cursor.callproc(procedimiento)
            else:
                cursor.callproc(procedimiento, parametros)

            for resultado in cursor.stored_results():
                datos.extend(resultado.fetchall())

            return datos

        except Exception as error:
            messagebox.showerror("Error", str(error))
            return []

        finally:
            cursor.close()


    def ejecutar(self, procedimiento, parametros):
        cursor = self.conexion.cursor()

        try:
            resultado = cursor.callproc(
                procedimiento,
                parametros
            )

            self.conexion.commit()
            return resultado

        except Exception as error:
            self.conexion.rollback()
            messagebox.showerror("Error", str(error))
            return None

        finally:
            cursor.close()


    def limpiar_tabla(self, tabla):
        for fila in tabla.get_children():
            tabla.delete(fila)


    def obtener_id_combo(self, combo):
        try:
            return int(combo.get().split(" - ")[0])
        except:
            return None


    # ==================================================
    # MENÚ PRINCIPAL
    # ==================================================

    def crear_menu(self):

        tk.Label(
            self.ventana,
            text="TechZone CR",
            font=("Arial", 24, "bold")
        ).pack(pady=(30, 5))

        tk.Label(
            self.ventana,
            text="Sistema de Gestión de Inventario",
            font=("Arial", 13)
        ).pack(pady=(0, 25))

        marco = ttk.Frame(self.ventana)
        marco.pack()

        opciones = [
            ("Gestión de Categorías", self.ventana_categorias),
            ("Gestión de Proveedores", self.ventana_proveedores),
            ("Gestión de Productos", self.ventana_productos),
            ("Gestión de Clientes", self.ventana_clientes),
            ("Gestión de Ventas", self.ventana_ventas),
            ("Gestión de Inventario", self.ventana_inventario),
            ("Reportes", self.ventana_reportes)
        ]

        for i, opcion in enumerate(opciones):
            ttk.Button(
                marco,
                text=opcion[0],
                width=35,
                command=opcion[1]
            ).grid(row=i, column=0, pady=8)

        ttk.Button(
            marco,
            text="Salir",
            width=35,
            command=self.cerrar
        ).grid(row=7, column=0, pady=(25, 8))

        tk.Label(
            self.ventana,
            text="Conexión realizada correctamente con MySQL"
        ).pack(pady=15)


    # ==================================================
    # CATEGORÍAS
    # ==================================================

    def ventana_categorias(self):

        ventana = tk.Toplevel(self.ventana)
        ventana.title("Gestión de Categorías")
        ventana.geometry("700x500")

        tk.Label(
            ventana,
            text="Gestión de Categorías",
            font=("Arial", 18, "bold")
        ).pack(pady=15)

        formulario = ttk.Frame(ventana)
        formulario.pack()

        ttk.Label(
            formulario,
            text="Nombre:"
        ).grid(row=0, column=0, padx=5, pady=5)

        nombre = ttk.Entry(
            formulario,
            width=35
        )
        nombre.grid(row=0, column=1, padx=5, pady=5)

        ttk.Label(
            formulario,
            text="Descripción:"
        ).grid(row=1, column=0, padx=5, pady=5)

        descripcion = ttk.Entry(
            formulario,
            width=35
        )
        descripcion.grid(row=1, column=1, padx=5, pady=5)

        tabla = ttk.Treeview(
            ventana,
            columns=("id", "nombre", "descripcion"),
            show="headings",
            height=11
        )

        tabla.heading("id", text="ID")
        tabla.heading("nombre", text="Nombre")
        tabla.heading("descripcion", text="Descripción")

        tabla.column("id", width=60)
        tabla.column("nombre", width=180)
        tabla.column("descripcion", width=350)

        tabla.pack(pady=15)


        def cargar():
            self.limpiar_tabla(tabla)

            datos = self.consultar(
                "sp_categorias_listar"
            )

            for fila in datos:
                tabla.insert(
                    "",
                    tk.END,
                    values=fila
                )


        def limpiar():
            nombre.delete(0, tk.END)
            descripcion.delete(0, tk.END)


        def seleccionar(evento):
            seleccion = tabla.selection()

            if not seleccion:
                return

            datos = tabla.item(
                seleccion[0],
                "values"
            )

            limpiar()

            nombre.insert(0, datos[1])
            descripcion.insert(0, datos[2])


        def registrar():

            if nombre.get() == "":
                messagebox.showwarning(
                    "Aviso",
                    "Ingrese el nombre."
                )
                return

            resultado = self.ejecutar(
                "sp_categorias_insertar",
                [
                    nombre.get(),
                    descripcion.get(),
                    0,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[3]
                )

                limpiar()
                cargar()


        def actualizar():

            seleccion = tabla.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione una categoría."
                )
                return

            categoria_id = int(
                tabla.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_categorias_actualizar",
                [
                    categoria_id,
                    nombre.get(),
                    descripcion.get(),
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[3]
                )

                limpiar()
                cargar()


        def eliminar():

            seleccion = tabla.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione una categoría."
                )
                return

            categoria_id = int(
                tabla.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_categorias_eliminar",
                [
                    categoria_id,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[1]
                )

                limpiar()
                cargar()


        tabla.bind(
            "<<TreeviewSelect>>",
            seleccionar
        )

        botones = ttk.Frame(ventana)
        botones.pack()

        ttk.Button(
            botones,
            text="Registrar",
            command=registrar
        ).grid(row=0, column=0, padx=5)

        ttk.Button(
            botones,
            text="Actualizar",
            command=actualizar
        ).grid(row=0, column=1, padx=5)

        ttk.Button(
            botones,
            text="Eliminar",
            command=eliminar
        ).grid(row=0, column=2, padx=5)

        ttk.Button(
            botones,
            text="Limpiar",
            command=limpiar
        ).grid(row=0, column=3, padx=5)

        cargar()


    # ==================================================
    # PROVEEDORES
    # ==================================================

    def ventana_proveedores(self):

        ventana = tk.Toplevel(self.ventana)
        ventana.title("Gestión de Proveedores")
        ventana.geometry("850x550")

        tk.Label(
            ventana,
            text="Gestión de Proveedores",
            font=("Arial", 18, "bold")
        ).pack(pady=15)

        formulario = ttk.Frame(ventana)
        formulario.pack()

        campos = [
            "Nombre",
            "Teléfono",
            "Correo",
            "Dirección"
        ]

        entradas = []

        for i, texto in enumerate(campos):

            ttk.Label(
                formulario,
                text=texto + ":"
            ).grid(row=i, column=0, padx=5, pady=4)

            entrada = ttk.Entry(
                formulario,
                width=35
            )

            entrada.grid(
                row=i,
                column=1,
                padx=5,
                pady=4
            )

            entradas.append(entrada)

        tabla = ttk.Treeview(
            ventana,
            columns=(
                "id",
                "nombre",
                "telefono",
                "correo",
                "direccion"
            ),
            show="headings",
            height=9
        )

        columnas = [
            ("id", "ID", 50),
            ("nombre", "Nombre", 150),
            ("telefono", "Teléfono", 110),
            ("correo", "Correo", 200),
            ("direccion", "Dirección", 250)
        ]

        for codigo, titulo, ancho in columnas:
            tabla.heading(codigo, text=titulo)
            tabla.column(codigo, width=ancho)

        tabla.pack(pady=15)


        def cargar():
            self.limpiar_tabla(tabla)

            for fila in self.consultar(
                "sp_proveedores_listar"
            ):
                tabla.insert(
                    "",
                    tk.END,
                    values=fila
                )


        def limpiar():
            for entrada in entradas:
                entrada.delete(0, tk.END)


        def seleccionar(evento):

            seleccion = tabla.selection()

            if not seleccion:
                return

            datos = tabla.item(
                seleccion[0],
                "values"
            )

            limpiar()

            for i in range(4):
                entradas[i].insert(
                    0,
                    datos[i + 1]
                )


        def registrar():

            if entradas[0].get() == "":
                messagebox.showwarning(
                    "Aviso",
                    "Ingrese el nombre."
                )
                return

            resultado = self.ejecutar(
                "sp_proveedores_insertar",
                [
                    entradas[0].get(),
                    entradas[1].get(),
                    entradas[2].get(),
                    entradas[3].get(),
                    0,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[5]
                )

                limpiar()
                cargar()


        def actualizar():

            seleccion = tabla.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un proveedor."
                )
                return

            proveedor_id = int(
                tabla.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_proveedores_actualizar",
                [
                    proveedor_id,
                    entradas[0].get(),
                    entradas[1].get(),
                    entradas[2].get(),
                    entradas[3].get(),
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[5]
                )

                limpiar()
                cargar()


        def eliminar():

            seleccion = tabla.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un proveedor."
                )
                return

            proveedor_id = int(
                tabla.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_proveedores_eliminar",
                [
                    proveedor_id,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[1]
                )

                limpiar()
                cargar()


        tabla.bind(
            "<<TreeviewSelect>>",
            seleccionar
        )

        botones = ttk.Frame(ventana)
        botones.pack()

        ttk.Button(
            botones,
            text="Registrar",
            command=registrar
        ).grid(row=0, column=0, padx=5)

        ttk.Button(
            botones,
            text="Actualizar",
            command=actualizar
        ).grid(row=0, column=1, padx=5)

        ttk.Button(
            botones,
            text="Eliminar",
            command=eliminar
        ).grid(row=0, column=2, padx=5)

        ttk.Button(
            botones,
            text="Limpiar",
            command=limpiar
        ).grid(row=0, column=3, padx=5)

        cargar()


    # ==================================================
    # PRODUCTOS
    # ==================================================

    def ventana_productos(self):

        ventana = tk.Toplevel(self.ventana)
        ventana.title("Gestión de Productos")
        ventana.geometry("1100x650")

        tk.Label(
            ventana,
            text="Gestión de Productos",
            font=("Arial", 18, "bold")
        ).pack(pady=15)

        formulario = ttk.Frame(ventana)
        formulario.pack()

        campos = [
            "Nombre",
            "Descripción",
            "Precio",
            "Stock inicial",
            "Stock mínimo"
        ]

        entradas = []

        for i, texto in enumerate(campos):

            ttk.Label(
                formulario,
                text=texto + ":"
            ).grid(row=i, column=0, padx=5, pady=4)

            entrada = ttk.Entry(
                formulario,
                width=30
            )

            entrada.grid(
                row=i,
                column=1,
                padx=5,
                pady=4
            )

            entradas.append(entrada)

        ttk.Label(
            formulario,
            text="Categoría:"
        ).grid(
            row=0,
            column=2,
            padx=10
        )

        categoria = ttk.Combobox(
            formulario,
            width=30,
            state="readonly"
        )

        categoria.grid(
            row=0,
            column=3
        )

        ttk.Label(
            formulario,
            text="Proveedor:"
        ).grid(
            row=1,
            column=2,
            padx=10
        )

        proveedor = ttk.Combobox(
            formulario,
            width=30,
            state="readonly"
        )

        proveedor.grid(
            row=1,
            column=3
        )

        tabla = ttk.Treeview(
            ventana,
            columns=(
                "id",
                "nombre",
                "descripcion",
                "precio",
                "stock",
                "minimo",
                "categoria",
                "proveedor"
            ),
            show="headings",
            height=12
        )

        columnas = [
            ("id", "ID", 40),
            ("nombre", "Nombre", 150),
            ("descripcion", "Descripción", 180),
            ("precio", "Precio", 90),
            ("stock", "Stock", 60),
            ("minimo", "Mínimo", 70),
            ("categoria", "Categoría", 130),
            ("proveedor", "Proveedor", 160)
        ]

        for codigo, titulo, ancho in columnas:
            tabla.heading(codigo, text=titulo)
            tabla.column(codigo, width=ancho)

        tabla.pack(pady=15)


        def cargar_catalogos():

            categorias = self.consultar(
                "sp_categorias_listar"
            )

            proveedores = self.consultar(
                "sp_proveedores_listar"
            )

            categoria["values"] = [
                f"{fila[0]} - {fila[1]}"
                for fila in categorias
            ]

            proveedor["values"] = [
                f"{fila[0]} - {fila[1]}"
                for fila in proveedores
            ]


        def cargar():

            self.limpiar_tabla(tabla)

            for fila in self.consultar(
                "sp_productos_listar"
            ):
                tabla.insert(
                    "",
                    tk.END,
                    values=fila
                )


        def limpiar():

            for entrada in entradas:
                entrada.delete(0, tk.END)

            categoria.set("")
            proveedor.set("")


        def seleccionar(evento):

            seleccion = tabla.selection()

            if not seleccion:
                return

            datos = tabla.item(
                seleccion[0],
                "values"
            )

            limpiar()

            for i in range(5):
                entradas[i].insert(
                    0,
                    datos[i + 1]
                )

            for valor in categoria["values"]:
                if valor.split(" - ", 1)[1] == datos[6]:
                    categoria.set(valor)
                    break

            for valor in proveedor["values"]:
                if valor.split(" - ", 1)[1] == datos[7]:
                    proveedor.set(valor)
                    break


        def registrar():

            try:
                precio = float(
                    entradas[2].get()
                )

                stock = int(
                    entradas[3].get()
                )

                minimo = int(
                    entradas[4].get()
                )

                categoria_id = self.obtener_id_combo(
                    categoria
                )

                proveedor_id = self.obtener_id_combo(
                    proveedor
                )

                if categoria_id is None:
                    raise ValueError

                if proveedor_id is None:
                    raise ValueError

            except ValueError:
                messagebox.showwarning(
                    "Aviso",
                    "Revise los datos ingresados."
                )
                return

            resultado = self.ejecutar(
                "sp_productos_insertar",
                [
                    entradas[0].get(),
                    entradas[1].get(),
                    precio,
                    stock,
                    minimo,
                    categoria_id,
                    proveedor_id,
                    0,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[8]
                )

                limpiar()
                cargar()


        def actualizar():

            seleccion = tabla.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un producto."
                )
                return

            try:
                producto_id = int(
                    tabla.item(
                        seleccion[0],
                        "values"
                    )[0]
                )

                precio = float(
                    entradas[2].get()
                )

                minimo = int(
                    entradas[4].get()
                )

                categoria_id = self.obtener_id_combo(
                    categoria
                )

                proveedor_id = self.obtener_id_combo(
                    proveedor
                )

                if categoria_id is None:
                    raise ValueError

                if proveedor_id is None:
                    raise ValueError

            except ValueError:
                messagebox.showwarning(
                    "Aviso",
                    "Revise los datos."
                )
                return

            resultado = self.ejecutar(
                "sp_productos_actualizar",
                [
                    producto_id,
                    entradas[0].get(),
                    entradas[1].get(),
                    precio,
                    minimo,
                    categoria_id,
                    proveedor_id,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[7]
                )

                cargar()


        def eliminar():

            seleccion = tabla.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un producto."
                )
                return

            producto_id = int(
                tabla.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_productos_eliminar",
                [
                    producto_id,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[1]
                )

                limpiar()
                cargar()


        tabla.bind(
            "<<TreeviewSelect>>",
            seleccionar
        )

        botones = ttk.Frame(ventana)
        botones.pack()

        ttk.Button(
            botones,
            text="Registrar",
            command=registrar
        ).grid(row=0, column=0, padx=5)

        ttk.Button(
            botones,
            text="Actualizar",
            command=actualizar
        ).grid(row=0, column=1, padx=5)

        ttk.Button(
            botones,
            text="Eliminar",
            command=eliminar
        ).grid(row=0, column=2, padx=5)

        ttk.Button(
            botones,
            text="Limpiar",
            command=limpiar
        ).grid(row=0, column=3, padx=5)

        cargar_catalogos()
        cargar()


    # ==================================================
    # CLIENTES
    # ==================================================

    def ventana_clientes(self):

        ventana = tk.Toplevel(self.ventana)
        ventana.title("Gestión de Clientes")
        ventana.geometry("750x500")

        tk.Label(
            ventana,
            text="Gestión de Clientes",
            font=("Arial", 18, "bold")
        ).pack(pady=15)

        formulario = ttk.Frame(ventana)
        formulario.pack()

        campos = [
            "Nombre",
            "Correo",
            "Teléfono"
        ]

        entradas = []

        for i, texto in enumerate(campos):

            ttk.Label(
                formulario,
                text=texto + ":"
            ).grid(
                row=i,
                column=0,
                padx=5,
                pady=5
            )

            entrada = ttk.Entry(
                formulario,
                width=35
            )

            entrada.grid(
                row=i,
                column=1,
                padx=5,
                pady=5
            )

            entradas.append(entrada)

        tabla = ttk.Treeview(
            ventana,
            columns=(
                "id",
                "nombre",
                "correo",
                "telefono"
            ),
            show="headings",
            height=10
        )

        columnas = [
            ("id", "ID", 50),
            ("nombre", "Nombre", 180),
            ("correo", "Correo", 250),
            ("telefono", "Teléfono", 130)
        ]

        for codigo, titulo, ancho in columnas:
            tabla.heading(codigo, text=titulo)
            tabla.column(codigo, width=ancho)

        tabla.pack(pady=15)


        def cargar():

            self.limpiar_tabla(tabla)

            for fila in self.consultar(
                "sp_clientes_listar"
            ):
                tabla.insert(
                    "",
                    tk.END,
                    values=fila
                )


        def limpiar():

            for entrada in entradas:
                entrada.delete(0, tk.END)


        def seleccionar(evento):

            seleccion = tabla.selection()

            if not seleccion:
                return

            datos = tabla.item(
                seleccion[0],
                "values"
            )

            limpiar()

            for i in range(3):
                entradas[i].insert(
                    0,
                    datos[i + 1]
                )


        def registrar():

            resultado = self.ejecutar(
                "sp_clientes_insertar",
                [
                    entradas[0].get(),
                    entradas[1].get(),
                    entradas[2].get(),
                    0,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[4]
                )

                limpiar()
                cargar()


        def actualizar():

            seleccion = tabla.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un cliente."
                )
                return

            cliente_id = int(
                tabla.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_clientes_actualizar",
                [
                    cliente_id,
                    entradas[0].get(),
                    entradas[1].get(),
                    entradas[2].get(),
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[4]
                )

                limpiar()
                cargar()


        def eliminar():

            seleccion = tabla.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un cliente."
                )
                return

            cliente_id = int(
                tabla.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_clientes_eliminar",
                [
                    cliente_id,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[1]
                )

                limpiar()
                cargar()


        tabla.bind(
            "<<TreeviewSelect>>",
            seleccionar
        )

        botones = ttk.Frame(ventana)
        botones.pack()

        ttk.Button(
            botones,
            text="Registrar",
            command=registrar
        ).grid(row=0, column=0, padx=5)

        ttk.Button(
            botones,
            text="Actualizar",
            command=actualizar
        ).grid(row=0, column=1, padx=5)

        ttk.Button(
            botones,
            text="Eliminar",
            command=eliminar
        ).grid(row=0, column=2, padx=5)

        ttk.Button(
            botones,
            text="Limpiar",
            command=limpiar
        ).grid(row=0, column=3, padx=5)

        cargar()


    # ==================================================
    # VENTAS
    # ==================================================

    def ventana_ventas(self):

        ventana = tk.Toplevel(self.ventana)
        ventana.title("Gestión de Ventas")
        ventana.geometry("1050x720")

        tk.Label(
            ventana,
            text="Gestión de Ventas",
            font=("Arial", 18, "bold")
        ).pack(pady=10)

        # ----------------------------------------------
        # DATOS DE LA VENTA
        # ----------------------------------------------

        marco_venta = ttk.LabelFrame(
            ventana,
            text="Datos de la venta"
        )

        marco_venta.pack(
            fill="x",
            padx=15,
            pady=5
        )

        ttk.Label(
            marco_venta,
            text="Cliente:"
        ).grid(
            row=0,
            column=0,
            padx=5,
            pady=8
        )

        cliente = ttk.Combobox(
            marco_venta,
            width=30,
            state="readonly"
        )

        cliente.grid(
            row=0,
            column=1,
            padx=5
        )

        ttk.Label(
            marco_venta,
            text="Fecha:"
        ).grid(
            row=0,
            column=2,
            padx=5
        )

        fecha = ttk.Entry(
            marco_venta,
            width=22
        )

        fecha.grid(
            row=0,
            column=3,
            padx=5
        )

        fecha.insert(
            0,
            datetime.now().strftime(
                "%Y-%m-%d %H:%M:%S"
            )
        )

        botones_venta = ttk.Frame(
            marco_venta
        )

        botones_venta.grid(
            row=1,
            column=0,
            columnspan=4,
            pady=8
        )


        # ----------------------------------------------
        # TABLA DE VENTAS
        # ----------------------------------------------

        tabla_ventas = ttk.Treeview(
            ventana,
            columns=(
                "id",
                "fecha",
                "cliente_id",
                "cliente",
                "productos",
                "total"
            ),
            show="headings",
            height=7
        )

        columnas_ventas = [
            ("id", "ID", 50),
            ("fecha", "Fecha", 160),
            ("cliente_id", "Cliente ID", 80),
            ("cliente", "Cliente", 180),
            ("productos", "Productos", 100),
            ("total", "Total", 120)
        ]

        for codigo, titulo, ancho in columnas_ventas:
            tabla_ventas.heading(
                codigo,
                text=titulo
            )

            tabla_ventas.column(
                codigo,
                width=ancho
            )

        tabla_ventas.pack(pady=10)


        # ----------------------------------------------
        # DETALLE DE VENTA
        # ----------------------------------------------

        marco_detalle = ttk.LabelFrame(
            ventana,
            text="Productos de la venta"
        )

        marco_detalle.pack(
            fill="x",
            padx=15,
            pady=5
        )

        ttk.Label(
            marco_detalle,
            text="Producto:"
        ).grid(
            row=0,
            column=0,
            padx=5,
            pady=8
        )

        producto = ttk.Combobox(
            marco_detalle,
            width=30,
            state="readonly"
        )

        producto.grid(
            row=0,
            column=1,
            padx=5
        )

        ttk.Label(
            marco_detalle,
            text="Cantidad:"
        ).grid(
            row=0,
            column=2,
            padx=5
        )

        cantidad = ttk.Entry(
            marco_detalle,
            width=10
        )

        cantidad.grid(
            row=0,
            column=3,
            padx=5
        )

        botones_detalle = ttk.Frame(
            marco_detalle
        )

        botones_detalle.grid(
            row=1,
            column=0,
            columnspan=4,
            pady=8
        )


        # ----------------------------------------------
        # TABLA DE DETALLES
        # ----------------------------------------------

        tabla_detalles = ttk.Treeview(
            ventana,
            columns=(
                "detalle",
                "venta",
                "producto_id",
                "producto",
                "cantidad",
                "precio",
                "subtotal"
            ),
            show="headings",
            height=7
        )

        columnas_detalle = [
            ("detalle", "Detalle", 60),
            ("venta", "Venta", 60),
            ("producto_id", "Producto ID", 80),
            ("producto", "Producto", 180),
            ("cantidad", "Cantidad", 80),
            ("precio", "Precio", 100),
            ("subtotal", "Subtotal", 110)
        ]

        for codigo, titulo, ancho in columnas_detalle:
            tabla_detalles.heading(
                codigo,
                text=titulo
            )

            tabla_detalles.column(
                codigo,
                width=ancho
            )

        tabla_detalles.pack(pady=10)


        def cargar_catalogos():

            clientes = self.consultar(
                "sp_clientes_listar"
            )

            productos = self.consultar(
                "sp_productos_listar"
            )

            cliente["values"] = [
                f"{fila[0]} - {fila[1]}"
                for fila in clientes
            ]

            producto["values"] = [
                f"{fila[0]} - {fila[1]}"
                for fila in productos
            ]


        def cargar_ventas():

            self.limpiar_tabla(
                tabla_ventas
            )

            datos = self.consultar(
                "sp_ventas_listar"
            )

            for fila in datos:
                tabla_ventas.insert(
                    "",
                    tk.END,
                    values=fila
                )


        def cargar_detalles():

            self.limpiar_tabla(
                tabla_detalles
            )

            seleccion = tabla_ventas.selection()

            if not seleccion:
                return

            venta_id = int(
                tabla_ventas.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            datos = self.consultar(
                "sp_detalle_venta_listar",
                [venta_id]
            )

            for fila in datos:
                tabla_detalles.insert(
                    "",
                    tk.END,
                    values=fila
                )


        def limpiar_venta():

            cliente.set("")

            fecha.delete(
                0,
                tk.END
            )

            fecha.insert(
                0,
                datetime.now().strftime(
                    "%Y-%m-%d %H:%M:%S"
                )
            )


        def limpiar_detalle():

            producto.set("")
            cantidad.delete(
                0,
                tk.END
            )


        def seleccionar_venta(evento):

            seleccion = tabla_ventas.selection()

            if not seleccion:
                return

            datos = tabla_ventas.item(
                seleccion[0],
                "values"
            )

            cliente_id = int(
                datos[2]
            )

            for valor in cliente["values"]:

                if int(
                    valor.split(" - ")[0]
                ) == cliente_id:

                    cliente.set(valor)
                    break

            fecha.delete(
                0,
                tk.END
            )

            fecha.insert(
                0,
                datos[1]
            )

            cargar_detalles()


        def seleccionar_detalle(evento):

            seleccion = tabla_detalles.selection()

            if not seleccion:
                return

            datos = tabla_detalles.item(
                seleccion[0],
                "values"
            )

            producto_id = int(
                datos[2]
            )

            for valor in producto["values"]:

                if int(
                    valor.split(" - ")[0]
                ) == producto_id:

                    producto.set(valor)
                    break

            cantidad.delete(
                0,
                tk.END
            )

            cantidad.insert(
                0,
                datos[4]
            )


        def registrar_venta():

            cliente_id = self.obtener_id_combo(
                cliente
            )

            if cliente_id is None:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un cliente."
                )
                return

            fecha_venta = fecha.get()

            if fecha_venta == "":
                fecha_venta = datetime.now().strftime(
                    "%Y-%m-%d %H:%M:%S"
                )

            resultado = self.ejecutar(
                "sp_ventas_insertar",
                [
                    cliente_id,
                    fecha_venta,
                    0,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[3]
                )

                limpiar_venta()
                cargar_ventas()


        def actualizar_venta():

            seleccion = tabla_ventas.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione una venta."
                )
                return

            cliente_id = self.obtener_id_combo(
                cliente
            )

            if cliente_id is None:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un cliente."
                )
                return

            venta_id = int(
                tabla_ventas.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_ventas_actualizar",
                [
                    venta_id,
                    cliente_id,
                    fecha.get(),
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[3]
                )

                limpiar_venta()
                cargar_ventas()
                self.limpiar_tabla(
                    tabla_detalles
                )


        def eliminar_venta():

            seleccion = tabla_ventas.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione una venta."
                )
                return

            venta_id = int(
                tabla_ventas.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_ventas_eliminar",
                [
                    venta_id,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[1]
                )

                limpiar_venta()
                cargar_ventas()

                self.limpiar_tabla(
                    tabla_detalles
                )


        def agregar_producto():

            seleccion = tabla_ventas.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione una venta."
                )
                return

            producto_id = self.obtener_id_combo(
                producto
            )

            if producto_id is None:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un producto."
                )
                return

            try:
                valor_cantidad = int(
                    cantidad.get()
                )

                if valor_cantidad <= 0:
                    raise ValueError

            except ValueError:
                messagebox.showwarning(
                    "Aviso",
                    "Ingrese una cantidad válida."
                )
                return

            venta_id = int(
                tabla_ventas.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_detalle_venta_insertar",
                [
                    venta_id,
                    producto_id,
                    valor_cantidad,
                    0,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[4]
                )

                limpiar_detalle()
                cargar_detalles()
                cargar_ventas()


        def actualizar_producto():

            seleccion = tabla_detalles.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un producto de la venta."
                )
                return

            producto_id = self.obtener_id_combo(
                producto
            )

            if producto_id is None:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un producto."
                )
                return

            try:
                valor_cantidad = int(
                    cantidad.get()
                )

                if valor_cantidad <= 0:
                    raise ValueError

            except ValueError:
                messagebox.showwarning(
                    "Aviso",
                    "Ingrese una cantidad válida."
                )
                return

            detalle_id = int(
                tabla_detalles.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_detalle_venta_actualizar",
                [
                    detalle_id,
                    producto_id,
                    valor_cantidad,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[3]
                )

                limpiar_detalle()
                cargar_detalles()
                cargar_ventas()


        def eliminar_producto():

            seleccion = tabla_detalles.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un producto de la venta."
                )
                return

            detalle_id = int(
                tabla_detalles.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_detalle_venta_eliminar",
                [
                    detalle_id,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[1]
                )

                limpiar_detalle()
                cargar_detalles()
                cargar_ventas()


        ttk.Button(
            botones_venta,
            text="Registrar venta",
            command=registrar_venta
        ).grid(
            row=0,
            column=0,
            padx=4
        )

        ttk.Button(
            botones_venta,
            text="Actualizar venta",
            command=actualizar_venta
        ).grid(
            row=0,
            column=1,
            padx=4
        )

        ttk.Button(
            botones_venta,
            text="Eliminar venta",
            command=eliminar_venta
        ).grid(
            row=0,
            column=2,
            padx=4
        )

        ttk.Button(
            botones_venta,
            text="Limpiar",
            command=limpiar_venta
        ).grid(
            row=0,
            column=3,
            padx=4
        )

        ttk.Button(
            botones_detalle,
            text="Agregar producto",
            command=agregar_producto
        ).grid(
            row=0,
            column=0,
            padx=4
        )

        ttk.Button(
            botones_detalle,
            text="Actualizar producto",
            command=actualizar_producto
        ).grid(
            row=0,
            column=1,
            padx=4
        )

        ttk.Button(
            botones_detalle,
            text="Eliminar producto",
            command=eliminar_producto
        ).grid(
            row=0,
            column=2,
            padx=4
        )

        ttk.Button(
            botones_detalle,
            text="Limpiar",
            command=limpiar_detalle
        ).grid(
            row=0,
            column=3,
            padx=4
        )

        tabla_ventas.bind(
            "<<TreeviewSelect>>",
            seleccionar_venta
        )

        tabla_detalles.bind(
            "<<TreeviewSelect>>",
            seleccionar_detalle
        )

        cargar_catalogos()
        cargar_ventas()


    # ==================================================
    # INVENTARIO
    # ==================================================

    def ventana_inventario(self):

        ventana = tk.Toplevel(self.ventana)
        ventana.title("Gestión de Inventario")
        ventana.geometry("1000x600")

        tk.Label(
            ventana,
            text="Gestión de Inventario",
            font=("Arial", 18, "bold")
        ).pack(pady=15)

        formulario = ttk.Frame(ventana)
        formulario.pack()

        ttk.Label(
            formulario,
            text="Producto:"
        ).grid(
            row=0,
            column=0,
            padx=5,
            pady=5
        )

        producto = ttk.Combobox(
            formulario,
            width=35,
            state="readonly"
        )

        producto.grid(
            row=0,
            column=1
        )

        ttk.Label(
            formulario,
            text="Tipo:"
        ).grid(
            row=1,
            column=0,
            padx=5,
            pady=5
        )

        tipo = ttk.Combobox(
            formulario,
            values=(
                "ENTRADA",
                "SALIDA"
            ),
            width=32,
            state="readonly"
        )

        tipo.grid(
            row=1,
            column=1
        )

        ttk.Label(
            formulario,
            text="Cantidad:"
        ).grid(
            row=2,
            column=0,
            padx=5,
            pady=5
        )

        cantidad = ttk.Entry(
            formulario,
            width=35
        )

        cantidad.grid(
            row=2,
            column=1
        )

        ttk.Label(
            formulario,
            text="Observación:"
        ).grid(
            row=3,
            column=0,
            padx=5,
            pady=5
        )

        observacion = ttk.Entry(
            formulario,
            width=35
        )

        observacion.grid(
            row=3,
            column=1
        )

        tabla = ttk.Treeview(
            ventana,
            columns=(
                "id",
                "producto_id",
                "producto",
                "tipo",
                "cantidad",
                "fecha",
                "observacion"
            ),
            show="headings",
            height=12
        )

        columnas = [
            ("id", "ID", 45),
            ("producto_id", "Producto ID", 80),
            ("producto", "Producto", 180),
            ("tipo", "Tipo", 80),
            ("cantidad", "Cantidad", 70),
            ("fecha", "Fecha", 150),
            ("observacion", "Observación", 260)
        ]

        for codigo, titulo, ancho in columnas:
            tabla.heading(
                codigo,
                text=titulo
            )

            tabla.column(
                codigo,
                width=ancho
            )

        tabla.pack(pady=15)


        def cargar_productos():

            productos = self.consultar(
                "sp_productos_listar"
            )

            producto["values"] = [
                f"{fila[0]} - {fila[1]}"
                for fila in productos
            ]


        def cargar():

            self.limpiar_tabla(
                tabla
            )

            datos = self.consultar(
                "sp_inventario_listar",
                [0]
            )

            for fila in datos:
                tabla.insert(
                    "",
                    tk.END,
                    values=fila
                )


        def limpiar():

            producto.set("")
            tipo.set("")

            cantidad.delete(
                0,
                tk.END
            )

            observacion.delete(
                0,
                tk.END
            )


        def seleccionar(evento):

            seleccion = tabla.selection()

            if not seleccion:
                return

            datos = tabla.item(
                seleccion[0],
                "values"
            )

            producto_id = int(
                datos[1]
            )

            for valor in producto["values"]:

                if int(
                    valor.split(" - ")[0]
                ) == producto_id:

                    producto.set(valor)
                    break

            tipo.set(
                datos[3]
            )

            cantidad.delete(
                0,
                tk.END
            )

            cantidad.insert(
                0,
                datos[4]
            )

            observacion.delete(
                0,
                tk.END
            )

            observacion.insert(
                0,
                datos[6]
            )


        def registrar():

            producto_id = self.obtener_id_combo(
                producto
            )

            if producto_id is None:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un producto."
                )
                return

            if tipo.get() == "":
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione el tipo de movimiento."
                )
                return

            try:
                valor_cantidad = int(
                    cantidad.get()
                )

                if valor_cantidad <= 0:
                    raise ValueError

            except ValueError:
                messagebox.showwarning(
                    "Aviso",
                    "La cantidad debe ser válida."
                )
                return

            resultado = self.ejecutar(
                "sp_inventario_insertar",
                [
                    producto_id,
                    tipo.get(),
                    valor_cantidad,
                    observacion.get(),
                    0,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[5]
                )

                limpiar()
                cargar()


        def actualizar():

            seleccion = tabla.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un movimiento."
                )
                return

            producto_id = self.obtener_id_combo(
                producto
            )

            if producto_id is None:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un producto."
                )
                return

            if tipo.get() == "":
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione el tipo de movimiento."
                )
                return

            try:
                valor_cantidad = int(
                    cantidad.get()
                )

                if valor_cantidad <= 0:
                    raise ValueError

            except ValueError:
                messagebox.showwarning(
                    "Aviso",
                    "La cantidad debe ser válida."
                )
                return

            movimiento_id = int(
                tabla.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_inventario_actualizar",
                [
                    movimiento_id,
                    producto_id,
                    tipo.get(),
                    valor_cantidad,
                    observacion.get(),
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[5]
                )

                limpiar()
                cargar()


        def eliminar():

            seleccion = tabla.selection()

            if not seleccion:
                messagebox.showwarning(
                    "Aviso",
                    "Seleccione un movimiento."
                )
                return

            movimiento_id = int(
                tabla.item(
                    seleccion[0],
                    "values"
                )[0]
            )

            resultado = self.ejecutar(
                "sp_inventario_eliminar",
                [
                    movimiento_id,
                    ""
                ]
            )

            if resultado:
                messagebox.showinfo(
                    "Resultado",
                    resultado[1]
                )

                limpiar()
                cargar()


        tabla.bind(
            "<<TreeviewSelect>>",
            seleccionar
        )

        botones = ttk.Frame(ventana)
        botones.pack()

        ttk.Button(
            botones,
            text="Registrar",
            command=registrar
        ).grid(
            row=0,
            column=0,
            padx=5
        )

        ttk.Button(
            botones,
            text="Actualizar",
            command=actualizar
        ).grid(
            row=0,
            column=1,
            padx=5
        )

        ttk.Button(
            botones,
            text="Eliminar",
            command=eliminar
        ).grid(
            row=0,
            column=2,
            padx=5
        )

        ttk.Button(
            botones,
            text="Limpiar",
            command=limpiar
        ).grid(
            row=0,
            column=3,
            padx=5
        )

        ttk.Button(
            botones,
            text="Actualizar lista",
            command=cargar
        ).grid(
            row=0,
            column=4,
            padx=5
        )

        cargar_productos()
        cargar()


    # ==================================================
    # REPORTES
    # ==================================================

    def ventana_reportes(self):

        ventana = tk.Toplevel(self.ventana)
        ventana.title("Reportes")
        ventana.geometry("900x600")

        tk.Label(
            ventana,
            text="Reportes de TechZone CR",
            font=("Arial", 18, "bold")
        ).pack(pady=15)

        texto = tk.Text(
            ventana,
            width=105,
            height=25
        )

        texto.pack(
            padx=10,
            pady=10
        )


        def mostrar_reporte(
            procedimiento,
            titulo
        ):

            texto.delete(
                "1.0",
                tk.END
            )

            texto.insert(
                tk.END,
                titulo + "\n"
            )

            texto.insert(
                tk.END,
                "=" * 70 + "\n\n"
            )

            cursor = self.conexion.cursor()

            try:
                cursor.callproc(
                    procedimiento
                )

                numero = 1

                for resultado in cursor.stored_results():

                    columnas = resultado.column_names
                    filas = resultado.fetchall()

                    texto.insert(
                        tk.END,
                        f"Resultado {numero}\n"
                    )

                    texto.insert(
                        tk.END,
                        "-" * 70 + "\n"
                    )

                    for fila in filas:

                        for i in range(
                            len(columnas)
                        ):

                            texto.insert(
                                tk.END,
                                f"{columnas[i]}: {fila[i]} | "
                            )

                        texto.insert(
                            tk.END,
                            "\n"
                        )

                    texto.insert(
                        tk.END,
                        "\n"
                    )

                    numero += 1

            except Exception as error:
                messagebox.showerror(
                    "Error",
                    str(error)
                )

            finally:
                cursor.close()


        botones = ttk.Frame(
            ventana
        )

        botones.pack()

        reportes = [
            (
                "Productos",
                "sp_reporte_productos"
            ),
            (
                "Categorías y proveedores",
                "sp_reporte_catalogos"
            ),
            (
                "Ventas",
                "sp_reporte_ventas"
            ),
            (
                "Inventario",
                "sp_reporte_inventario"
            ),
            (
                "Reporte general",
                "sp_reporte_general"
            )
        ]

        for i, reporte in enumerate(
            reportes
        ):

            ttk.Button(
                botones,
                text=reporte[0],
                command=lambda p=reporte[1], t=reporte[0]:
                    mostrar_reporte(p, t)
            ).grid(
                row=0,
                column=i,
                padx=4
            )


    # ==================================================
    # CERRAR
    # ==================================================

    def cerrar(self):

        if self.conexion is not None:
            self.conexion.close()

        self.ventana.destroy()


# ======================================================
# INICIAR APLICACIÓN
# ======================================================

ventana = tk.Tk()
app = AplicacionTechZone(ventana)
ventana.mainloop()