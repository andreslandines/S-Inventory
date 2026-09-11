import{supabase} from '../config/supabase.js';

export const obtenerTodos = async () => {
    const { data, error } = await
supabase.from ('productos').select ('*');
    return { data, error };
};


export const obtenerPorId = async (id_productos) => {
    const { data, error } = await supabase
        .from ('productos').select ('*').eq('id_productos', id_productos).single ();
    return { data, error };
};


export const obtenerPorCategoria = async (categoria) => {
        const { data, error } = await supabase

.from ('productos').select ('*').eq ('categoria', categoria);
    return { data, error };
};


export const crearproductos = async (productosData) => {
        const { data, error } = await supabase

.from ('productos').insert (productosData).select ();
    return { data, error };
};


export const actualizarproductos = async (id_productos,productosData) => {
    const { data, error } = await supabase

.from ('productos').update (productosData).eq ('id_productos',id_productos).select ();
return { data, error };
};


export const eliminarproductos = async (id_productos) =>
{
    const { data, error } = await supabase
.from ('productos').delete().eq('id_productos', id_productos);
return { data, error };
};
