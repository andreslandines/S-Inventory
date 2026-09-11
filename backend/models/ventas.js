import { supabase } from "../config/supabase.js";

// Obtener todas las ventas
export const obtenerVentas = async () => {

    const { data, error } = await supabase
        .from('ventas')
        .select('*')
        .order('fecha', { ascending: false });

    return { data, error };
};


// Obtener una venta por ID
export const obtenerVentaPorId = async (id_venta) => {

    const { data, error } = await supabase
        .from('ventas')
        .select('*')
        .eq('id_venta', id_venta)
        .single();

    return { data, error };
};

// Obtener los detalles de una venta
export const obtenerDetallesVenta = async (id_venta) => {

    const { data, error } = await supabase
        .from('detalle_ventas')
        .select('*')
        .eq('id_venta', id_venta);

    return { data, error };
};


// Crear una venta
export const crearVenta = async (ventaData) => {

    const { data, error } = await supabase
        .from('ventas')
        .insert(ventaData)
        .select()
        .single();

    return { data, error };
};


// Crear detalle de una venta
export const crearDetalleVenta = async (detalleData) => {

    const { data, error } = await supabase
        .from('detalle_ventas')
        .insert(detalleData)
        .select()
        .single();

    return { data, error };
};

// Actualizar el stock de un producto
export const actualizarStock = async (id_producto, nuevoStock) => {

    const { data, error } = await supabase
        .from('productos')
        .update({
            stock: nuevoStock,
            actualizado_en: new Date().toISOString()
        })
        .eq('id_productos', id_producto)
        .select()
        .single();

    return { data, error };
};


// Crear movimiento de inventario
export const crearMovimiento = async (movimientoData) => {

    const { data, error } = await supabase
        .from('movimientos')
        .insert(movimientoData)
        .select()
        .single();

    return { data, error };
};