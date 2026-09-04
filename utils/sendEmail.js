import { BrevoClient } from '@getbrevo/brevo';


// =====================================================
// ENVIAR CÓDIGO DE VERIFICACIÓN
// =====================================================

export const enviarCodigoVerificacion = async (
    emailDestino,
    nombreDestino,
    codigo
) => {

    try {

        // ---------------------------------------------
        // VALIDAR API KEY
        // ---------------------------------------------

        if (!process.env.BREVO_API_KEY) {

            console.error(
                'BREVO_API_KEY no está configurada'
            );

            return {
                exito: false,
                error:
                    new Error(
                        'BREVO_API_KEY no está configurada'
                    )
            };
        }


        // ---------------------------------------------
        // CREAR CLIENTE BREVO
        // ---------------------------------------------

        const brevo = new BrevoClient({

            apiKey:
                process.env.BREVO_API_KEY

        });


        // ---------------------------------------------
        // ENVIAR CORREO
        // ---------------------------------------------

        const result =
            await brevo.transactionalEmails.sendTransacEmail({

                subject:
                    'Código de verificación - S-Inventory',

                sender: {

                    name:
                        process.env.EMAIL_FROM_NAME
                        || 'S-Inventory',

                    email:
                        process.env.EMAIL_USER
                },

                to: [

                    {

                        email:
                            emailDestino,

                        name:
                            nombreDestino

                    }

                ],

                htmlContent: `

                    <div style="
                        font-family: Arial, sans-serif;
                        max-width: 500px;
                        margin: 0 auto;
                        padding: 24px;
                        border: 1px solid #f0e6e6;
                        border-radius: 12px;
                        background: #ffffff;
                    ">

                        <h2 style="
                            color: #f50c0c;
                            text-align: center;
                        ">
                            S-Inventory
                        </h2>

                        <h3 style="
                            color: #080808;
                            text-align: center;
                        ">
                            Verifica tu cuenta
                        </h3>

                        <p style="
                            color: #4b4b4b;
                            font-size: 15px;
                        ">
                            Hola
                            <strong>
                                ${nombreDestino}
                            </strong>,
                        </p>

                        <p style="
                            color: #696969;
                            font-size: 15px;
                        ">
                            Gracias por registrarte en
                            S-Inventory.
                        </p>

                        <p style="
                            color: #696969;
                            font-size: 15px;
                        ">
                            Usa el siguiente código de
                            6 dígitos para verificar tu cuenta:
                        </p>

                        <div style="
                            text-align: center;
                            margin: 30px 0;
                        ">

                            <span style="
                                font-size: 32px;
                                font-weight: bold;
                                letter-spacing: 6px;
                                color: #d81b60;
                                background: #fdf2f4;
                                padding: 12px 24px;
                                border-radius: 8px;
                            ">
                                ${codigo}
                            </span>

                        </div>

                        <p style="
                            color: #888888;
                            font-size: 12px;
                            text-align: center;
                        ">
                            Este código tiene una
                            validez de 15 minutos.
                        </p>

                        <p style="
                            color: #888888;
                            font-size: 12px;
                            text-align: center;
                        ">
                            Si no creaste una cuenta en
                            S-Inventory, puedes ignorar
                            este correo.
                        </p>

                    </div>

                `
            });


        console.log(
            'Correo enviado con éxito a:',
            emailDestino
        );


        return {

            exito: true,

            result

        };


    } catch (error) {

        console.error(
            'Error enviando correo con Brevo:',
            error
        );


        return {

            exito: false,

            error

        };
    }
};