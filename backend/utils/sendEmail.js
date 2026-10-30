
import { BrevoClient } from '@getbrevo/brevo';

const brevoApiKey = process.env.BREVO_API_KEY;
const emailRemitente = process.env.EMAIL_USER;
const nombreRemitente =
    process.env.EMAIL_FROM_NAME || 'S-Inventory';

// Validar configuración al iniciar el módulo.
if (!brevoApiKey) {
    console.error('ERROR: BREVO_API_KEY no está configurada.');
}

if (!emailRemitente) {
    console.error('ERROR: EMAIL_USER no está configurado.');
}

const brevo = brevoApiKey
    ? new BrevoClient({ apiKey: brevoApiKey })
    : null;

/**
 * Escapa texto para evitar que los datos introducidos
 * en el HTML se interpreten como etiquetas.
 */
const escaparHtml = (valor) => {
    return String(valor ?? '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
};

/**
 * Devuelve errores más útiles sin imprimir claves API.
 */
const obtenerMensajeError = (error) => {
    const estado =
        error?.status ??
        error?.statusCode ??
        error?.response?.status;

    const mensaje =
        error?.body?.message ??
        error?.response?.data?.message ??
        error?.message ??
        'Error desconocido al comunicarse con Brevo';

    return {
        ...(estado !== undefined ? { estado } : {}),
        mensaje
    };
};

/**
 * Envía un correo transaccional mediante Brevo.
 */
const enviarCorreo = async ({
    destinatario,
    nombreDestino,
    asunto,
    html
}) => {
    try {
        if (!brevo) {
            throw new Error(
                'BREVO_API_KEY no está configurada en el backend.'
            );
        }

        if (!emailRemitente) {
            throw new Error(
                'EMAIL_USER no está configurado en el backend.'
            );
        }

        if (!destinatario) {
            throw new Error(
                'No se indicó el correo destinatario.'
            );
        }

        const respuesta =
            await brevo.transactionalEmails.sendTransacEmail({
                subject: asunto,
                sender: {
                    name: nombreRemitente,
                    email: emailRemitente
                },
                to: [
                    {
                        email: destinatario,
                        ...(nombreDestino
                            ? { name: nombreDestino }
                            : {})
                    }
                ],
                htmlContent: html
            });

        // Una respuesta satisfactoria significa que Brevo
        // aceptó la solicitud, no que el correo ya llegó
        // a la bandeja de entrada.
        console.log(
            `Brevo aceptó el envío: "${asunto}" para ${destinatario}.`,
            respuesta?.messageId
                ? `ID: ${respuesta.messageId}`
                : ''
        );

        return {
            exito: true,
            result: respuesta
        };
    } catch (error) {
        const detalle = obtenerMensajeError(error);

        console.error('Error al enviar correo con Brevo:', {
            asunto,
            destinatario,
            ...detalle
        });

        return {
            exito: false,
            error: detalle
        };
    }
};

/**
 * Correo con código de recuperación de contraseña.
 */
export const enviarCodigoRecuperacion = async (
    emailDestino,
    nombreDestino,
    codigo
) => {
    const nombre = escaparHtml(nombreDestino);
    const codigoSeguro = escaparHtml(codigo);

    const html = `
        <div style="
            font-family: Arial, sans-serif;
            max-width: 500px;
            margin: 0 auto;
            padding: 30px;
            border-radius: 12px;
            background: #0F172A;
            text-align: center;
            color: #FFFFFF;
        ">
            <h2 style="
                color: #1E3A8A;
                background: #FFFFFF;
                padding: 12px;
                border-radius: 8px;
                margin-bottom: 20px;
            ">
                S-Inventory
            </h2>

            <h3 style="color: #FFFFFF; margin-bottom: 25px;">
                Recuperación de contraseña
            </h3>

            <p>Hola <strong>${nombre}</strong>,</p>

            <p style="color: #CBD5E1;">
                Se solicitó recuperar la contraseña
                de tu cuenta de S-Inventory.
            </p>

            <p>Tu código de recuperación es:</p>

            <div style="margin: 30px 0;">
                <span style="
                    display: inline-block;
                    font-size: 32px;
                    font-weight: bold;
                    letter-spacing: 6px;
                    background: #FFFFFF;
                    color: #1E3A8A;
                    padding: 12px 24px;
                    border-radius: 8px;
                ">
                    ${codigoSeguro}
                </span>
            </div>

            <p style="color: #CBD5E1;">
                Este código es válido durante 15 minutos.
            </p>

            <p style="color: #CBD5E1;">
                Si no solicitaste recuperar tu contraseña,
                puedes ignorar este correo.
            </p>

            <p style="
                color: #CBD5E1;
                font-size: 12px;
                margin-top: 30px;
            ">
                S-Inventory<br>
                Sistema de gestión de inventario
            </p>
        </div>
    `;

    return enviarCorreo({
        destinatario: emailDestino,
        nombreDestino,
        asunto: 'Código de recuperación - S-Inventory',
        html
    });
};

/**
 * Correo de confirmación tras cambiar la contraseña.
 */
export const enviarConfirmacionCambioContrasena = async (
    emailDestino,
    nombreDestino
) => {
    const nombre = escaparHtml(nombreDestino);

    const html = `
        <div style="
            font-family: Arial, sans-serif;
            max-width: 500px;
            margin: 0 auto;
            padding: 30px;
            border-radius: 12px;
            background: #0F172A;
            text-align: center;
            color: #FFFFFF;
        ">
            <h2 style="
                color: #1E3A8A;
                background: #FFFFFF;
                padding: 12px;
                border-radius: 8px;
                margin-bottom: 20px;
            ">
                S-Inventory
            </h2>

            <h3 style="color: #FFFFFF; margin-bottom: 25px;">
                Contraseña cambiada exitosamente
            </h3>

            <p>Hola <strong>${nombre}</strong>,</p>

            <p style="color: #CBD5E1;">
                Te informamos que la contraseña de tu
                cuenta de S-Inventory fue cambiada correctamente.
            </p>

            <p style="color: #CBD5E1;">
                Si realizaste este cambio, no necesitas
                realizar ninguna acción adicional.
            </p>

            <p style="color: #CBD5E1;">
                Si no realizaste este cambio, contacta
                al administrador del sistema.
            </p>

            <p style="
                color: #CBD5E1;
                font-size: 12px;
                margin-top: 30px;
            ">
                S-Inventory<br>
                Sistema de gestión de inventario
            </p>
        </div>
    `;

    return enviarCorreo({
        destinatario: emailDestino,
        nombreDestino,
        asunto: 'Contraseña cambiada - S-Inventory',
        html
    });
};

/**
 * Correo de aviso cuando se registra una venta.
 */
export const enviarCorreoVenta = async (
    idVenta,
    idUsuario,
    total
) => {
    const html = `
        <div style="
            font-family: Arial, sans-serif;
            max-width: 500px;
            margin: 0 auto;
            padding: 30px;
            border-radius: 12px;
            background: #0F172A;
            text-align: center;
            color: #FFFFFF;
        ">
            <h2 style="
                color: #1E3A8A;
                background: #FFFFFF;
                padding: 12px;
                border-radius: 8px;
                margin-bottom: 20px;
            ">
                S-Inventory
            </h2>

            <h3 style="color: #FFFFFF; margin-bottom: 25px;">
                Venta registrada correctamente
            </h3>

            <p style="color: #CBD5E1;">
                Se ha registrado una nueva venta en S-Inventory.
            </p>

            <p>
                <strong>ID de venta:</strong>
                ${escaparHtml(idVenta)}
            </p>

            <p>
                <strong>ID de usuario:</strong>
                ${escaparHtml(idUsuario)}
            </p>

            <p>
                <strong>Total de la venta:</strong>
                $${escaparHtml(total)}
            </p>

            <p style="color: #CBD5E1;">
                La venta fue registrada correctamente en el sistema.
            </p>

            <p style="
                color: #CBD5E1;
                font-size: 12px;
                margin-top: 30px;
            ">
                S-Inventory<br>
                Sistema de gestión de inventario
            </p>
        </div>
    `;

    return enviarCorreo({
        destinatario: emailRemitente,
        nombreDestino: 'Administrador',
        asunto: 'Venta registrada - S-Inventory',
        html
    });
};

/**
 * Correo con el informe semanal del inventario.
 */
export const enviarInformeSemanal = async (htmlReporte) => {
    return enviarCorreo({
        destinatario: emailRemitente,
        nombreDestino: 'Administrador',
        asunto: 'Informe semanal - S-Inventory',
        html: htmlReporte
    });
};
