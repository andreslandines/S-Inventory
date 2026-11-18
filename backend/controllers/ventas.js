
import {
    obtenerVentas,
    obtenerVentaPorId,
    obtenerDetallesVenta,
    registrarVentaFefo
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
// REGISTRAR VENTA CON SISTEMA FEFO
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

        // Normalizar y validar cada producto
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

        console.log("Registrando venta mediante FEFO...");
        console.log("Usuario:", usuarioId);
        console.log("Productos:", productosValidados);

        // La función SQL realiza en una sola transacción:
        // - Creación de la venta.
        // - Registro de los detalles.
        // - Descuento de los lotes FEFO.
        // - Actualización del stock general.
        // - Registro de movimientos.
        // - Registro de trazabilidad de lotes.

        const { data, error } = await registrarVentaFefo(
            usuarioId,
            productosValidados
        );

        if (error) {
            console.error(
                "Error al registrar venta FEFO:",
                error
            );

            const codigoEstado =
                error.code === "P0001" ? 400 : 500;

            return res.status(codigoEstado).json({
                error: "No fue posible registrar la venta",
                detalle: error.message
            });
        }

        // Comprobar respuesta de la función SQL
        const venta = data?.venta;
        const detalles = data?.detalles;

        if (!venta || !venta.id_venta) {
            console.error(
                "La función FEFO no devolvió los datos esperados:",
                data
            );

            return res.status(500).json({
                error: "La venta fue procesada, pero la respuesta de la base de datos no tiene el formato esperado"
            });
        }

        // Enviar correo después de completar la transacción
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

        // Mantener la estructura de respuesta utilizada por Flutter
        const detallesRespuesta = (detalles || []).map(
            (detalle) => ({
                id_venta: venta.id_venta,
                id_producto: detalle.id_producto,
                cantidad: detalle.cantidad,
                precio_unitario: detalle.precio_unitario
            })
        );

        console.log(
            `Venta ${venta.id_venta} registrada correctamente mediante FEFO`
        );

        return res.status(201).json({
            message: "Venta registrada correctamente",
            venta: {
                id_venta: venta.id_venta,
                id_usuario: venta.id_usuario,
                total: venta.total
            },
            detalles: detallesRespuesta
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
