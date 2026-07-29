import express from 'express';
import dotev from 'dotenv';
import{conectaDB,supabase} from "./config/supabase.js";


dotev.config();

//CREAMOS LA APLICACION DE EXPRESS
const app = express();

//LEER EL JSON
app.use(express.json());

//CONFIGURAMOS EL PUERTO 

const PORT = 3000;

//PONER A ESCUCHAR EL SERVIDOR
app.listen(PORT,()=>{
    console.log(`Servidor escuchando el puerto ${PORT}`);
    console.log(`http://localhost:${PORT}`);
});