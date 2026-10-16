// VARIABLES DE ENTORNO
import 'dotenv/config'; 
import WebSocket from 'ws'; // NUEVO: Conexión a Supabase con transporte WebSocket para Node.js
import { createClient } from '@supabase/supabase-js';

// CREACION DE LA CONEXION A SUPABASE
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;
console.log("🔗 SUPABASE_URL:", supabaseUrl);

// VARIABLES DE CONEXION
if (!supabaseUrl || !supabaseKey) {
    console.error("❌ Error: Las variables de entorno SUPABASE_URL y SUPABASE_KEY son requeridas");
}

// CONEXION A SUPABASE
export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false,
  },
  realtime: {            // NUEVO: todo este bloque
    transport: WebSocket,
  },
});

export const conectaDB = () => {
    console.log("✅ Conexion a supabase establecida correctamente");
};