
import { BrevoClient } from '@getbrevo/brevo';

<<<<<<< HEAD
const brevoApiKey = process.env.BREVO_API_KEY;
const emailRemitente = process.env.EMAIL_USER;
const nombreRemitente =
    process.env.EMAIL_FROM_NAME || 'S-Inventory';
=======
const apiKey = process.env.BREVO_API_KEY;
const emailRemitente = process.env.EMAIL_USER;
const nombreRemitente =
  process.env.EMAIL_FROM_NAME || 'S-Inventory';

const brevo = apiKey
  ? new BrevoClient({ apiKey })
  : null;

// =====================================================
// FUNCIONES AUXILIARES
// =====================================================

function escaparHTML(valor = '') {
  return String(valor).replace(/[&<>"']/g, (caracter) => {
    const entidades = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#39;',
    };

    return entidades[caracter];
  });
}

function validarConfiguracionCorreo() {
  if (!apiKey) {
    throw new Error('Falta configurar BREVO_API_KEY');
  }

  if (!emailRemitente) {
    throw new Error('Falta configurar EMAIL_USER');
  }

  if (!brevo) {
    throw new Error('El cliente de Brevo no está disponible');
  }
}

function obtenerError(error) {
  return {
    mensaje:
      error?.message ||
      error?.body?.message ||
      'Error desconocido al enviar el correo',
    codigo: error?.status || error?.statusCode || null,
  };
}

async function enviarCorreo(datos) {
  validarConfiguracionCorreo();

  return await brevo.transactionalEmails.sendTransacEmail({
    sender: {
      name: nombreRemitente,
      email: emailRemitente,
    },
    ...datos,
  });
}

function registrarError(tipo, error) {
  const detalle = obtenerError(error);

  console.error(`[Brevo] Error en ${tipo}:`, {
    mensaje: detalle.mensaje,
    codigo: detalle.codigo,
  });
}

// =====================================================
// CÓDIGO DE RECUPERACIÓN
// =====================================================
>>>>>>> bed2d9b8221df863417f349e5593d34b28cc25c4

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
<<<<<<< HEAD
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
=======
  try {
    const nombre = escaparHTML(nombreDestino || 'Usuario');
    const codigoSeguro = escaparHTML(codigo);

    const result = await enviarCorreo({
      subject: 'Código de recuperación - S-Inventory',
      to: [
        {
          email: emailDestino,
          name: nombreDestino || 'Usuario',
        },
      ],
      htmlContent: `
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
          ">
            S-Inventory
          </h2>

          <h3>Recuperación de contraseña</h3>

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

          <p style="color: #CBD5E1; font-size: 12px;">
            S-Inventory<br>
            Sistema de gestión de inventario
          </p>
        </div>
      `,
    });

    console.log(
      '[Brevo] Solicitud de recuperación aceptada para:',
      emailDestino
    );

    return {
      exito: true,
      result,
    };
  } catch (error) {
    registrarError('recuperación de contraseña', error);

    return {
      exito: false,
      error: obtenerError(error).mensaje,
    };
  }
};

// =====================================================
// CONFIRMACIÓN DE CAMBIO DE CONTRASEÑA
// =====================================================

>>>>>>> bed2d9b8221df863417f349e5593d34b28cc25c4
export const enviarConfirmacionCambioContrasena = async (
  emailDestino,
  nombreDestino
) => {
<<<<<<< HEAD
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
=======
  try {
    const nombre = escaparHTML(nombreDestino || 'Usuario');

    const result = await enviarCorreo({
      subject: 'Contraseña cambiada - S-Inventory',
      to: [
        {
          email: emailDestino,
          name: nombreDestino || 'Usuario',
        },
      ],
      htmlContent: `
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
          ">
            S-Inventory
          </h2>

          <h3>Contraseña cambiada exitosamente</h3>

          <p>Hola <strong>${nombre}</strong>,</p>

          <p style="color: #CBD5E1;">
            La contraseña de tu cuenta de S-Inventory
            fue cambiada correctamente.
          </p>

          <p style="color: #CBD5E1;">
            Si realizaste este cambio, no necesitas
            realizar ninguna acción adicional.
          </p>

          <p style="color: #CBD5E1;">
            Si no realizaste este cambio, contacta
            al administrador del sistema.
          </p>

          <p style="color: #CBD5E1; font-size: 12px;">
            S-Inventory<br>
            Sistema de gestión de inventario
          </p>
        </div>
      `,
    });

    console.log(
      '[Brevo] Solicitud de confirmación de cambio aceptada para:',
      emailDestino
    );

    return {
      exito: true,
      result,
    };
  } catch (error) {
    registrarError('confirmación de contraseña', error);

    return {
      exito: false,
      error: obtenerError(error).mensaje,
    };
  }
};

// =====================================================
// NOTIFICACIÓN DE VENTA
// =====================================================

>>>>>>> bed2d9b8221df863417f349e5593d34b28cc25c4
export const enviarCorreoVenta = async (
  idVenta,
  idUsuario,
  total
) => {
<<<<<<< HEAD
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
=======
  try {
    const result = await enviarCorreo({
      subject: 'Venta registrada - S-Inventory',
      to: [
        {
          email: emailRemitente,
          name: 'Administrador',
        },
      ],
      htmlContent: `
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
          ">
            S-Inventory
          </h2>

          <h3>Venta registrada correctamente</h3>

          <p style="color: #CBD5E1;">
            Se ha registrado una nueva venta en S-Inventory.
          </p>

          <p>
            <strong>ID de venta:</strong>
            ${escaparHTML(idVenta)}
          </p>

          <p>
            <strong>ID de usuario:</strong>
            ${escaparHTML(idUsuario)}
          </p>

          <p>
            <strong>Total de la venta:</strong>
            $${escaparHTML(total)}
          </p>

          <p style="color: #CBD5E1; font-size: 12px;">
            S-Inventory<br>
            Sistema de gestión de inventario
          </p>
        </div>
      `,
    });

    console.log('[Brevo] Solicitud de correo de venta aceptada');

    return {
      exito: true,
      result,
    };
  } catch (error) {
    registrarError('notificación de venta', error);

    return {
      exito: false,
      error: obtenerError(error).mensaje,
    };
  }
};

// =====================================================
// INFORME SEMANAL
// =====================================================

export const enviarInformeSemanal = async (htmlReporte) => {
  try {
    const result = await enviarCorreo({
      subject: 'Informe semanal - S-Inventory',
      to: [
        {
          email: emailRemitente,
          name: 'Administrador',
        },
      ],
      htmlContent: htmlReporte,
    });

    console.log('[Brevo] Solicitud de informe semanal aceptada');

    return {
      exito: true,
      result,
    };
  } catch (error) {
    registrarError('informe semanal', error);

    return {
      exito: false,
      error: obtenerError(error).mensaje,
    };
  }
>>>>>>> bed2d9b8221df863417f349e5593d34b28cc25c4
};
