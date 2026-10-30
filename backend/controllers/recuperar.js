
import {
  crearCodigoDeRecuperacion,
  marcarComoUsado,
  obtenerCodigoValido,
} from "../models/recuperar.js";

import {
  actualizarUsuario,
  obtenerPorEmail,
} from "../models/usuarios.js";

import bcrypt from "bcryptjs";

import {
  enviarCodigoRecuperacion,
  enviarConfirmacionCambioContrasena,
} from "../utils/sendEmail.js";

<<<<<<< HEAD

export const forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({
                error: 'El correo electrónico es requerido'
            });
        }

        // Verificar que el usuario exista
        const { data: usuario, error: errorUsuario } =
            await obtenerPorEmail(email);

        if (errorUsuario || !usuario) {
            return res.status(404).json({
                error: 'Usuario no encontrado'
            });
        }

        // Generar código de recuperación de seis dígitos
        const codigo = Math.floor(
            100000 + Math.random() * 900000
        ).toString();

        // Guardar el código en Supabase
        const { error: errorCodigo } =
            await crearCodigoDeRecuperacion(
                usuario.id_usuario,
                codigo
            );

        if (errorCodigo) {
            console.error(
                'Error guardando el código de recuperación:',
                errorCodigo
            );

            return res.status(500).json({
                error: 'No se pudo generar el código de recuperación'
            });
        }

        // Enviar el código mediante Brevo
        const resultadoCorreo = await enviarCodigoRecuperacion(
            email,
            usuario.nombre,
            codigo
        );

        // Comprobar si el envío realmente tuvo éxito
        if (!resultadoCorreo || resultadoCorreo.exito !== true) {
            console.error(
                'Brevo no confirmó el envío del correo:',
                resultadoCorreo?.error || 'Sin detalles del error'
            );

            return res.status(502).json({
                error: 'No se pudo enviar el correo de recuperación. Inténtalo nuevamente.'
            });
        }

        console.log(
            'Correo de recuperación enviado correctamente'
        );

        return res.status(200).json({
            message: 'Código de recuperación enviado al correo'
        });

    } catch (error) {
        console.error(
            'Error en forgotPassword:',
            error?.message || error
        );

        return res.status(500).json({
            error: 'Ocurrió un error al enviar el código de recuperación'
        });
    }
};


//Cambiar contraseña y verificar el codigo recuperacion

export const verifyCode = async (req, res) => {
    try {

        const { email, codigo, newPasswords } = req.body;

        // Verificamos las entradas
        if (!email || !codigo || !newPasswords) {
            return res.status(400).json({
                error: 'Todos los campos son requeridos'
            });
        }

        // Verificar si el usuario existe
        const { data: usuario, error: errorUsuario } =
            await obtenerPorEmail(email);

        if (errorUsuario || !usuario) {
            return res.status(404).json({
                error: 'Usuario no encontrado'
            });
        }

        // Verificar el código de recuperación
        const { data: codigoRecord, error: errorCodigo } =
            await obtenerCodigoValido(
                usuario.id_usuario,
                codigo
            );

        if (errorCodigo || !codigoRecord) {
            return res.status(400).json({
                error: 'Código de recuperación inválido o expirado'
            });
        }

        // Encriptamos la nueva contraseña
        const hashedPassword = await bcrypt.hash(
            newPasswords,
            10
        );

        // Actualizamos la contraseña del usuario
        const { error: updateError } =
            await actualizarUsuario(
                usuario.id_usuario,
                {
                    contrasena: hashedPassword
                }
            );

        if (updateError) {
            throw updateError;
        }

        // Marcamos el código como usado
        const { error: errorUsado } =
            await marcarComoUsado(codigoRecord.id);

        if (errorUsado) {
            throw errorUsado;
        }

        // Enviamos correo de confirmación
        await enviarConfirmacionCambioContrasena(
            email,
            usuario.nombre
        );


        // Respuesta al frontend/Postman
        return res.status(200).json({
            message: 'Contraseña cambiada exitosamente'
        });

    } catch (error) {

        console.error('Error en verifyCode:', error);

        return res.status(500).json({
            error: 'Error al verificar el código o cambiar la contraseña',
            detalle: error.message
        });
=======
// =====================================================
// RECUPERAR CONTRASEÑA: ENVIAR CÓDIGO AL CORREO
// =====================================================

export const forgotPassword = async (req, res) => {
  try {
    const email = req.body.email?.trim();

    if (!email) {
      return res.status(400).json({
        error: "El correo electrónico es requerido",
      });
>>>>>>> bed2d9b8221df863417f349e5593d34b28cc25c4
    }

    // 1. Buscar al usuario por su correo.
    const {
      data: usuario,
      error: errorUsuario,
    } = await obtenerPorEmail(email);

    if (errorUsuario) {
      console.error(
        "Error consultando usuario:",
        errorUsuario
      );

      return res.status(500).json({
        error: "Error al consultar el usuario",
      });
    }

    if (!usuario) {
      return res.status(404).json({
        error: "Usuario no encontrado",
      });
    }

    // 2. Generar un código de seis dígitos.
    const codigo = Math.floor(
      100000 + Math.random() * 900000
    ).toString();

    // 3. Guardar el código en la base de datos.
    const {
      error: errorCodigo,
    } = await crearCodigoDeRecuperacion(
      usuario.id_usuario,
      codigo
    );

    if (errorCodigo) {
      console.error(
        "Error guardando código:",
        errorCodigo
      );

      return res.status(500).json({
        error: "Error al generar el código de recuperación",
      });
    }

    // 4. Enviar el correo mediante Brevo.
    const resultadoCorreo = await enviarCodigoRecuperacion(
      email,
      usuario.nombre,
      codigo
    );

    // 5. Verificar el resultado del envío.
    if (
      !resultadoCorreo ||
      resultadoCorreo.exito !== true
    ) {
      console.error(
        "Error confirmado por el servicio de correo:",
        resultadoCorreo?.error || "Resultado no confirmado"
      );

      return res.status(502).json({
        error: "No se pudo enviar el correo de recuperación",
      });
    }

    // 6. Confirmar el envío al frontend.
    return res.status(200).json({
      message: "Código de recuperación enviado al correo",
    });

  } catch (error) {
    console.error(
      "Error en forgotPassword:",
      error.message
    );

    return res.status(500).json({
      error: "Error interno al enviar el código de recuperación",
    });
  }
};

// =====================================================
// VALIDAR CÓDIGO DE RECUPERACIÓN
// =====================================================

export const validateCode = async (req, res) => {
  try {
    const email = req.body.email?.trim();
    const codigo = req.body.codigo?.trim();

    if (!email || !codigo) {
      return res.status(400).json({
        error: "El correo y el código son requeridos",
      });
    }

    const {
      data: usuario,
      error: errorUsuario,
    } = await obtenerPorEmail(email);

    if (errorUsuario) {
      console.error(
        "Error consultando usuario:",
        errorUsuario
      );

      return res.status(500).json({
        error: "Error al consultar el usuario",
      });
    }

    if (!usuario) {
      return res.status(404).json({
        error: "Usuario no encontrado",
      });
    }

    const {
      data: codigoRecord,
      error: errorCodigo,
    } = await obtenerCodigoValido(
      usuario.id_usuario,
      codigo
    );

    if (errorCodigo) {
      console.error(
        "Error validando código:",
        errorCodigo
      );

      return res.status(500).json({
        error: "Error al validar el código",
      });
    }

    if (!codigoRecord) {
      return res.status(400).json({
        error: "Código de recuperación inválido o expirado",
      });
    }

    return res.status(200).json({
      message: "Código válido",
    });

  } catch (error) {
    console.error(
      "Error en validateCode:",
      error.message
    );

    return res.status(500).json({
      error: "Error al validar el código",
    });
  }
};

// =====================================================
// CAMBIAR CONTRASEÑA CON CÓDIGO DE RECUPERACIÓN
// =====================================================

export const verifyCode = async (req, res) => {
  try {
    const email = req.body.email?.trim();
    const codigo = req.body.codigo?.trim();
    const newPasswords = req.body.newPasswords;

    if (!email || !codigo || !newPasswords) {
      return res.status(400).json({
        error: "Todos los campos son requeridos",
      });
    }

    const {
      data: usuario,
      error: errorUsuario,
    } = await obtenerPorEmail(email);

    if (errorUsuario) {
      console.error(
        "Error consultando usuario:",
        errorUsuario
      );

      return res.status(500).json({
        error: "Error al consultar el usuario",
      });
    }

    if (!usuario) {
      return res.status(404).json({
        error: "Usuario no encontrado",
      });
    }

    const {
      data: codigoRecord,
      error: errorCodigo,
    } = await obtenerCodigoValido(
      usuario.id_usuario,
      codigo
    );

    if (errorCodigo) {
      console.error(
        "Error buscando código:",
        errorCodigo
      );

      return res.status(500).json({
        error: "Error al verificar el código",
      });
    }

    if (!codigoRecord) {
      return res.status(400).json({
        error: "Código de recuperación inválido o expirado",
      });
    }

    // Encriptar la nueva contraseña.
    const hashedPassword = await bcrypt.hash(
      newPasswords,
      10
    );

    // Actualizar la contraseña.
    const {
      error: errorActualizacion,
    } = await actualizarUsuario(
      usuario.id_usuario,
      {
        contrasena: hashedPassword,
      }
    );

    if (errorActualizacion) {
      console.error(
        "Error actualizando contraseña:",
        errorActualizacion
      );

      return res.status(500).json({
        error: "No se pudo actualizar la contraseña",
      });
    }

    // Marcar el código como utilizado.
    const {
      error: errorUsado,
    } = await marcarComoUsado(codigoRecord.id);

    if (errorUsado) {
      console.error(
        "Error marcando código como usado:",
        errorUsado
      );

      return res.status(500).json({
        error: "La contraseña cambió, pero no se pudo actualizar el código",
      });
    }

    // Enviar confirmación del cambio de contraseña.
    try {
      await enviarConfirmacionCambioContrasena(
        email,
        usuario.nombre
      );
    } catch (errorCorreo) {
      // El cambio de contraseña ya se realizó.
      // No informar que la contraseña falló por el correo.
      console.error(
        "No se pudo enviar la confirmación:",
        errorCorreo.message
      );
    }

    return res.status(200).json({
      message: "Contraseña cambiada exitosamente",
    });

  } catch (error) {
    console.error(
      "Error en verifyCode:",
      error.message
    );

    return res.status(500).json({
      error: "Error al verificar el código o cambiar la contraseña",
    });
  }
};
