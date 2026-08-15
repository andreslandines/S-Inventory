import express from 'express';
import dotev from 'dotenv';
import{conectaDB,supabase} from "./config/supabase.js";
import AuthRoutes from "./routes/Auth.js";
import UsuariosRoutes from "./routes/usuarios.js";
import cors from 'cors';

//CARGAR VARIABLES
dotev.config();

//CREAMOS LA APLICACION DE EXPRESS
const app = express();

//LEER EL JSON
app.use(express.json());
app.use(cors());


//ruta de autenticacion
app.use('/Auth', AuthRoutes);
app.use('/usuarios', UsuariosRoutes);


//CONFIGURAMOS EL PUERTO 

const PORT = 3000;

//PONER A ESCUCHAR EL SERVIDOR
app.listen(PORT,()=>{
    console.log(`Servidor escuchando el puerto ${PORT}`);
    console.log(`http://localhost:${PORT}`);
});