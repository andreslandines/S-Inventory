import { supabase } from "../config/supabase.js";

// Obtener las notificaciones de un usuario
export const obtenerNotificacionesPorUsuario = async (id_usuario) => {

    const { data, error } = await supabase
        .from("notificaciones")
        .select("*")
        .eq("id_usuario", id_usuario)
        .order("creado_en", { ascending: false });

    return { data, error };
};


// Obtener una notificación por ID
export const obtenerNotificacionPorId = async (id_notificacion) => {

    const { data, error } = await supabase
        .from("notificaciones")
        .select("*")
        .eq("id_notificacion", id_notificacion)
        .single();

    return { data, error };
};


// Crear una notificación
export const crearNotificacion = async (notificacionData) => {

    const { data, error } = await supabase
        .from("notificaciones")
        .insert(notificacionData)
        .select()
        .single();

    return { data, error };
};


// Marcar como leída
export const marcarNotificacionComoLeida = async (id_notificacion) => {

    const { data, error } = await supabase
        .from("notificaciones")
        .update({
            leido: true
        })
        .eq("id_notificacion", id_notificacion)
        .select()
        .single();

    return { data, error };
};


// Eliminar una notificación
export const eliminarNotificacion = async (id_notificacion) => {

    const { data, error } = await supabase
        .from("notificaciones")
        .delete()
        .eq("id_notificacion", id_notificacion)
        .select()
        .single();

    return { data, error };
};