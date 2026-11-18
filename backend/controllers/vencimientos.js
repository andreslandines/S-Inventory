
import {
    obtenerVencimientos,
    obtenerVencimientoPorId,
    registrarEntradaLote,
    actualizarVencimiento,
    obtenerProximosAVencer,
    obtenerLotesVencidos
} from "../models/vencimientos.js";

// Fecha actual de Colombia.
const obtenerFechaColombia = () => {
    const partes = new Intl.DateTimeFormat("en-CA", {
        timeZone: "America/Bogota",
        year: "numeric",
        month: "2-digit",
        day: "2-digit"
    }).formatToParts(new Date());

    const obtener = (tipo) =>
        partes.find((parte) => parte.type === tipo)?.value;

    return `${obtener("year")}-${obtener("month")}-${obtener("day")}`;
};

// Validar que una fecha YYYY-MM-DD exista realmente.
const validarFecha = (fecha) => {
    if (typeof fecha !== "string") return false;

    const coincidencia = fecha.match(/^(\d{4})-(\d{2})-(\d{2})$/);

    if (!coincidencia) return false;

    const anio = Number(coincidencia[1]);
    const mes = Number(coincidencia[2]);
    const dia = Number(coincidencia[3]);

    const fechaUTC = new Date(Date.UTC(anio, mes - 1, dia));

    return (
        fechaUTC.getUTCFullYear() === anio &&
        fechaUTC.getUTCMonth() === mes - 1 &&
        fechaUTC.getUTCDate() === dia
    );
};

// ==========================================
// LISTAR TODOS LOS LOTES
// ==========================================

export const listarVencimientos = async (req, res) => {
    try {
        const { data, error } = await obtenerVencimientos();

        if (error) {
            console.error("Error al obtener los lotes:", error);

            return res.status(500).json({
                error: "Error al obtener los lotes",
                detalle: error.message
            });
        }

        return res.status(200).json(data);

    } catch (error) {
        console.error("Error en listarVencimientos:", error);

        return res.status(500).json({
            error: error.message
        });
    }
};

// ==========================================
// OBTENER UN LOTE
// ==========================================

export const obtenerVencimiento = async (req, res) => {
    try {
        const id = Number(req.params.id_vencimiento);

        if (!Number.isSafeInteger(id) || id <= 0) {
            return res.status(400).json({
                error: "El ID del lote no es válido"
            });
        }

        const { data, error } = await obtenerVencimientoPorId(id);

        if (error || !data) {
            return res.status(404).json({
                error: "Lote no encontrado"
            });
        }

        return res.status(200).json(data);

    } catch (error) {
        console.error("Error al obtener el lote:", error);

        return res.status(500).json({
            error: error.message
        });
    }
};

// ==========================================
// REGISTRAR ENTRADA DE INVENTARIO
// ==========================================

export const registrarVencimiento = async (req, res) => {
    try {
        const {
            id_producto,
            cantidad,
            fecha_vencimiento
        } = req.body;

        const productoId = Number(id_producto);
        const cantidadEntrada = Number(cantidad);

        if (
            !Number.isSafeInteger(productoId) ||
            productoId <= 0
        ) {
            return res.status(400).json({
                error: "Debe seleccionar un producto válido"
            });
        }

        if (
            !Number.isSafeInteger(cantidadEntrada) ||
            cantidadEntrada <= 0
        ) {
            return res.status(400).json({
                error: "La cantidad debe ser un entero mayor a cero"
            });
        }

        let fecha = null;

        if (
            fecha_vencimiento !== undefined &&
            fecha_vencimiento !== null &&
            fecha_vencimiento !== ""
        ) {
            if (!validarFecha(fecha_vencimiento)) {
                return res.status(400).json({
                    error: "La fecha de vencimiento no es válida. Use YYYY-MM-DD"
                });
            }

            if (fecha_vencimiento < obtenerFechaColombia()) {
                return res.status(400).json({
                    error: "No se puede registrar un lote con fecha de vencimiento pasada"
                });
            }

            fecha = fecha_vencimiento;
        }

        const { data, error } = await registrarEntradaLote(
            productoId,
            cantidadEntrada,
            fecha
        );

        if (error) {
            console.error("Error al registrar la entrada:", error);

            return res.status(400).json({
                error: "No se pudo registrar la entrada",
                detalle: error.message
            });
        }

        return res.status(201).json(data);

    } catch (error) {
        console.error("Error en registrarVencimiento:", error);

        return res.status(500).json({
            error: error.message
        });
    }
};

// ==========================================
// ACTUALIZAR FECHA DE UN LOTE
// ==========================================

export const editarVencimiento = async (req, res) => {
    try {
        const id = Number(req.params.id_vencimiento);

        if (!Number.isSafeInteger(id) || id <= 0) {
            return res.status(400).json({
                error: "El ID del lote no es válido"
            });
        }

        if (
            !Object.prototype.hasOwnProperty.call(
                req.body,
                "fecha_vencimiento"
            )
        ) {
            return res.status(400).json({
                error: "Debe indicar la fecha de vencimiento"
            });
        }

        const { fecha_vencimiento } = req.body;

        if (
            fecha_vencimiento !== null &&
            !validarFecha(fecha_vencimiento)
        ) {
            return res.status(400).json({
                error: "La fecha debe ser válida o null"
            });
        }

        const { data, error } = await actualizarVencimiento(
            id,
            { fecha_vencimiento }
        );

        if (error) {
            console.error("Error al actualizar el lote:", error);

            return res.status(400).json({
                error: "No se pudo actualizar el lote",
                detalle: error.message
            });
        }

        if (!data) {
            return res.status(404).json({
                error: "Lote no encontrado"
            });
        }

        return res.status(200).json({
            message: "Lote actualizado correctamente",
            lote: data
        });

    } catch (error) {
        console.error("Error al actualizar el lote:", error);

        return res.status(500).json({
            error: error.message
        });
    }
};

// ==========================================
// ELIMINAR LOTE
// ==========================================

export const borrarVencimiento = async (req, res) => {
    return res.status(409).json({
        error: "No se permite eliminar lotes directamente. Debe realizarse un ajuste de inventario para conservar la trazabilidad."
    });
};

// ==========================================
// LOTES PRÓXIMOS A VENCER
// ==========================================

export const listarProximosAVencer = async (req, res) => {
    try {
        let dias = 30;

        if (req.query.dias !== undefined) {
            if (!/^\d+$/.test(req.query.dias)) {
                return res.status(400).json({
                    error: "El rango de días debe ser un número entero entre 1 y 365"
                });
            }

            dias = Number(req.query.dias);
        }

        if (
            !Number.isSafeInteger(dias) ||
            dias < 1 ||
            dias > 365
        ) {
            return res.status(400).json({
                error: "El rango de días debe estar entre 1 y 365"
            });
        }

        const { data, error } = await obtenerProximosAVencer(dias);

        if (error) {
            console.error("Error al consultar próximos vencimientos:", error);

            return res.status(500).json({
                error: "Error al consultar próximos vencimientos",
                detalle: error.message
            });
        }

        return res.status(200).json(data);

    } catch (error) {
        console.error("Error en listarProximosAVencer:", error);

        return res.status(500).json({
            error: error.message
        });
    }
};

// ==========================================
// LOTES VENCIDOS
// ==========================================

export const listarLotesVencidos = async (req, res) => {
    try {
        const { data, error } = await obtenerLotesVencidos();

        if (error) {
            console.error("Error al consultar lotes vencidos:", error);

            return res.status(500).json({
                error: "Error al consultar lotes vencidos",
                detalle: error.message
            });
        }

        return res.status(200).json(data);

    } catch (error) {
        console.error("Error en listarLotesVencidos:", error);

        return res.status(500).json({
            error: error.message
        });
    }
};
