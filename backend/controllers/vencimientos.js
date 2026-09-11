import {obtenerVencimientos, obtenerVencimientoPorId, crearVencimiento, actualizarVencimiento,
     eliminarVencimiento, obtenerProximosAVencer } from "../models/vencimientos.js";


// Obtener todos los vencimientos
export const listarVencimientos = async (req, res) => {

    try {

        const { data, error } = await obtenerVencimientos();

        if (error) {
            console.error("Error al obtener los vencimientos: ", error);

            return res.status(500).json({
                error: "Error al obtener los vencimientos"
            });
        }

        return res.status(200).json(data);

    } catch (error) {

        console.error("Error en listarVencimientos: ", error);

        return res.status(500).json({
            error: error.message
        });
    }
};



// Obtener un vencimiento por ID
export const obtenerVencimiento = async (req, res) => {

    try {

        const { id_vencimiento } = req.params;

        const { data, error } =
            await obtenerVencimientoPorId(id_vencimiento);

        if (error || !data) {
            return res.status(404).json({
                error: "Vencimiento no encontrado"
            });
        }

        return res.status(200).json(data);

    } catch (error) {

        console.error("Error al obtener el vencimiento: ", error);

        return res.status(500).json({
            error: error.message
        });
    }
};


// Crear un vencimiento
export const registrarVencimiento = async (req, res) => {

    try {

        const { id_producto, fecha_vencimiento } = req.body;

        // Validar producto
        if (!id_producto) {
            return res.status(400).json({
                error: "El id_producto es requerido"
            });
        }

        // Validar fecha
        if (!fecha_vencimiento) {
            return res.status(400).json({
                error: "La fecha de vencimiento es requerida"
            });
        }

        const { data, error } = await crearVencimiento({
            id_producto,
            fecha_vencimiento
        });

        if (error) {

            console.error("Error al crear vencimiento: ", error);

            return res.status(500).json({
                error: "Error al crear el vencimiento",
                detalle: error.message
            });
        }

        return res.status(201).json({
            message: "Vencimiento registrado correctamente",
            vencimiento: data
        });

    } catch (error) {

        console.error("Error al registrar vencimiento: ", error);

        return res.status(500).json({
            error: error.message
        });
    }
};


// Actualizar un vencimiento
export const editarVencimiento = async (req, res) => {

    try {

        const { id_vencimiento } = req.params;

        const { id_producto, fecha_vencimiento } = req.body;

        const { data, error } =
            await actualizarVencimiento(
                id_vencimiento,
                {
                    id_producto,
                    fecha_vencimiento
                }
            );

        if (error || !data) {

            return res.status(404).json({
                error: "Vencimiento no encontrado"
            });
        }

        return res.status(200).json({
            message: "Vencimiento actualizado correctamente",
            vencimiento: data
        });

    } catch (error) {

        console.error("Error al actualizar vencimiento: ", error);

        return res.status(500).json({
            error: error.message
        });
    }
};


// Eliminar un vencimiento
export const borrarVencimiento = async (req, res) => {

    try {

        const { id_vencimiento } = req.params;

        const { data, error } =
            await eliminarVencimiento(id_vencimiento);

        if (error || !data) {

            return res.status(404).json({
                error: "Vencimiento no encontrado"
            });
        }

        return res.status(200).json({
            message: "Vencimiento eliminado correctamente",
            vencimiento: data
        });

    } catch (error) {

        console.error("Error al eliminar vencimiento: ", error);

        return res.status(500).json({
            error: error.message
        });
    }
};

// Obtener productos próximos a vencer
export const listarProximosAVencer = async (req, res) => {

    try {

        const dias = parseInt(req.query.dias) || 30;

        const { data, error } =
            await obtenerProximosAVencer(dias);

        if (error) {

            console.error(
                "Error al obtener productos próximos a vencer: ",
                error
            );

            return res.status(500).json({
                error: "Error al obtener productos próximos a vencer"
            });
        }

        return res.status(200).json(data);

    } catch (error) {

        console.error(
            "Error en listarProximosAVencer: ",
            error
        );

        return res.status(500).json({
            error: error.message
        });
    }
};