import express from "express";

import {
    listarNotificaciones,
    obtenerNotificacion,
    registrarNotificacion,
    marcarComoLeida,
    borrarNotificacion
} from "../controllers/notificaciones.js";

import { verificarToken } from "../middlewares/authmiddlewares.js";

const router = express.Router();


// Obtener mis notificaciones
router.get("/", verificarToken, listarNotificaciones);


// Obtener una notificación específica
router.get("/:id_notificacion", verificarToken, obtenerNotificacion);


// Crear una notificación
router.post("/", verificarToken, registrarNotificacion);


// Marcar como leída
router.put("/:id_notificacion/leida", verificarToken, marcarComoLeida);


// Eliminar una notificación
router.delete("/:id_notificacion", verificarToken, borrarNotificacion);


export default router;