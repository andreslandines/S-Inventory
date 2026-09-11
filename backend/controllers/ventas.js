import { obtenerVentas, obtenerVentaPorId, obtenerDetallesVenta, crearVenta, 
crearDetalleVenta, actualizarStock, crearMovimiento } from "../models/ventas.js";
import { obtenerPorId } from "../models/productos.js";

// Obtener todas las ventas
export const listarVentas = async (req, res) => {

    try {

        const { data, error } = await obtenerVentas();

        if (error) {
            console.error("Error al obtener las ventas:", error);

            return res.status(500).json({
                error: "Error al obtener las ventas"
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


export const obtenerVenta = async (req, res) => {

    try {

        const { id_venta } = req.params;

        // Buscar la venta
        const { data: venta, error: errorVenta } =
            await obtenerVentaPorId(id_venta);

        if (errorVenta || !venta) {
            return res.status(404).json({
                error: "Venta no encontrada"
            });
        }

        // Buscar los detalles de la venta
        const { data: detalles, error: errorDetalles } =
            await obtenerDetallesVenta(id_venta);

        if (errorDetalles) {
            console.error(
                "Error al obtener los detalles:",
                errorDetalles
            );

            return res.status(500).json({
                error: "Error al obtener los detalles de la venta"
            });
        }

        // Devolver venta + detalles
        return res.status(200).json({
            id_venta: venta.id_venta,
            id_usuario: venta.id_usuario,
            total: venta.total,
            fecha: venta.fecha,
            detalles: detalles
        });

    } catch (error) {

        console.error("Error al obtener la venta:", error);

        return res.status(500).json({
            error: error.message
        });
    }
};


export const registrarVenta = async (req, res) => {

    try {

        const { id_usuario, productos } = req.body;

        // Validar usuario
        if (!id_usuario) {
            return res.status(400).json({
                error: "El id_usuario es requerido"
            });
        }

        // Validar productos
        if (!productos || !Array.isArray(productos) || productos.length === 0) {
            return res.status(400).json({
                error: "Debe enviar al menos un producto"
            });
        }

        let total = 0;
        const detalles = [];

        // Buscar cada producto
        for (const item of productos) {

            const { id_producto, cantidad } = item;

            // Validar cantidad
            if (!cantidad || cantidad <= 0) {
                return res.status(400).json({
                    error: "La cantidad debe ser mayor a 0"
                });
            }

            // Buscar producto en Supabase
            const { data: producto, error } =
                await obtenerPorId(id_producto);

            if (error || !producto) {
                return res.status(404).json({
                    error: `Producto ${id_producto} no encontrado`
                });
            }

            // Verificar stock
            if (producto.stock < cantidad) {
                return res.status(400).json({
                    error: `Stock insuficiente para el producto ${producto.nombre}`
                });
            }

            // Calcular subtotal
            const subtotal = producto.precio * cantidad;

            total += subtotal;

            // Guardar información del detalle
            detalles.push({
                id_producto: producto.id_productos,
                cantidad: cantidad,
                precio_unitario: producto.precio
            });
        }

        console.log("Total de la venta:", total);
        console.log("Detalles:", detalles);


       
        // CREAR LA VENTA

        const { data: venta, error: errorVenta } =
            await crearVenta({
                id_usuario: id_usuario,
                total: total
            });

        if (errorVenta) {

            console.error("Error al crear la venta:", errorVenta);

            return res.status(500).json({
                error: "Error al guardar la venta",
                detalle: errorVenta.message
            });
        }


        // AGREGAR ID DE LA VENTA A CADA DETALLE

        const detallesVenta = detalles.map(detalle => ({
            id_venta: venta.id_venta,
            id_producto: detalle.id_producto,
            cantidad: detalle.cantidad,
            precio_unitario: detalle.precio_unitario
        }));


        // CREAR LOS DETALLES DE LA VENTA

        for (const detalle of detallesVenta) {

            const { data, error } =
                await crearDetalleVenta(detalle);

            if (error) {

                console.error(
                    "Error al crear detalle de venta:",
                    error
                );

                return res.status(500).json({
                    error: "La venta fue creada pero hubo un error al guardar los detalles",
                    detalle: error.message
                });
            }
        }

            // ACTUALIZAR STOCK

        for (const item of productos) {

            const { id_producto, cantidad } = item;

            const { data: producto, error: errorProducto } =
                await obtenerPorId(id_producto);

            if (errorProducto || !producto) {
                return res.status(404).json({
                    error: `Producto ${id_producto} no encontrado`
                });
            }

            const nuevoStock = producto.stock - cantidad;

            const { error: errorStock } =
                await actualizarStock(id_producto, nuevoStock);

            if (errorStock) {

                console.error("Error al actualizar stock:", errorStock);

                return res.status(500).json({
                    error: "Error al actualizar el stock",
                    detalle: errorStock.message
                });
            }

            console.log(
                `Producto ${id_producto}: stock actualizado a ${nuevoStock}`
            );

            // REGISTRAR MOVIMIENTO

            const { error: errorMovimiento } = await crearMovimiento({
                id_producto: id_producto,
                tipo: "salida",
                cantidad: cantidad,
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
                `Movimiento registrado: producto ${id_producto}, cantidad ${cantidad}`
            );
                    }


        // RESPUESTA FINAL

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