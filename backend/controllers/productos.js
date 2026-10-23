import { obtenerTodos, obtenerPorId, obtenerPorCategoria, crearproductos, actualizarproductos,
eliminarproductos } from '../models/productos.js';

export const listarproductos = async (req, res) => {
  try {
    const { data, error } = await obtenerTodos();
    if (error) return res.status(500).json({ error: 'Error al obtener' });
    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

export const obtenerproductos = async (req, res) => {
  try {
    const { id_productos } = req.params;
    const { data, error } = await obtenerPorId(id_productos);
    if (error || !data) return res.status(404).json({ error: 'No encontrado' });
    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

export const obtenerPorCat = async (req, res) => {
  try {
    const { categoria } = req.params;
    const { data, error } = await obtenerPorCategoria(categoria);
    if (error) return res.status(500).json({ error: 'Error' });
    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }

};


export const crear = async (req, res) => {
  try {
    const { nombre, descripcion, precio, categoria, stock, imagen_url } =
      req.body;

    const imagen = req.file?.path || imagen_url;

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

    const { data, error } = await crearproductos({
      nombre: nombre.trim(),
      descripcion,
      precio,
      categoria,
      stock: stock ?? 0,
      imagen,
    });

    if (error) {
      return res.status(500).json({ error: 'Error al crear producto' });
    }

    return res.status(201).json({
      message: 'Creado',
      producto: data?.[0],
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};


export const editar = async (req, res) => {
  try {
    const { id_productos } = req.params;
    const { data, error } = await actualizarproductos(id_productos, req.body);
    if (error) return res.status(500).json({ error: 'Error al actualizar' });
    return res.status(200).json({ message: 'Actualizado', productos: data[0] });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};


export const eliminar = async (req, res) => {
  try {
    const { id_productos } = req.params;

    const { data, error } = await eliminarproductos(id_productos);

    if (error) {
      console.error('Error al eliminar producto:', error);

      if (error.code === '23503') {
        return res.status(409).json({
          error: 'No se puede eliminar este producto porque tiene ventas o movimientos asociados.'
        });
      }

      return res.status(500).json({
        error: 'Error al eliminar el producto.'
      });
    }

    if (!data || data.length === 0) {
      return res.status(404).json({
        error: 'Producto no encontrado.'
      });
    }

    return res.status(200).json({
      message: 'Producto eliminado correctamente.'
    });
  } catch (error) {
    console.error('Error inesperado al eliminar:', error);

    return res.status(500).json({
      error: 'Error interno al eliminar el producto.'
    });
  }
};