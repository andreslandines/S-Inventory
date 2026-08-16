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
    const { nombre, descripcion, precio, categoria, stock, imagen  } =
req.body;
    if (!nombre || !precio || !imagen) {
      return res.status(400).json({ error: 'nombre, precio e imagen requeridos' });
    }
    const { data, error } = await crearproductos({
      nombre, descripcion, precio, categoria, stock, imagen
    });
    if (error) return res.status(500).json({ error: 'Error al crear' });
    return res.status(201).json({ message: 'Creado', producto: data[0] });
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
    const { error } = await eliminarproductos(id_productos);
    if (error) return res.status(500).json({ error: 'Error al eliminar' });
    return res.status(200).json({ message: 'Eliminado' });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};