import express from "express";
import { chatearConBoxIA } from "../controllers/chatbot.js";

const router = express.Router();

//ruta para chatear con BoxIA
router.post('/', chatearConBoxIA);
router.get('/historial/:sesionId', chatearConBoxIA);

export default router;