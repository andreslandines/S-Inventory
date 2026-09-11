import { supabase } from "../config/supabase.js";

// Obtener todos los vencimientos
export const obtenerVencimientos = async () => {

    const { data, error } = await supabase
        .from('vencimientos')
        .select('*')
        .order('fecha_vencimiento', { ascending: true });

    return { data, error };
};


// Obtener un vencimiento por ID
export const obtenerVencimientoPorId = async (id_vencimiento) => {

    const { data, error } = await supabase
        .from('vencimientos')
        .select('*')
        .eq('id_vencimiento', id_vencimiento)
        .single();

    return { data, error };
};


// Crear un vencimiento
export const crearVencimiento = async (vencimientoData) => {

    const { data, error } = await supabase
        .from('vencimientos')
        .insert(vencimientoData)
        .select()
        .single();

    return { data, error };
};


// Actualizar un vencimiento
export const actualizarVencimiento = async (id_vencimiento, vencimientoData) => {

    const { data, error } = await supabase
        .from('vencimientos')
        .update(vencimientoData)
        .eq('id_vencimiento', id_vencimiento)
        .select()
        .single();

    return { data, error };
};


// Eliminar un vencimiento
export const eliminarVencimiento = async (id_vencimiento) => {

    const { data, error } = await supabase
        .from('vencimientos')
        .delete()
        .eq('id_vencimiento', id_vencimiento)
        .select()
        .single();

    return { data, error };
};

// Obtener productos próximos a vencer
export const obtenerProximosAVencer = async (dias) => {

    const fechaActual = new Date();

    const fechaLimite = new Date();
    fechaLimite.setDate(fechaActual.getDate() + dias);

    const { data, error } = await supabase
        .from('vencimientos')
        .select(`
            *,
            productos (
                id_productos,
                nombre,
                stock
            )
        `)
        .gte('fecha_vencimiento', fechaActual.toISOString().split('T')[0])
        .lte('fecha_vencimiento', fechaLimite.toISOString().split('T')[0])
        .order('fecha_vencimiento', { ascending: true });

    return { data, error };
};