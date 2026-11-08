
import {
  obtenerTodos,
  obtenerPorId,
  obtenerPorCategoria,
  crearproductos,
  actualizarproductos,
  eliminarproductos,
} from '../models/productos.js';

// LISTAR PRODUCTOS
export const listarproductos = async (req, res) => {
  try {
    const { data, error } = await obtenerTodos();

    if (error) {
      return res.status(500).json({
        error: 'Error al obtener',
      });
    }

    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({
      error: error.message,
    });
  }
};

// OBTENER PRODUCTO POR ID
export const obtenerproductos = async (req, res) => {
  try {
    const { id_productos } = req.params;

    const { data, error } = await obtenerPorId(id_productos);

    if (error || !data) {
      return res.status(404).json({
        error: 'No encontrado',
      });
    }

    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({
      error: error.message,
    });
  }
};

// OBTENER PRODUCTOS POR CATEGORÍA
export const obtenerPorCat = async (req, res) => {
  try {
    const { categoria } = req.params;

    const { data, error } = await obtenerPorCategoria(categoria);

    if (error) {
      return res.status(500).json({
        error: 'Error',
      });
    }

    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({
      error: error.message,
    });
  }
};

// REGISTRAR PRODUCTO
export const crear = async (req, res) => {
  console.log('========== REGISTRO DE PRODUCTO ==========');
console.log('BODY COMPLETO:', req.body);
console.log('CÓDIGO DE BARRAS RECIBIDO:', req.body.codigo_barras);
console.log('==========================================');
  try {
    const {
      nombre,
      descripcion,
      precio,
      categoria,
      stock,
      imagen_url,
      codigo_barras,
    } = req.body;

    const imagen = req.file?.path || imagen_url;
    console.log('DATOS RECIBIDOS:', req.body);
console.log('CODIGO DE BARRAS:', req.body.codigo_barras);

    if (!nombre?.trim() || !precio || !imagen) {
      return res.status(400).json({
        error: 'nombre, precio e imagen requeridos',
      });
    }

    // Las URL externas deben ser HTTPS y de Cloudinary.
    if (!req.file) {
      let url;

      try {
        url = new URL(imagen);
      } catch {
        return res.status(400).json({
          error: 'La URL de imagen no es válida',
        });
      }

      if (
        url.protocol !== 'https:' ||
        url.hostname !== 'res.cloudinary.com'
      ) {
        return res.status(400).json({
          error: 'Usa una URL HTTPS de Cloudinary',
        });
      }
    }
    console.log('DATOS QUE SE ENVIARÁN A SUPABASE:', {
  nombre: nombre.trim(),
  descripcion,
  precio,
  categoria,
  stock: stock ?? 0,
  imagen,
  codigo_barras: codigo_barras?.trim() || null,
});


    const { data, error } = await crearproductos({
      nombre: nombre.trim(),
      descripcion,
      precio,
      categoria,
      stock: stock ?? 0,
      imagen,
      codigo_barras: codigo_barras?.trim() || null,
    });

    if (error) {
      console.error('Error al crear producto:', error);

      if (error.code === '23505') {
        return res.status(409).json({
          error: 'Ya existe un producto con ese código de barras.',
        });
      }

      return res.status(500).json({
        error: 'Error al crear producto',
      });
    }

    return res.status(201).json({
      message: 'Creado',
      producto: data?.[0],
    });
  } catch (error) {
    console.error('Error al registrar producto:', error);

    return res.status(500).json({
      error: error.message,
    });
  }
};

// EDITAR PRODUCTO
export const editar = async (req, res) => {
  try {
    const { id_productos } = req.params;

    const {
      nombre,
      descripcion,
      precio,
      categoria,
      stock,
      codigo_barras,
    } = req.body;

    // Construimos los datos que se van a actualizar.
    const productosData = {
      nombre: nombre?.trim(),
      descripcion,
      precio,
      categoria,
      stock,
      codigo_barras: codigo_barras?.trim() || null,
    };

    // Solo actualizamos la imagen si se seleccionó una nueva.
    if (req.file?.path) {
      productosData.imagen = req.file.path;
    }

    // Evitamos enviar campos indefinidos a Supabase.
    Object.keys(productosData).forEach((campo) => {
      if (productosData[campo] === undefined) {
        delete productosData[campo];
      }
    });

    const { data, error } = await actualizarproductos(
      id_productos,
      productosData,
    );

    if (error) {
      console.error('Error al actualizar producto:', error);

      if (error.code === '23505') {
        return res.status(409).json({
          error: 'Ya existe un producto con ese código de barras.',
        });
      }

      return res.status(500).json({
        error: 'Error al actualizar',
      });
    }

    if (!data || data.length === 0) {
      return res.status(404).json({
        error: 'Producto no encontrado',
      });
    }

    return res.status(200).json({
      message: 'Actualizado',
      productos: data[0],
    });
  } catch (error) {
    console.error('Error al editar producto:', error);

    return res.status(500).json({
      error: error.message,
    });
  }
};

// ELIMINAR PRODUCTO
export const eliminar = async (req, res) => {
  try {
    const { id_productos } = req.params;

    const { data, error } = await eliminarproductos(id_productos);

    if (error) {
      console.error('Error al eliminar producto:', error);

      if (error.code === '23503') {
        return res.status(409).json({
          error:
            'No se puede eliminar este producto porque tiene ventas o movimientos asociados.',
        });
      }

      return res.status(500).json({
        error: 'Error al eliminar el producto.',
      });
    }

    if (!data || data.length === 0) {
      return res.status(404).json({
        error: 'Producto no encontrado.',
      });
    }

    return res.status(200).json({
      message: 'Producto eliminado correctamente.',
    });
  } catch (error) {
    console.error('Error inesperado al eliminar:', error);

    return res.status(500).json({
      error: 'Error interno al eliminar el producto.',
    });
  }
};
