
import { BrevoClient } from '@getbrevo/brevo';

/**
 * Cliente de Brevo
 */
const brevo = new BrevoClient({
    apiKey: process.env.BREVO_API_KEY
});

/**
 * Enviar código de verificación
 */
export const enviarCodigoVerificacion = async (
    emailDestino,
    nombreDestino,
    codigo
) => {
    try {
        const result = await brevo.transactionalEmails.sendTransacEmail({
            subject: 'Código de verificación - S-Inventory',

            sender: {
                name: process.env.EMAIL_FROM_NAME || 'S-Inventory',
                email: process.env.EMAIL_USER
            },

            to: [
                {
                    email: emailDestino,
                    name: nombreDestino
                }
            ],

            htmlContent: `
                <div style="
                    font-family: Arial, sans-serif;
                    max-width: 500px;
                    margin: 0 auto;
                    padding: 24px;
                    border: 1px solid #e5e7eb;
                    border-radius: 12px;
                    background: #ffffff;
                ">

                    <h2 style="
                        color: #2563eb;
                        text-align: center;
                        margin-bottom: 8px;
                    ">
                        S-Inventory
                    </h2>

                    <h3 style="
                        color: #111827;
                        text-align: center;
                        margin-top: 0;
                    ">
                        Verifica tu cuenta
                    </h3>

                    <p style="
                        color: #374151;
                        font-size: 15px;
                    ">
                        Hola <strong>${nombreDestino}</strong>,
                    </p>

                    <p style="
                        color: #6b7280;
                        font-size: 15px;
                    ">
                        Gracias por registrarte en S-Inventory.
                        Utiliza el siguiente código de 6 dígitos
                        para verificar tu cuenta.
                    </p>

                    <div style="
                        text-align: center;
                        margin: 30px 0;
                    ">
                        <span style="
                            font-size: 32px;
                            font-weight: bold;
                            letter-spacing: 6px;
                            color: #2563eb;
                            background: #eff6ff;
                            padding: 12px 24px;
                            border-radius: 8px;
                        ">
                            ${codigo}
                        </span>
                    </div>

                    <p style="
                        color: #6b7280;
                        font-size: 13px;
                        text-align: center;
                        margin-top: 30px;
                    ">
                        Si no solicitaste este código,
                        puedes ignorar este correo.
                    </p>

                    <p style="
                        color: #9ca3af;
                        font-size: 12px;
                        text-align: center;
                        margin-top: 20px;
                    ">
                        S-Inventory<br>
                        Sistema de gestión de inventario
                    </p>

                </div>
            `
        });

        console.log(
            `Correo de verificación enviado a ${emailDestino}`
        );

        return {
            exito: true,
            result
        };

    } catch (error) {

        console.error(
            'Error enviando correo de verificación con Brevo:',
            error
        );

        return {
            exito: false,
            error
        };
    }
};


/**
 * Enviar notificación de bienvenida
 */
export const enviarCorreoBienvenida = async (
    emailDestino,
    nombreDestino
) => {
    try {

        const result = await brevo.transactionalEmails.sendTransacEmail({
            subject: 'Bienvenido a S-Inventory',

            sender: {
                name: process.env.EMAIL_FROM_NAME || 'S-Inventory',
                email: process.env.EMAIL_USER
            },

            to: [
                {
                    email: emailDestino,
                    name: nombreDestino
                }
            ],

            htmlContent: `
                <div style="
                    font-family: Arial, sans-serif;
                    max-width: 500px;
                    margin: 0 auto;
                    padding: 24px;
                    border: 1px solid #e5e7eb;
                    border-radius: 12px;
                    background: #ffffff;
                ">

                    <h2 style="
                        color: #2563eb;
                        text-align: center;
                    ">
                        S-Inventory
                    </h2>

                    <h3 style="
                        color: #111827;
                        text-align: center;
                    ">
                        ¡Bienvenido!
                    </h3>

                    <p style="
                        color: #374151;
                        font-size: 15px;
                    ">
                        Hola <strong>${nombreDestino}</strong>,
                    </p>

                    <p style="
                        color: #6b7280;
                        font-size: 15px;
                    ">
                        Tu cuenta en S-Inventory ha sido creada
                        correctamente.
                    </p>

                    <p style="
                        color: #6b7280;
                        font-size: 15px;
                    ">
                        Ahora puedes acceder al sistema y comenzar
                        a gestionar tus productos, inventario,
                        ventas y demás funciones.
                    </p>

                    <p style="
                        color: #9ca3af;
                        font-size: 12px;
                        text-align: center;
                        margin-top: 30px;
                    ">
                        S-Inventory<br>
                        Sistema de gestión de inventario
                    </p>

                </div>
            `
        });

        console.log(
            `Correo de bienvenida enviado a ${emailDestino}`
        );

        return {
            exito: true,
            result
        };

    } catch (error) {

        console.error(
            'Error enviando correo de bienvenida:',
            error
        );

        return {
            exito: false,
            error
        };
    }
};


/**
 * Enviar notificación de cambio de contraseña
 */
export const enviarConfirmacionCambioContrasena = async (
    emailDestino,
    nombreDestino
) => {
    try {

        const result = await brevo.transactionalEmails.sendTransacEmail({
            subject: 'Contraseña actualizada - S-Inventory',

            sender: {
                name: process.env.EMAIL_FROM_NAME || 'S-Inventory',
                email: process.env.EMAIL_USER
            },

            to: [
                {
                    email: emailDestino,
                    name: nombreDestino
                }
            ],

            htmlContent: `
                <div style="
                    font-family: Arial, sans-serif;
                    max-width: 500px;
                    margin: 0 auto;
                    padding: 24px;
                    border: 1px solid #e5e7eb;
                    border-radius: 12px;
                    background: #ffffff;
                ">

                    <h2 style="
                        color: #2563eb;
                        text-align: center;
                    ">
                        S-Inventory
                    </h2>

                    <h3 style="
                        color: #111827;
                        text-align: center;
                    ">
                        Contraseña actualizada
                    </h3>

                    <p style="
                        color: #374151;
                        font-size: 15px;
                    ">
                        Hola <strong>${nombreDestino}</strong>,
                    </p>

                    <p style="
                        color: #6b7280;
                        font-size: 15px;
                    ">
                        Tu contraseña de S-Inventory fue actualizada
                        correctamente.
                    </p>

                    <p style="
                        color: #dc2626;
                        font-size: 14px;
                    ">
                        Si tú no realizaste este cambio, comunícate
                        con el administrador del sistema
                        inmediatamente.
                    </p>

                    <p style="
                        color: #9ca3af;
                        font-size: 12px;
                        text-align: center;
                        margin-top: 30px;
                    ">
                        S-Inventory<br>
                        Sistema de gestión de inventario
                    </p>

                </div>
            `
        });

        console.log(
            `Confirmación de cambio de contraseña enviada a ${emailDestino}`
        );

        return {
            exito: true,
            result
        };

    } catch (error) {

        console.error(
            'Error enviando confirmación de contraseña:',
            error
        );

        return {
            exito: false,
            error
        };
    }
};
