
import express from "express";

import {
    listarVencimientos,
    obtenerVencimiento,
    registrarVencimiento,
    editarVencimiento,
    borrarVencimiento,
    listarProximosAVencer,
    listarLotesVencidos
} from "../controllers/vencimientos.js";

import {
    verificarToken,
    verificarAdmin
} from "../middlewares/authmiddlewares.js";

const router = express.Router();

// Obtener todos los lotes
router.get("/", listarVencimientos);

// Obtener lotes próximos a vencer
router.get("/proximos", listarProximosAVencer);

// Obtener lotes ya vencidos
router.get("/vencidos", listarLotesVencidos);

// Obtener un lote por ID
router.get("/:id_vencimiento", obtenerVencimiento);

// Registrar una nueva entrada de inventario
router.post(
    "/registrar",
    verificarToken,
    verificarAdmin,
    registrarVencimiento
);

// Actualizar la fecha de un lote
router.put(
    "/actualizar/:id_vencimiento",
    verificarToken,
    verificarAdmin,
    editarVencimiento
);

// No permite eliminar lotes directamente
router.delete(
    "/eliminar/:id_vencimiento",
    verificarToken,
    verificarAdmin,
    borrarVencimiento
);

export default router;