
import { supabase } from "../config/supabase.js";

// Obtener todas las ventas
export const obtenerVentas = async () => {
    const { data, error } = await supabase
        .from("ventas")
        .select("*")
        .order("fecha", { ascending: false });

    return { data, error };
};

// Obtener una venta por ID
export const obtenerVentaPorId = async (id_venta) => {
    const { data, error } = await supabase
        .from("ventas")
        .select("*")
        .eq("id_venta", id_venta)
        .single();

    return { data, error };
};

// Obtener los detalles de una venta
export const obtenerDetallesVenta = async (id_venta) => {
    const { data, error } = await supabase
        .from("detalle_ventas")
        .select("*")
        .eq("id_venta", id_venta);

    return { data, error };
};

// Obtener los lotes disponibles de un producto (FEFO: vencen primero).
export const obtenerLotesDisponibles = async (id_producto) => {
    const { data, error } = await supabase
        .from("vencimientos")
        .select(
            "id_vencimiento, cantidad_disponible, fecha_vencimiento"
        )
        .eq("id_producto", id_producto)
        .gt("cantidad_disponible", 0)
        .order("fecha_vencimiento", { ascending: true });

    return { data, error };
};

// Descontar la cantidad disponible de un lote.
export const actualizarCantidadLote = async (
    id_vencimiento,
    cantidad_disponible
) => {
    const { data, error } = await supabase
        .from("vencimientos")
        .update({ cantidad_disponible })
        .eq("id_vencimiento", id_vencimiento)
        .select()
        .single();

    return { data, error };
};

// Trazabilidad: detalle_venta_lotes usa id_detalle (no id_venta).
export const crearDetalleVentaLote = async (detalle) => {
    const { data, error } = await supabase
        .from("detalle_venta_lotes")
        .insert(detalle)
        .select()
        .single();

    return { data, error };
};

// Funciones auxiliares usadas por el controlador de ventas:
// escriben ventas, detalles, stock y movimientos con las columnas reales.

export const crearVenta = async (ventaData) => {
    const { data, error } = await supabase
        .from("ventas")
        .insert(ventaData)
        .select()
        .single();

    return { data, error };
};

export const crearDetalleVenta = async (detalleData) => {
    const { data, error } = await supabase
        .from("detalle_ventas")
        .insert(detalleData)
        .select()
        .single();

    return { data, error };
};

export const actualizarStock = async (id_producto, nuevoStock) => {
    const { data, error } = await supabase
        .from("productos")
        .update({
            stock: nuevoStock,
            actualizado_en: new Date().toISOString()
        })
        .eq("id_productos", id_producto)
        .select()
        .single();

    return { data, error };
};

export const crearMovimiento = async (movimientoData) => {
    const { data, error } = await supabase
        .from("movimientos")
        .insert(movimientoData)
        .select()
        .single();

    return { data, error };
};
