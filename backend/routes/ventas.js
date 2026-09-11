import express from "express";

import { listarVentas, registrarVenta, obtenerVenta } from "../controllers/ventas.js";

const router = express.Router();


// Obtener todas las ventas
router.get('/', listarVentas);
// Obtener una venta por ID
router.get('/:id_venta', obtenerVenta);
// Registrar una venta
router.post('/registrar', registrarVenta);

export default router;