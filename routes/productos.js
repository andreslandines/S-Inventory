import express from 'express';
import { listarproductos, obtenerproductos, obtenerPorCat, crear, editar, eliminar } from '../controllers/productos.js';
import {verificarToken, verificarAdmin} from '../middlewares/authmiddlewares.js';
import { upload } from '../config/cloudinary.js';
const router = express.Router();


// GET - Obtener todos
router.get('/productos', listarproductos);

// GET - Obtener por ID
router.get('/productos/:id_productos', obtenerproductos);

// GET - Obtener por categoría
router.get('/productos/categoria/:categoria', obtenerPorCat);


//Rutas protegidas por token y rol de administrador

// POST - Crear producto
router.post('/productoscrear',verificarToken, verificarAdmin, upload.single('imagen'), crear);

// PUT - Actualizar producto
router.put('/productoseditar/:id_productos', verificarToken, verificarAdmin, upload.single('imagen'), editar);

// DELETE - Eliminar producto
router.delete('/productoseliminar/:id_productos', verificarToken, verificarAdmin,  eliminar);

export default router;