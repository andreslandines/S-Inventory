import { Router } from "express";
import { autenticarConGoogle } from "../controllers/googleauth.controller.js";

const router = Router();

// Endpoint: POST /api/auth/google
router.post("/google", autenticarConGoogle);

export default router;