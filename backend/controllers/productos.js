
import {
  obtenerTodos,
  obtenerPorId,
  obtenerPorCategoria,
  crearProductoConLote,
  actualizarproductos,
  eliminarproductos,
} from '../models/productos.js';

// Fecha actual de Colombia (YYYY-MM-DD).
const obtenerFechaColombia = () => {
  const partes = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'America/Bogota',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).formatToParts(new Date());

  const obtener = (tipo) =>
    partes.find((parte) => parte.type === tipo)?.value;

  return `${obtener('year')}-${obtener('month')}-${obtener('day')}`;
};

// Valida que una fecha YYYY-MM-DD exista realmente.
const validarFecha = (fecha) => {
  if (typeof fecha !== 'string') return false;

  const coincidencia = fecha.match(/^(\d{4})-(\d{2})-(\d{2})$/);

  if (!coincidencia) return false;

  const anio = Number(coincidencia[1]);
  const mes = Number(coincidencia[2]);
  const dia = Number(coincidencia[3]);

  const fechaUTC = new Date(Date.UTC(anio, mes - 1, dia));

  return (
    fechaUTC.getUTCFullYear() === anio &&
    fechaUTC.getUTCMonth() === mes - 1 &&
    fechaUTC.getUTCDate() === dia
  );
};

// LISTAR PRODUCTOS
export const listarproductos = async (req, res) => {
  try {
    const { data, error } = await obtenerTodos();

    if (error) {
      console.error('Error al listar productos:', error);

      return res.status(500).json({
        error: 'Error al obtener productos',
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
        error: 'Producto no encontrado',
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
      console.error('Error al buscar por categoría:', error);

      return res.status(500).json({
        error: 'Error al obtener productos por categoría',
      });
    }

    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({
      error: error.message,
    });
  }
};

// REGISTRAR PRODUCTO CON SU PRIMER LOTE
export const crear = async (req, res) => {
  try {
    const {
      nombre,
      descripcion,
      precio,
      categoria,
      stock,
      imagen_url,
      codigo_barras,
      fecha_vencimiento,
    } = req.body;

    const imagen = req.file?.path || imagen_url;

    // Validaciones básicas
    if (!nombre?.trim() || !precio || !imagen) {
      return res.status(400).json({
        error: 'Nombre, precio e imagen son obligatorios',
      });
    }

    const precioNumerico = Number(precio);
    const stockInicial = Number(stock ?? 0);

    if (!Number.isFinite(precioNumerico) || precioNumerico <= 0) {
      return res.status(400).json({
        error: 'El precio debe ser mayor a cero',
      });
    }

    if (
      !Number.isInteger(stockInicial) ||
      stockInicial < 0 ||
      stockInicial > 100
    ) {
      return res.status(400).json({
        error: 'El stock inicial debe ser un número entero entre 0 y 100',
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

    // Fecha de vencimiento opcional del primer lote.
    let fechaVencimiento = null;

    if (
      fecha_vencimiento !== undefined &&
      fecha_vencimiento !== null &&
      String(fecha_vencimiento).trim() !== ''
    ) {
      const fecha = String(fecha_vencimiento).trim();

      if (!validarFecha(fecha)) {
        return res.status(400).json({
          error: 'La fecha de vencimiento no es válida. Use YYYY-MM-DD',
        });
      }

      if (fecha < obtenerFechaColombia()) {
        return res.status(400).json({
          error: 'No se puede registrar un lote con fecha de vencimiento pasada',
        });
      }

      fechaVencimiento = fecha;
    }

    // Producto y primer lote se registran mediante una sola función SQL.
    const { data, error } = await crearProductoConLote({
      nombre: nombre.trim(),
      descripcion,
      precio: precioNumerico,
      categoria,
      stock: stockInicial,
      imagen,
      codigo_barras: codigo_barras?.trim() || null,
      fecha_vencimiento: fechaVencimiento,
    });

    if (error) {
      console.error('Error al crear producto con lote:', error);

      if (error.code === '23505') {
        return res.status(409).json({
          error: 'Ya existe un producto con ese código de barras.',
        });
      }

      if (error.code === 'P0001') {
        return res.status(400).json({
          error: error.message,
        });
      }

      return res.status(500).json({
        error: 'Error al crear el producto',
      });
    }

    return res.status(201).json({
      message: 'Producto registrado correctamente',
      producto: data?.producto,
      lote: data?.lote ?? null,
    });
  } catch (error) {
    console.error('Error al registrar producto:', error);

    return res.status(500).json({
      error: error.message,
    });
  }
};

// EDITAR PRODUCTO SIN MODIFICAR EL STOCK
export const editar = async (req, res) => {
  try {
    const { id_productos } = req.params;

    const {
      nombre,
      descripcion,
      precio,
      categoria,
      codigo_barras,
    } = req.body;

    // El stock no se recibe ni se actualiza desde esta operación.
    const productosData = {
      nombre: nombre?.trim(),
      descripcion,
      precio,
      categoria,
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
        error: 'Error al actualizar el producto',
      });
    }

    if (!data || data.length === 0) {
      return res.status(404).json({
        error: 'Producto no encontrado',
      });
    }

    return res.status(200).json({
      message: 'Producto actualizado correctamente',
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
