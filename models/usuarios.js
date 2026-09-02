//importamos la conexion a la base de datos
import{supabase} from "../config/supabase.js";

export const crearUsuarios = async (nombre, email, rol, contrasena) => {


    const resultado = await supabase
        .from('usuarios')
        .insert({
            nombre,
            email,
            rol,
            contrasena
        })
        .select('*');


    return resultado;
};

//OBTENER TODOS LOS USUARIOS
export const obtenerUsuarios = async ()=>{
    const {data,error}=await supabase
    .from('usuarios')
    .select('*')
    return {data,error};
};

//BUSCAR USUARIO POR EMAIL PARA EL LOGIN
export const obtenerPorEmail= async(email)=>{
    const{data,error}=await supabase 
    .from("usuarios")
    .select("*")
    .eq ('email', email)
    .single();
    return{data,error};
};

//Obtener un usuario por id
export const obtenerUsuarioPorId = async (id_usuario) => {
    const { data,error } = await supabase
        .from('usuarios')
        .select('id_usuario, nombre, email, rol')
        .eq('id_usuario', id_usuario)
        .single();
    return {data, error};
};

//actualizar su usuario
export const actualizarUsuario = async (id_usuario, campos) => {
    const { data, error } = await supabase
        .from('usuarios')
        .update(campos)
        .eq('id_usuario', id_usuario)
        .select('id_usuario, nombre, email, rol');
    return { data,error };
};


//eliminar un usuario
export const eliminarUsuario = async (id_usuario) => {
    const { data,error } = await supabase
        .from('usuarios')
        .delete()
        .eq('id_usuario', id_usuario)
        .select('id_usuario, nombre, email, rol')
        return { data,error };
};