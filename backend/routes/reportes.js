import express from "express";
import { generarInformeSemanal } from "../controllers/reportes.js";

const router = express.Router();

router.post("/informe-semanal", generarInformeSemanal);

export default router;