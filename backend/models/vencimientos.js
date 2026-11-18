
import { supabase } from "../config/supabase.js";

// =====================================================
// OBTENER FECHA ACTUAL DE COLOMBIA
// =====================================================
const obtenerFechaColombia = () => {
    const partes = new Intl.DateTimeFormat("en-CA", {
        timeZone: "America/Bogota",
        year: "numeric",
        month: "2-digit",
        day: "2-digit"
    }).formatToParts(new Date());

    const obtener = (tipo) =>
        partes.find((parte) => parte.type === tipo)?.value;

    return `${obtener("year")}-${obtener("month")}-${obtener("day")}`;
};

// =====================================================
// OBTENER TODOS LOS LOTES
// =====================================================
export const obtenerVencimientos = async () => {
    const { data, error } = await supabase
        .from("vencimientos")
        .select(`
            *,
            productos (
                id_productos,
                nombre,
                categoria,
                stock
            )
        `)
        .order("fecha_vencimiento", {
            ascending: true,
            nullsFirst: false
        })
        .order("creado_en", {
            ascending: true
        })
        .order("id_vencimiento", {
            ascending: true
        });

    return { data, error };
};

// =====================================================
// OBTENER UN LOTE POR SU ID
// =====================================================
export const obtenerVencimientoPorId = async (id_vencimiento) => {
    const { data, error } = await supabase
        .from("vencimientos")
        .select(`
            *,
            productos (
                id_productos,
                nombre,
                categoria,
                stock
            )
        `)
        .eq("id_vencimiento", id_vencimiento)
        .single();

    return { data, error };
};

// =====================================================
// REGISTRAR UNA ENTRADA NUEVA MEDIANTE RPC
// =====================================================
export const registrarEntradaLote = async (
    id_producto,
    cantidad,
    fecha_vencimiento = null
) => {
    const { data, error } = await supabase.rpc(
        "registrar_entrada_lote",
        {
            p_id_producto: id_producto,
            p_cantidad: cantidad,
            p_fecha_vencimiento: fecha_vencimiento
        }
    );

    return { data, error };
};

// =====================================================
// ACTUALIZAR FECHA DE VENCIMIENTO DE UN LOTE
// =====================================================
export const actualizarVencimiento = async (
    id_vencimiento,
    vencimientoData
) => {
    const { data, error } = await supabase
        .from("vencimientos")
        .update(vencimientoData)
        .eq("id_vencimiento", id_vencimiento)
        .select(`
            *,
            productos (
                id_productos,
                nombre,
                categoria,
                stock
            )
        `)
        .single();

    return { data, error };
};

// =====================================================
// ELIMINAR UN LOTE
// =====================================================
export const eliminarVencimiento = async (id_vencimiento) => {
    const { data, error } = await supabase
        .from("vencimientos")
        .delete()
        .eq("id_vencimiento", id_vencimiento)
        .select()
        .single();

    return { data, error };
};

// =====================================================
// OBTENER LOTES PRÓXIMOS A VENCER
// =====================================================
export const obtenerProximosAVencer = async (dias = 30) => {
    const hoy = obtenerFechaColombia();

    const fechaLimite = new Date(`${hoy}T00:00:00Z`);
    fechaLimite.setUTCDate(fechaLimite.getUTCDate() + dias);

    const limite = fechaLimite.toISOString().split("T")[0];

    const { data, error } = await supabase
        .from("vencimientos")
        .select(`
            *,
            productos (
                id_productos,
                nombre,
                categoria,
                stock
            )
        `)
        .gte("fecha_vencimiento", hoy)
        .lte("fecha_vencimiento", limite)
        .gt("cantidad_disponible", 0)
        .order("fecha_vencimiento", {
            ascending: true
        })
        .order("creado_en", {
            ascending: true
        })
        .order("id_vencimiento", {
            ascending: true
        });

    return { data, error };
};

// =====================================================
// OBTENER LOTES YA VENCIDOS
// =====================================================
export const obtenerLotesVencidos = async () => {
    const hoy = obtenerFechaColombia();

    const { data, error } = await supabase
        .from("vencimientos")
        .select(`
            *,
            productos (
                id_productos,
                nombre,
                categoria,
                stock
            )
        `)
        .lt("fecha_vencimiento", hoy)
        .gt("cantidad_disponible", 0)
        .order("fecha_vencimiento", {
            ascending: true
        })
        .order("creado_en", {
            ascending: true
        })
        .order("id_vencimiento", {
            ascending: true
        });

    return { data, error };
};
