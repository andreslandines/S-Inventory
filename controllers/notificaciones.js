import {
    obtenerNotificacionesPorUsuario,
    obtenerNotificacionPorId,
    crearNotificacion,
    marcarNotificacionComoLeida,
    eliminarNotificacion
} from "../models/notificaciones.js";


// Obtener las notificaciones del usuario autenticado
export const listarNotificaciones = async (req, res) => {

    try {

        const id_usuario = req.usuario.id_usuario;

        const { data, error } =
            await obtenerNotificacionesPorUsuario(id_usuario);

        if (error) {

            console.error(
                "Error al obtener notificaciones:",
                error
            );

            return res.status(500).json({
                error: "Error al obtener las notificaciones"
            });
        }

        return res.status(200).json(data);

    } catch (error) {

        console.error(
            "Error en listarNotificaciones:",
            error
        );

        return res.status(500).json({
            error: error.message
        });
    }
};


// Obtener una notificación específica
export const obtenerNotificacion = async (req, res) => {

    try {

        const { id_notificacion } = req.params;

        const { data, error } =
            await obtenerNotificacionPorId(id_notificacion);

        if (error || !data) {

            return res.status(404).json({
                error: "Notificación no encontrada"
            });
        }

        // Verificar que pertenece al usuario
        if (data.id_usuario !== req.usuario.id_usuario) {

            return res.status(403).json({
                error: "No tienes permiso para ver esta notificación"
            });
        }

        return res.status(200).json(data);

    } catch (error) {

        console.error(
            "Error al obtener notificación:",
            error
        );

        return res.status(500).json({
            error: error.message
        });
    }
};


// Crear una notificación
export const registrarNotificacion = async (req, res) => {

    try {

        const { titulo, mensaje } = req.body;

        if (!titulo || !mensaje) {

            return res.status(400).json({
                error: "El título y el mensaje son requeridos"
            });
        }

        const id_usuario = req.usuario.id_usuario;

        const { data, error } =
            await crearNotificacion({
                titulo,
                mensaje,
                leido: false,
                id_usuario
            });

        if (error) {

            console.error(
                "Error al crear notificación:",
                error
            );

            return res.status(500).json({
                error: "Error al crear la notificación",
                detalle: error.message
            });
        }

        return res.status(201).json({
            message: "Notificación creada correctamente",
            notificacion: data
        });

    } catch (error) {

        console.error(
            "Error al registrar notificación:",
            error
        );

        return res.status(500).json({
            error: error.message
        });
    }
};


// Marcar una notificación como leída
export const marcarComoLeida = async (req, res) => {

    try {

        const { id_notificacion } = req.params;

        // Primero verificar que pertenece al usuario
        const { data: notificacion, error: errorConsulta } =
            await obtenerNotificacionPorId(id_notificacion);

        if (errorConsulta || !notificacion) {

            return res.status(404).json({
                error: "Notificación no encontrada"
            });
        }

        if (notificacion.id_usuario !== req.usuario.id_usuario) {

            return res.status(403).json({
                error: "No tienes permiso para modificar esta notificación"
            });
        }

        const { data, error } =
            await marcarNotificacionComoLeida(id_notificacion);

        if (error) {

            return res.status(500).json({
                error: "Error al marcar la notificación como leída"
            });
        }

        return res.status(200).json({
            message: "Notificación marcada como leída",
            notificacion: data
        });

    } catch (error) {

        console.error(
            "Error al marcar notificación:",
            error
        );

        return res.status(500).json({
            error: error.message
        });
    }
};


// Eliminar una notificación
export const borrarNotificacion = async (req, res) => {

    try {

        const { id_notificacion } = req.params;

        // Verificar propietario
        const { data: notificacion, error: errorConsulta } =
            await obtenerNotificacionPorId(id_notificacion);

        if (errorConsulta || !notificacion) {

            return res.status(404).json({
                error: "Notificación no encontrada"
            });
        }

        if (notificacion.id_usuario !== req.usuario.id_usuario) {

            return res.status(403).json({
                error: "No tienes permiso para eliminar esta notificación"
            });
        }

        const { data, error } =
            await eliminarNotificacion(id_notificacion);

        if (error) {

            return res.status(500).json({
                error: "Error al eliminar la notificación"
            });
        }

        return res.status(200).json({
            message: "Notificación eliminada correctamente",
            notificacion: data
        });

    } catch (error) {

        console.error(
            "Error al eliminar notificación:",
            error
        );

        return res.status(500).json({
            error: error.message
        });
    }
};