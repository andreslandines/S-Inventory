
import {obtenerVentas, obtenerVentaPorId, obtenerDetallesVenta, crearVenta,
     crearDetalleVenta, actualizarStock, crearMovimiento} from "../models/ventas.js";
import { obtenerPorId } from "../models/productos.js";
import { enviarCorreoVenta } from "../utils/sendEmail.js";

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
        return res.status(500).json({ error: error.message });
    }
};

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
            console.error("Error al obtener los detalles:", errorDetalles);
            return res.status(500).json({
                error: "Error al obtener los detalles de la venta",
                detalle: errorDetalles.message
            });
        }

        return res.status(200).json({
            id_venta: venta.id_venta,
            id_usuario: venta.id_usuario,
            total: venta.total,
            fecha: venta.fecha,
            detalles
        });
    } catch (error) {
        console.error("Error al obtener la venta:", error);
        return res.status(500).json({ error: error.message });
    }
};

export const registrarVenta = async (req, res) => {
    try {
        const { id_usuario, productos } = req.body;

        if (!id_usuario) {
            return res.status(400).json({
                error: "El id_usuario es requerido"
            });
        }

        if (!productos || !Array.isArray(productos) || productos.length === 0) {
            return res.status(400).json({
                error: "Debe enviar al menos un producto"
            });
        }

        let total = 0;
        const detalles = [];

        for (const item of productos) {
            const { id_productos, cantidad } = item;

            if (!id_productos) {
                return res.status(400).json({
                    error: "El id_productos es requerido"
                });
            }

            if (!cantidad || cantidad <= 0) {
                return res.status(400).json({
                    error: "La cantidad debe ser mayor a 0"
                });
            }

            const { data: producto, error } = await obtenerPorId(id_productos);

            if (error) {
                console.error("Error al buscar producto:", error);
                return res.status(500).json({
                    error: "Error al buscar el producto",
                    detalle: error.message
                });
            }

            if (!producto) {
                return res.status(404).json({
                    error: `Producto ${id_productos} no encontrado`
                });
            }

            if (producto.stock < cantidad) {
                return res.status(400).json({
                    error: `Stock insuficiente para el producto ${producto.nombre}`,
                    stock_disponible: producto.stock,
                    cantidad_solicitada: cantidad
                });
            }

            const subtotal = Number(producto.precio) * Number(cantidad);
            total += subtotal;

            detalles.push({
                id_producto: producto.id_productos,
                cantidad,
                precio_unitario: producto.precio
            });
        }

        console.log("Total de la venta:", total);
        console.log("Detalles:", detalles);

        const { data: venta, error: errorVenta } = await crearVenta({
            id_usuario,
            total
        });

        if (errorVenta) {
            console.error("Error al crear la venta:", errorVenta);
            return res.status(500).json({
                error: "Error al guardar la venta",
                detalle: errorVenta.message
            });
        }

        const detallesVenta = detalles.map(detalle => ({
            id_venta: venta.id_venta,
            id_producto: detalle.id_producto,
            cantidad: detalle.cantidad,
            precio_unitario: detalle.precio_unitario
        }));

        for (const detalle of detallesVenta) {
            const { error } = await crearDetalleVenta(detalle);

            if (error) {
                console.error("Error al crear detalle de venta:", error);
                return res.status(500).json({
                    error: "La venta fue creada pero hubo un error al guardar los detalles",
                    detalle: error.message
                });
            }
        }

        for (const item of productos) {
            const { id_productos, cantidad } = item;

            const { data: producto, error: errorProducto } =
                await obtenerPorId(id_productos);

            if (errorProducto) {
                console.error("Error al buscar producto para stock:", errorProducto);
                return res.status(500).json({
                    error: "Error al buscar el producto para actualizar stock",
                    detalle: errorProducto.message
                });
            }

            if (!producto) {
                return res.status(404).json({
                    error: `Producto ${id_productos} no encontrado`
                });
            }

            const nuevoStock =
                Number(producto.stock) - Number(cantidad);

            const { error: errorStock } =
                await actualizarStock(id_productos, nuevoStock);

            if (errorStock) {
                console.error("Error al actualizar el stock:", errorStock);
                return res.status(500).json({
                    error: "Error al actualizar el stock",
                    detalle: errorStock.message
                });
            }

            console.log(
                `Producto ${id_productos}: stock actualizado a ${nuevoStock}`
            );

            const { error: errorMovimiento } =
                await crearMovimiento({
                    id_producto: id_productos,
                    tipo: "salida",
                    cantidad,
                    id_venta: venta.id_venta
                });

            if (errorMovimiento) {
                console.error(
                    "Error al registrar movimiento:",
                    errorMovimiento
                );

                return res.status(500).json({
                    error: "El stock fue actualizado pero no se pudo registrar el movimiento",
                    detalle: errorMovimiento.message
                });
            }

            console.log(
                `Movimiento registrado: producto ${id_productos}, cantidad ${cantidad}`
            );
        }

        try {
            await enviarCorreoVenta(
                venta.id_venta,
                venta.id_usuario,
                venta.total
            );
        } catch (errorCorreo) {
            console.error(
                "Error enviando correo de venta:",
                errorCorreo
            );
        }

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
        console.error("Error al registrar venta:", error);
        return res.status(500).json({
            error: error.message
        });
    }
};

