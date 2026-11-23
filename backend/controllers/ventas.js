
import {
    obtenerVentas,
    obtenerVentaPorId,
    obtenerDetallesVenta,
    crearVenta,
    crearDetalleVenta,
    actualizarStock,
    crearMovimiento,
    obtenerLotesDisponibles,
    actualizarCantidadLote,
    crearDetalleVentaLote
} from "../models/ventas.js";

import { obtenerPorId } from "../models/productos.js";
import { enviarCorreoVenta } from "../utils/sendEmail.js";

// ==========================================
// LISTAR TODAS LAS VENTAS
// ==========================================

export const listarVentas = async (req, res) => {
    try {
        const { data, error } = await obtenerVentas();

        if (error) {
            console.error("Error al obtener las ventas:", error);

            return res.status(500).json({
                error: "Error al obtener las ventas",
                detalle: error.message
            });
        }

        return res.status(200).json(data);

    } catch (error) {
        console.error("Error en listarVentas:", error);

        return res.status(500).json({
            error: error.message
        });
    }
};

// ==========================================
// OBTENER UNA VENTA Y SUS DETALLES
// ==========================================

export const obtenerVenta = async (req, res) => {
    try {
        const { id_venta } = req.params;

        const { data: venta, error: errorVenta } =
            await obtenerVentaPorId(id_venta);

        if (errorVenta || !venta) {
            return res.status(404).json({
                error: "Venta no encontrada"
            });
        }

        const { data: detalles, error: errorDetalles } =
            await obtenerDetallesVenta(id_venta);

        if (errorDetalles) {
            console.error(
                "Error al obtener los detalles:",
                errorDetalles
            );

            return res.status(500).json({
                error: "Error al obtener los detalles de la venta",
                detalle: errorDetalles.message
            });
        }

        // Consultar el nombre de cada producto
        const detallesConProductos = await Promise.all(
            (detalles || []).map(async (detalle) => {
                const { data: producto, error: errorProducto } =
                    await obtenerPorId(detalle.id_producto);

                if (errorProducto) {
                    console.error(
                        `Error al consultar el producto ${detalle.id_producto}:`,
                        errorProducto
                    );
                }

                return {
                    ...detalle,
                    nombre_producto:
                        producto?.nombre ||
                        `Producto ${detalle.id_producto}`
                };
            })
        );

        return res.status(200).json({
            id_venta: venta.id_venta,
            id_usuario: venta.id_usuario,
            total: venta.total,
            fecha: venta.fecha,
            detalles: detallesConProductos
        });

    } catch (error) {
        console.error("Error al obtener la venta:", error);

        return res.status(500).json({
            error: error.message
        });
    }
};

// ==========================================
// REGISTRAR VENTA (FEFO CON COLUMNAS REALES)
// ==========================================

export const registrarVenta = async (req, res) => {
    try {
        const { id_usuario, productos } = req.body;

        // Validar usuario
        const usuarioId = Number(id_usuario);

        if (
            !Number.isSafeInteger(usuarioId) ||
            usuarioId <= 0
        ) {
            return res.status(400).json({
                error: "El id_usuario es obligatorio y debe ser válido"
            });
        }

        // Validar productos
        if (
            !Array.isArray(productos) ||
            productos.length === 0
        ) {
            return res.status(400).json({
                error: "Debe enviar al menos un producto"
            });
        }

        const productosValidados = [];

        for (const item of productos) {
            const idProducto = Number(item.id_productos);
            const cantidad = Number(item.cantidad);

            if (
                !Number.isSafeInteger(idProducto) ||
                idProducto <= 0
            ) {
                return res.status(400).json({
                    error: "Hay un identificador de producto inválido"
                });
            }

            if (
                !Number.isSafeInteger(cantidad) ||
                cantidad <= 0
            ) {
                return res.status(400).json({
                    error: `La cantidad del producto ${idProducto} debe ser un entero mayor a cero`
                });
            }

            productosValidados.push({
                id_productos: idProducto,
                cantidad: cantidad
            });
        }

        // Si el mismo producto aparece repetido, se agrupa en una sola línea.
        const agrupados = new Map();

        for (const item of productosValidados) {
            agrupados.set(
                item.id_productos,
                (agrupados.get(item.id_productos) || 0) +
                    item.cantidad
            );
        }

        const productosFinales = Array.from(
            agrupados,
            ([id_productos, cantidad]) => ({
                id_productos,
                cantidad
            })
        );

        // Validar stock, precio y lotes ANTES de escribir en la base de datos.
        const preparados = [];
        let total = 0;

        for (const item of productosFinales) {
            const { data: producto, error: errorProducto } =
                await obtenerPorId(item.id_productos);

            // PGRST116 = "sin filas" en Supabase: es producto inexistente.
            if (
                errorProducto &&
                errorProducto.code !== "PGRST116"
            ) {
                console.error(
                    "Error al consultar el producto:",
                    errorProducto
                );

                return res.status(500).json({
                    error: "Error al consultar el producto",
                    detalle: errorProducto.message
                });
            }

            if (!producto) {
                return res.status(404).json({
                    error: `El producto ${item.id_productos} no existe`
                });
            }

            if (producto.activo === false) {
                return res.status(400).json({
                    error: `El producto ${producto.nombre} está inactivo`
                });
            }

            const stock = Number(producto.stock);

            if (
                !Number.isFinite(stock) ||
                stock < item.cantidad
            ) {
                return res.status(400).json({
                    error: `Stock insuficiente para el producto ${producto.nombre}. Disponible: ${stock}, solicitado: ${item.cantidad}`,
                    stock_disponible: stock,
                    cantidad_solicitada: item.cantidad
                });
            }

            const { data: lotes, error: errorLotes } =
                await obtenerLotesDisponibles(item.id_productos);

            if (errorLotes) {
                console.error(
                    "Error al consultar los lotes:",
                    errorLotes
                );

                return res.status(500).json({
                    error: "Error al consultar los lotes del producto",
                    detalle: errorLotes.message
                });
            }

            const precio = Number(producto.precio);
            total +=
                (Number.isFinite(precio) ? precio : 0) *
                item.cantidad;

            preparados.push({
                id_producto: item.id_productos,
                nombre: producto.nombre,
                cantidad: item.cantidad,
                precio_unitario:
                    Number.isFinite(precio) ? precio : 0,
                stock: stock,
                lotes: lotes || []
            });
        }

        // Crear la venta
        const { data: venta, error: errorVenta } =
            await crearVenta({
                id_usuario: usuarioId,
                total
            });

        if (errorVenta || !venta?.id_venta) {
            console.error(
                "Error al crear la venta:",
                errorVenta
            );

            return res.status(500).json({
                error: "No fue posible guardar la venta",
                detalle: errorVenta?.message
            });
        }

        // Crear los detalles y guardar el id_detalle para la trazabilidad.
        const detallesVenta = [];

        for (const item of preparados) {
            const { data: detalle, error: errorDetalle } =
                await crearDetalleVenta({
                    id_venta: venta.id_venta,
                    id_producto: item.id_producto,
                    cantidad: item.cantidad,
                    precio_unitario: item.precio_unitario
                });

            if (errorDetalle || !detalle?.id_detalle) {
                console.error(
                    "Error al crear el detalle de la venta:",
                    errorDetalle
                );

                return res.status(500).json({
                    error: "La venta se creó pero falló un detalle",
                    detalle: errorDetalle?.message
                });
            }

            item.id_detalle = detalle.id_detalle;

            detallesVenta.push({
                id_venta: venta.id_venta,
                id_producto: item.id_producto,
                cantidad: item.cantidad,
                precio_unitario: item.precio_unitario
            });
        }

        // Descontar lotes FEFO y actualizar stock por cada producto.
        for (const item of preparados) {
            let restante = item.cantidad;

            for (const lote of item.lotes) {
                if (restante <= 0) break;

                const disponible =
                    Number(lote.cantidad_disponible) || 0;
                const tomar = Math.min(restante, disponible);

                if (tomar <= 0) continue;

                const { error: errorLote } =
                    await actualizarCantidadLote(
                        lote.id_vencimiento,
                        disponible - tomar
                    );

                if (errorLote) {
                    console.error(
                        "Error al descontar el lote:",
                        errorLote
                    );

                    return res.status(500).json({
                        error: "No fue posible descontar el lote",
                        detalle: errorLote.message
                    });
                }

                const { error: errorTrazabilidad } =
                    await crearDetalleVentaLote({
                        id_detalle: item.id_detalle,
                        id_vencimiento: lote.id_vencimiento,
                        cantidad: tomar,
                        creado_en: new Date().toISOString()
                    });

                if (errorTrazabilidad) {
                    console.error(
                        "Error al registrar la trazabilidad del lote:",
                        errorTrazabilidad
                    );

                    return res.status(500).json({
                        error: "No fue posible registrar el lote vendido",
                        detalle: errorTrazabilidad.message
                    });
                }

                restante -= tomar;
            }

            if (restante > 0) {
                console.warn(
                    `El producto ${item.id_producto} vendió ${item.cantidad} unidades pero solo ${item.cantidad - restante} estaban en lotes.`
                );
            }

            const { error: errorStock } =
                await actualizarStock(
                    item.id_producto,
                    item.stock - item.cantidad
                );

            if (errorStock) {
                console.error(
                    "Error al actualizar el stock:",
                    errorStock
                );

                return res.status(500).json({
                    error: "No fue posible actualizar el stock",
                    detalle: errorStock.message
                });
            }

            const { error: errorMovimiento } =
                await crearMovimiento({
                    id_producto: item.id_producto,
                    tipo: "salida",
                    cantidad: item.cantidad,
                    id_venta: venta.id_venta
                });

            if (errorMovimiento) {
                console.error(
                    "Error al registrar el movimiento:",
                    errorMovimiento
                );

                return res.status(500).json({
                    error: "No fue posible registrar el movimiento",
                    detalle: errorMovimiento.message
                });
            }
        }

        // El correo es secundario: nunca bloquea la respuesta.
        try {
            await enviarCorreoVenta(
                venta.id_venta,
                venta.id_usuario,
                venta.total
            );

            console.log(
                "Correo de venta enviado correctamente"
            );
        } catch (errorCorreo) {
            console.error(
                "Error enviando correo de venta:",
                errorCorreo
            );
        }

        console.log(
            `Venta ${venta.id_venta} registrada correctamente`
        );

        return res.status(201).json({
            message: "Venta registrada correctamente",
            venta: {
                id_venta: venta.id_venta,
                id_usuario: venta.id_usuario,
                total: venta.total
            },
            detalles: detallesVenta
        });

    } catch (error) {
        console.error(
            "Error al registrar venta:",
            error
        );

        return res.status(500).json({
            error: "Error interno al registrar la venta",
            detalle: error.message
        });
    }
};
