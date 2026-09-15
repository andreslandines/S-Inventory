import express from "express";
import { chatearConBoxIA,obtenerHistorial } from "../controllers/chatbot.js";

const router = express.Router();

//ruta para chatear con BoxIA
router.post('/', chatearConBoxIA);
router.get('/historial/:sesionId', obtenerHistorial);

export default router;