import express from "express";

import { listarVencimientos, obtenerVencimiento, registrarVencimiento ,
editarVencimiento, borrarVencimiento, listarProximosAVencer} from "../controllers/vencimientos.js";

const router = express.Router();


// Obtener todos los vencimientos
router.get("/", listarVencimientos);


// Obtener próximos a vencer
router.get("/proximos", listarProximosAVencer);

// Obtener un vencimiento por ID
router.get("/:id_vencimiento", obtenerVencimiento);


// Registrar un vencimiento
router.post("/registrar", registrarVencimiento);


// Actualizar un vencimiento
router.put("/actualizar/:id_vencimiento", editarVencimiento);


// Eliminar un vencimiento
router.delete("/eliminar/:id_vencimiento", borrarVencimiento);


export default router;