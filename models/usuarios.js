import { supabase } from "../config/supabase.js";

// CREAR USUARIO
export const crearUsuarios = async (
    nombre,
    email,
    rol,
    contrasena,
    CodigoVerificacion,
    codigoVerificacionExpiracion
) => {

    const { data, error } = await supabase
        .from('usuarios')
        .insert({
            nombre,
            email,
            rol,
            contrasena,
            CodigoVerificacion,
            codigoVerificacionExpiracion
        })
        .select('id_usuario,nombre,email,rol')

    return { data, error };
};


// OBTENER TODOS LOS USUARIOS
export const obtenerUsuarios = async () => {

    const { data, error } = await supabase
        .from('usuarios')
        .select('*');

    return { data, error };
};


// BUSCAR USUARIO POR EMAIL
export const obtenerPorEmail = async (email) => {

    const { data, error } = await supabase
        .from('usuarios')
        .select('*')
        .eq('email', email)
        .maybeSingle();

    return { data, error };
};


// OBTENER USUARIO POR ID
export const obtenerUsuarioPorId = async (id_usuario) => {

    const { data, error } = await supabase
        .from('usuarios')
        .select('id_usuario,nombre,email,rol')
        .eq('id_usuario', id_usuario)
        .single();

    return { data, error };
};


// ACTUALIZAR USUARIO
export const actualizarUsuario = async (id_usuario, campos) => {

    const { data, error } = await supabase
        .from('usuarios')
        .update(campos)
        .eq('id_usuario', id_usuario)
        .select('id_usuario,nombre,email,rol');

    return { data, error };
};


// ELIMINAR USUARIO
export const eliminarUsuario = async (id_usuario) => {

    const { data, error } = await supabase
        .from('usuarios')
        .delete()
        .eq('id_usuario', id_usuario)
        .select('id_usuario,nombre,email,rol');

    return { data, error };
};