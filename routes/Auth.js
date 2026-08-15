import express from "express";
import { registro,login } from "../controllers/Auth.js";

const router = express.Router();

//Rutas de autenticacion
router.post('/register', registro);
router.post('/login', login);

export default router;
