
import express from "express";
import { getUsuarioporId, getUsuarios, putUsuarioporId, deleteUsuario} from  "../controllers/usuarios.js";

const router = express.Router();


//ruta para obtener los usuarios 
router.get('/', getUsuarios);

//ruta para obtener un usuario por id
router.get('/:id_usuario', getUsuarioporId);

//ruta para actualizar un usuario por id
router.put('/actualizar:id_usuario', putUsuarioporId);

//ruta para eliminar usuario por id
router.delete('/eliminar:id_usuario', deleteUsuario);

export default router;