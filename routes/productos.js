import express from 'express';
import { listarproductos, obtenerproductos, obtenerPorCat, crear, editar, eliminar } from '../controllers/productos.js';
const router = express.Router();


// GET - Obtener todos
router.get('/productos', listarproductos);

// GET - Obtener por ID
router.get('/productos/:id_productos', obtenerproductos);

// GET - Obtener por categoría
router.get('/productos/categoria/:categoria', obtenerPorCat);


//Rutas protegidas por token y rol de administrador

// POST - Crear helado
router.post('/productoscrear', crear);

// PUT - Actualizar helado
router.put('/productoseditar/:id_productos',  editar);

// DELETE - Eliminar helado
router.delete('/productoseliminar/:id_productos',  eliminar);

export default router;