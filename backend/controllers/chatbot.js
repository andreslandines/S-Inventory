
import Groq from "groq-sdk";
import { supabase } from "../config/supabase.js";

const groq = new Groq({
    apiKey: process.env.GROQ_API_KEY
});

// ============================================
// FUNCIONES AUXILIARES
// ============================================

const normalizar = (texto = "") =>
    texto
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .trim();

const formatoPrecio = (precio) =>
    `$${Number(precio).toLocaleString("es-CO")} COP`;

const buscarProducto = (mensaje, productos, historial = []) => {
    const texto = normalizar(mensaje);

    // Buscar primero en el mensaje actual
    let encontrado = [...productos]
        .sort((a, b) => b.nombre.length - a.nombre.length)
        .find(p => texto.includes(normalizar(p.nombre)));

    // Si no menciona producto, recuperar el último consultado
    if (!encontrado) {
        for (const item of [...historial].reverse()) {
            if (item.emisor !== "user") continue;

            const textoAnterior = normalizar(item.mensaje);

            encontrado = productos
                .sort((a, b) => b.nombre.length - a.nombre.length)
                .find(p => textoAnterior.includes(normalizar(p.nombre)));

            if (encontrado) break;
        }
    }

    return encontrado || null;
};

// ============================================
// CHAT PRINCIPAL
// ============================================

export const chatearConBoxIA = async (req, res) => {
    try {
        const { mensaje, sesionId, usuarioId } = req.body;

        if (!mensaje || !mensaje.trim()) {
            return res.status(400).json({
                message: "Debes enviar un mensaje."
            });
        }

        const mensajeLimpio = mensaje.trim();

        const idSesionValido =
            sesionId || `S-Inventory_sesion_${Date.now()}`;

        // ============================================
        // 1. CONSULTAR PRODUCTOS
        // ============================================

        const { data: productos, error: errorProductos } =
            await supabase
                .from("productos")
                .select(`
                    id_productos,
                    nombre,
                    descripcion,
                    stock,
                    precio,
                    categoria
                `);

        if (errorProductos) {
            console.error(errorProductos.message);

            return res.status(500).json({
                message: "Error al consultar el inventario."
            });
        }

        // ============================================
        // 2. CONSULTAR HISTORIAL
        // ============================================

        const { data: historial, error: errorHistorial } =
            await supabase
                .from("mensaje_chat")
                .select("emisor, mensaje")
                .eq("sesion_id", idSesionValido)
                .order("created_at", { ascending: true });

        if (errorHistorial) {
            console.error(errorHistorial.message);

            return res.status(500).json({
                message: "Error al consultar el historial."
            });
        }

        const mensajesAnteriores = historial || [];

        const yaFueSaludado = mensajesAnteriores.some(
            m =>
                m.emisor === "bot" &&
                /soy boxia|mi nombre es boxia/i.test(m.mensaje)
        );

        const texto = normalizar(mensajeLimpio);

        let respuestaTexto = "";

        // ============================================
        // 3. IDENTIFICAR CONSULTA DE IDENTIDAD
        // ============================================

        const preguntaIdentidad =
            /^(quien eres|como te llamas|cual es tu nombre)[?.! ]*$/.test(texto);

        if (preguntaIdentidad) {
            respuestaTexto =
                "Soy BoxIA, el asistente virtual de S-Inventory.";
        }

        // ============================================
        // 4. IDENTIFICAR SALUDO
        // ============================================

        const esSaludo =
            /^(hola|buenos dias|buenas tardes|buenas noches|hey|buenas)[!. ]*$/.test(texto);

        if (!respuestaTexto && esSaludo) {
            respuestaTexto = yaFueSaludado
                ? "Estoy disponible para ayudarte con tu inventario. ¿Qué necesitas consultar?"
                : "¡Hola! Soy BoxIA, el asistente virtual de S-Inventory. Estoy aquí para ayudarte con la gestión de tu inventario. ¿Qué información necesitas?";
        }

        // ============================================
        // 5. IDENTIFICAR PRODUCTO
        // ============================================

        const producto = buscarProducto(
            mensajeLimpio,
            productos || [],
            mensajesAnteriores
        );

        // ============================================
        // 6. CONSULTAS DIRECTAS A SUPABASE
        // ============================================

        if (!respuestaTexto && producto) {

            const preguntaPrecio =
                /\b(precio|cuesta|cuanto vale|valor|vale)\b/.test(texto);

            const preguntaStock =
                /\b(stock|existencias|unidades|cantidad|disponibles|disponible)\b/.test(texto);

            const preguntaCategoria =
                /\b(categoria|clasificacion)\b/.test(texto);

            const preguntaDescripcion =
                /\b(descripcion|detalles|informacion)\b/.test(texto);

            const preguntaNombre =
                /\b(nombre)\b/.test(texto);

            const datos = [];

            if (preguntaPrecio) {
                datos.push(`Precio: ${formatoPrecio(producto.precio)}`);
            }

            if (preguntaStock) {
                datos.push(`Stock disponible: ${producto.stock} unidades`);
            }

            if (preguntaCategoria) {
                datos.push(`Categoría: ${producto.categoria || "No registrada"}`);
            }

            if (preguntaDescripcion) {
                datos.push(`Descripción: ${producto.descripcion || "No registrada"}`);
            }

            if (preguntaNombre && datos.length === 0) {
                datos.push(`Producto: ${producto.nombre}`);
            }

            if (datos.length > 0) {
                respuestaTexto = datos.join("\n");
            }
        }

        // ============================================
        // 7. CONSULTAR CATÁLOGO GENERAL
        // ============================================

        const preguntaCatalogo =
            /\b(que productos|cuales productos|productos tengo|inventario general|lista de productos|catalogo)\b/.test(texto);

        if (!respuestaTexto && preguntaCatalogo) {
            if (!productos || productos.length === 0) {
                respuestaTexto =
                    "Actualmente no hay productos registrados en el inventario.";
            } else {
                respuestaTexto =
                    "Estos son los productos registrados:\n\n" +
                    productos.map(p =>
                        `• ${p.nombre} - ${p.stock} unidades`
                    ).join("\n");
            }
        }

        // ============================================
        // 8. SI NO ES CONSULTA DIRECTA, UTILIZAR GROQ
        // ============================================

        if (!respuestaTexto) {

            const catalogoTexto = productos?.length
                ? productos.map(p => `
Producto: ${p.nombre}
ID: ${p.id_productos}
Descripción: ${p.descripcion || "No registrada"}
Categoría: ${p.categoria || "No registrada"}
Stock: ${p.stock}
Precio: ${formatoPrecio(p.precio)}
`).join("\n")
                : "No hay productos registrados.";

            const systemPrompt = `
Eres el asistente administrativo de S-Inventory.

Tu función es ayudar exclusivamente con el sistema
de inventario y sus funcionalidades.

REGLAS OBLIGATORIAS:

1. Responde siempre directamente a la pregunta.
2. Nunca te presentes espontáneamente.
3. Nunca menciones tu nombre en las respuestas.
4. Nunca escribas "Hola, soy BoxIA".
5. No repitas saludos ni presentaciones.
6. Utiliza un lenguaje amable, educado y profesional.
7. No agregues introducciones innecesarias.
8. No inventes información.
9. Utiliza únicamente los datos proporcionados.
10. No respondas preguntas ajenas a S-Inventory.
11. Si desconoces un dato, indícalo claramente.
12. No afirmes haber realizado operaciones que no ejecutaste.

Si el usuario pregunta algo que no está relacionado
con S-Inventory, responde:

"Puedo ayudarte con información y funcionalidades
de S-Inventory. ¿Qué necesitas consultar?"

Si el usuario pregunta cómo estás, responde
brevemente y con cordialidad, sin presentarte.

INFORMACIÓN DEL INVENTARIO:

${catalogoTexto}

RECUERDA:
No debes mencionar tu nombre ni presentarte.
Responde únicamente lo que el usuario necesita saber.
`;

            const completion = await groq.chat.completions.create({
                model: "openai/gpt-oss-20b",

                messages: [
                    {
                        role: "system",
                        content: systemPrompt
                    },

                    ...mensajesAnteriores.map(m => ({
                        role: m.emisor === "bot"
                            ? "assistant"
                            : "user",
                        content: m.mensaje
                    })),

                    {
                        role: "user",
                        content: mensajeLimpio
                    }
                ],

                max_tokens: 350,
                temperature: 0.1
            });

            respuestaTexto =
                completion.choices[0]?.message?.content?.trim() ||
                "No pude generar una respuesta en este momento.";

            // Eliminar presentaciones y menciones innecesarias
            respuestaTexto = respuestaTexto
                .replace(/^(hola|buenos dias|buenas tardes|buenas noches)[,!.\s]+/i, "")
                .replace(/^(soy|mi nombre es)\s+boxia[,.!\s]*/i, "")
                .replace(/como asistente virtual de s-inventory[,:\s]*/gi, "")
                .replace(/\bBoxIA\b[:,]?\s*/gi, "")
                .trim();

        }

        // ============================================
        // 9. GUARDAR MENSAJES
        // ============================================

        const registroAInsertar = [
            {
                sesion_id: idSesionValido,
                usuario_id: usuarioId || null,
                emisor: "user",
                mensaje: mensajeLimpio
            },
            {
                sesion_id: idSesionValido,
                usuario_id: usuarioId || null,
                emisor: "bot",
                mensaje: respuestaTexto
            }
        ];

        const { error: insertError } = await supabase
            .from("mensaje_chat")
            .insert(registroAInsertar);

        if (insertError) {
            console.error(
                "Error guardando historial:",
                insertError.message
            );
        }

        // ============================================
        // 10. RESPUESTA AL FRONTEND
        // ============================================

        return res.status(200).json({
            respuesta: respuestaTexto,
            sesionId: idSesionValido
        });

    } catch (error) {
        console.error("Error en BoxIA:", error);

        return res.status(500).json({
            message: "Error al procesar la respuesta.",
            error: error.message
        });
    }
};


// ============================================
// OBTENER HISTORIAL
// ============================================

export const obtenerHistorial = async (req, res) => {
    try {
        const { sesionId } = req.params;

        const { data: historial, error } = await supabase
            .from("mensaje_chat")
            .select("emisor, mensaje, created_at")
            .eq("sesion_id", sesionId)
            .order("created_at", { ascending: true });

        if (error) {
            return res.status(500).json({
                message: "Error al consultar el historial.",
                error: error.message
            });
        }

        return res.status(200).json({
            historial: historial || []
        });

    } catch (error) {
        console.error("Error obteniendo historial:", error);

        return res.status(500).json({
            message: "Error interno.",
            error: error.message
        });
    }
};
