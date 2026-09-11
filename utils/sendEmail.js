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
                    padding: 24px;
                    border: 1px solid #e0e0e0;
                    border-radius: 12px;
                    background: #ffffff;
                ">

                    <h2 style="text-align: center;">
                        S-Inventory
                    </h2>

                    <h3 style="text-align: center;">
                        Recuperación de contraseña
                    </h3>

                    <p>
                        Hola <strong>${nombreDestino}</strong>,
                    </p>

                    <p>
                        Se solicitó recuperar la contraseña
                        de tu cuenta de S-Inventory.
                    </p>

                    <p>
                        Tu código de recuperación es:
                    </p>

                    <div style="
                        text-align: center;
                        margin: 30px 0;
                    ">
                        <span style="
                            font-size: 32px;
                            font-weight: bold;
                            letter-spacing: 6px;
                            background: #f2f2f2;
                            padding: 12px 24px;
                            border-radius: 8px;
                        ">
                            ${codigo}
                        </span>
                    </div>

                    <p>
                        Este código es válido durante 15 minutos.
                    </p>

                    <p>
                        Si no solicitaste recuperar tu contraseña,
                        puedes ignorar este correo.
                    </p>

                    <p style="
                        color: #888888;
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