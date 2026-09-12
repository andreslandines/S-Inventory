import { BrevoClient } from '@getbrevo/brevo';

const brevo = new BrevoClient({
    apiKey: process.env.BREVO_API_KEY
});

export const enviarCodigoRecuperacion = async (
    emailDestino,
    nombreDestino,
    codigo
) => {
    try {
        const result = await brevo.transactionalEmails.sendTransacEmail({
            subject: 'Código de recuperación - S-Inventory',
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

                    <h3 style="
                        color: #FFFFFF;
                        margin-bottom: 25px;
                    ">
                        Recuperación de contraseña
                    </h3>

                    <p>
                        Hola <strong>${nombreDestino}</strong>,
                    </p>

                    <p style="color: #CBD5E1;">
                        Se solicitó recuperar la contraseña
                        de tu cuenta de S-Inventory.
                    </p>

                    <p>
                        Tu código de recuperación es:
                    </p>

                    <div style="
                        margin: 30px 0;
                    ">
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
                            ${codigo}
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
            `
        });

        console.log('Correo de recuperación enviado con éxito');

        return {
            exito: true,
            result
        };
    } catch (error) {
        console.error(
            'Error enviando correo de recuperación:',
            error
        );

        return {
            exito: false,
            error
        };
    }
};

export const enviarConfirmacionCambioContrasena = async (
    emailDestino,
    nombreDestino
) => {
    try {
        const result = await brevo.transactionalEmails.sendTransacEmail({
            subject: 'Contraseña cambiada - S-Inventory',
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

                    <h3 style="
                        color: #FFFFFF;
                        margin-bottom: 25px;
                    ">
                        Contraseña cambiada exitosamente
                    </h3>

                    <p>
                        Hola <strong>${nombreDestino}</strong>,
                    </p>

                    <p style="color: #CBD5E1;">
                        Te informamos que la contraseña de tu
                        cuenta de S-Inventory fue cambiada
                        correctamente.
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
            `
        });

        console.log(
            'Correo de confirmación de contraseña enviado con éxito'
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

export const enviarCorreoVenta = async (
    idVenta,
    idUsuario,
    total
) => {
    try {
        const result = await brevo.transactionalEmails.sendTransacEmail({
            subject: 'Venta registrada - S-Inventory',
            sender: {
                name: process.env.EMAIL_FROM_NAME || 'S-Inventory',
                email: process.env.EMAIL_USER
            },
            to: [
                {
                    email: process.env.EMAIL_USER,
                    name: 'Administrador'
                }
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
                        margin-bottom: 20px;
                    ">
                        S-Inventory
                    </h2>

                    <h3 style="
                        color: #FFFFFF;
                        margin-bottom: 25px;
                    ">
                        Venta registrada correctamente
                    </h3>

                    <p style="color: #CBD5E1;">
                        Se ha registrado una nueva venta en
                        S-Inventory.
                    </p>

                    <p>
                        <strong>ID de venta:</strong> ${idVenta}
                    </p>

                    <p>
                        <strong>ID de usuario:</strong> ${idUsuario}
                    </p>

                    <p>
                        <strong>Total de la venta:</strong> $${total}
                    </p>

                    <p style="color: #CBD5E1;">
                        La venta fue registrada correctamente
                        en el sistema.
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
            `
        });

        console.log(
            'Correo de venta enviado con éxito'
        );

        return {
            exito: true,
            result
        };
    } catch (error) {
        console.error(
            'Error enviando correo de venta:',
            error
        );

        return {
            exito: false,
            error
        };
    }
};

export const enviarInformeSemanal = async (htmlReporte) => {
    try {
        const result = await brevo.transactionalEmails.sendTransacEmail({
            subject: 'Informe semanal - S-Inventory',
            sender: {
                name: process.env.EMAIL_FROM_NAME || 'S-Inventory',
                email: process.env.EMAIL_USER
            },
            to: [
                {
                    email: process.env.EMAIL_USER,
                    name: 'Administrador'
                }
            ],
            htmlContent: htmlReporte
        });

        console.log('Informe semanal enviado con éxito');

        return {
            exito: true,
            result
        };
    } catch (error) {
        console.error('Error enviando informe semanal:', error);

        return {
            exito: false,
            error
        };
    }
};