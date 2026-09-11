import Groq from "groq-sdk";
import { supabase } from "../config/supabase.js";

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export const chatearConBoxIA = async (req, res) => {
    try {
        const { mensaje, sesionId, usuarioId } = req.body;

        if (!mensaje || !mensaje.trim()) {
            return res.status(400).json({ 
                message: "Debes enviar un mensaje." 
            });
        }

        const idSesionValido = sesionId || `S-Iventory_sesion_${Date.now()}`;

        const { data: productos, error: errorProductos } = await supabase
            .from("productos")
            .select("id_productos, nombre, descripcion, stock, precio, creado_en, actualizado_en, categoria");
            
        if (errorProductos) {
            console.error("Error al consultar Supabase:", errorProductos.message);
            return res.status(500).json({ message: "Error al consultar productos." });
        }

        if (!productos || productos.length === 0) {
            return res.status(200).json({
                respuesta: "Hola! En este momento no tenemos productos disponibles en el inventario." 
            });
        }

        const catalogoTexto = productos.map(p => 
            `- **${p.nombre}** | ID: ${p.id_producto} | Stock: ${p.stock} | Precio: $${Number(p.precio).toLocaleString("es-CO")} COP | Descripción: ${p.descripcion}`
        ).join("\n");

        const systemPrompt = `
    Eres el asesor virtual y anfitrión del inventario digital "S-Inventory" y te llamaras "BoxIA".
    Eres alegre, intelectual, amable, coherente y educado.

    CATALOGO ACTUAL EN TIENDA:
    ${catalogoTexto}

    REGLAS DE ATENCION:
    1. Si el administrador solo saluda (ej: "Hola", "¿Como estas?"), respode con cortesia y cercania sin dar la carta ni precios:
        "¡Hola! Mi nombre es BoxIA. Bienvenido a S-Inventory 📦. Que alegria tenerte aqui, ¿en que necesitas ayuda hoy?"
    2. Da precios, nombres de productos, el stock de ellos, cuando se venceran UNICAMENTE cuando el cliente pregunta por los productos que hay en el inventario.
    3. Especifica los valores siempre en pesos colombianos ($ COP).
    4. Se conciso y completa tus oraciones.
    5. Da consejos de cuidado y almacenamiento de los productos UNICAMENTE cuando el cliente pregunte especificamente por cada uno.
    6. Recomienda que productos estan por vencer para venderlos antes de que se venzan UNICAMENTE cuando el cliente los pregunte.
    `;
        
        const completation = await groq.chat.completions.create({
            model: "openai/gpt-oss-20b",
            messages: [
                { role: "system", content: systemPrompt },
                { role: "user", content: mensaje }
            ],
            max_tokens: 600,
            temperature: 0.3,
        });

        const respuestaTexto = completation.choices[0]?.message?.content || 
        "No pude generar una respuesta.";

        const registroAInsertar = [
            {
                sesion_id: idSesionValido,
                usuario_id: usuarioId || null,
                emisor: "user",
                mensaje: mensaje.trim()
            },
            {
                sesion_id: idSesionValido,
                usuario_id: usuarioId || null,
                emisor: "bot",
                mensaje: respuestaTexto
            }
        ];

        const { error: insertError } = await supabase
            .from("mensajes_chat")
            .insert(registroAInsertar);

        if (insertError) {
            console.error("Error guardando el historial en Supabase::", insertError.message);
        }
        
        return res.status(200).json({ 
            respuesta: respuestaTexto,
            sesionId: idSesionValido 
        });

    } catch (error) {
        console.error("Error en Groq chat BoxIA:", error);
        return res.status(500).json({ 
            message: "Error al procesar la respuesta.",
            error: error.message
        });
    }
};

export const obtenerHistorialMimos = async (req, res) => {
    try {
        const { sesionId } = req.params;

        const { data: historial, error } = await supabase
            .from("mensajes_chat")
            .select("emisor, mensaje, created_at")
            .eq("sesion_id", sesionId)
            .order("created_at", { ascending: true });

        if (error) {
            return res.status(500).json({ message: "Error al consultar el historial.", error: error.message });
        }

        return res.status(200).json({ historial: historial || [] });
    } catch (error) {
        return res.status(500).json({ message: "Error interno", error: error.message });
    }
};