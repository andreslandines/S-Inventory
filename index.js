import express from 'express';
import dotev from 'dotenv';
import{conectaDB,supabase} from "./config/supabase.js";
import AuthRoutes from "./routes/Auth.js";
import UsuariosRoutes from "./routes/usuarios.js";
import productosRoutes from "./routes/productos.js";
import ventasRoutes from "./routes/ventas.js";
import vencimientosRoutes from "./routes/vencimientos.js";
import notificacionesRoutes from "./routes/notificaciones.js";
import cors from 'cors';

//CARGAR VARIABLES
dotev.config();

//CREAMOS LA APLICACION DE EXPRESS
const app = express();

//LEER EL JSON
app.use(express.json());
app.use(cors());

//CREAMOS LA RUTA
app.get('/',(req,res)=>{
    res.json({
        Mensaje:"Bienvenido al BACKEND de MIMOS",
        Estado: "En linea",
        Version:"1.0.0"
    })
})


//ruta de autenticacion
app.use('/Auth', AuthRoutes);
app.use('/usuarios', UsuariosRoutes);
app.use('/pro', productosRoutes);
app.use('/ventas', ventasRoutes);
app.use('/vencimientos', vencimientosRoutes);
app.use('/notificaciones', notificacionesRoutes);


//CONFIGURAMOS EL PUERTO 

const PORT = 3000;

//PONER A ESCUCHAR EL SERVIDOR
app.listen(PORT,()=>{
    console.log(`Servidor escuchando el puerto ${PORT}`);
    console.log(`http://localhost:${PORT}`);
});