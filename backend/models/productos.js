
import { supabase } from '../config/supabase.js';

export const obtenerTodos = async () => {
    const { data, error } = await supabase
        .from('productos')
        .select('*')
        .eq('activo', true);

    return { data, error };
};

export const obtenerPorId = async (id_productos) => {
    const { data, error } = await supabase
        .from('productos')
        .select('*')
        .eq('id_productos', id_productos)
        .single();

    return { data, error };
};

export const obtenerPorCategoria = async (categoria) => {
    const { data, error } = await supabase
        .from('productos')
        .select('*')
        .eq('categoria', categoria);

    return { data, error };
};

// Crear producto y su primer lote en una sola operación.
export const crearProductoConLote = async ({
    nombre,
    descripcion,
    precio,
    categoria,
    imagen,
    stock,
    codigo_barras,
    fecha_vencimiento
}) => {
    const { data, error } = await supabase.rpc(
        'crear_producto_con_lote',
        {
            p_nombre: nombre,
            p_descripcion: descripcion,
            p_precio: Number(precio),
            p_categoria: categoria,
            p_imagen: imagen,
            p_stock_inicial: Number(stock),
            p_codigo_barras: codigo_barras || null,
            // Fecha del primer lote. Va como null cuando no se selecciona.
            p_fecha_vencimiento: fecha_vencimiento || null
        }
    );

    return { data, error };
};

export const crearproductos = async (productosData) => {
    const { data, error } = await supabase
        .from('productos')
        .insert(productosData)
        .select();

    return { data, error };
};

export const actualizarproductos = async (id_productos, productosData) => {
    const { data, error } = await supabase
        .from('productos')
        .update(productosData)
        .eq('id_productos', id_productos)
        .select();

    return { data, error };
};

export const eliminarproductos = async (id_productos) => {
    const { data, error } = await supabase
        .from('productos')
        .update({ activo: false })
        .eq('id_productos', id_productos)
        .select();

    return { data, error };
};
