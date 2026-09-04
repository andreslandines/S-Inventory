import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

import { supabase } from '../config/supabase.js';

import {
    crearUsuarios,
    obtenerPorEmail
} from '../models/usuarios.js';

import {
    enviarCodigoVerificacion
} from '../utils/sendEmail.js';


// =====================================================
// REGISTRO
// =====================================================

export const registro = async (req, res) => {

    try {

        const {
            nombre,
            email,
            contrasena
        } = req.body;


        // ---------------------------------------------
        // VALIDAR DATOS
        // ---------------------------------------------

        if (!nombre || !email || !contrasena) {

            return res.status(400).json({
                error: 'El nombre, email y contraseña son requeridos'
            });
        }


        // ---------------------------------------------
        // VERIFICAR SI EL EMAIL YA EXISTE
        // ---------------------------------------------

        const {
            data: usuarioExiste
        } = await obtenerPorEmail(email);

        if (usuarioExiste) {

            return res.status(400).json({
                error: 'El email ya existe'
            });
        }


        // ---------------------------------------------
        // ENCRIPTAR CONTRASEÑA
        // ---------------------------------------------

        const hashedContrasena = await bcrypt.hash(
            contrasena,
            10
        );


        // ---------------------------------------------
        // ROL POR DEFECTO
        // ---------------------------------------------

        const rolPorDefecto = 'usuario';


        // ---------------------------------------------
        // GENERAR CODIGO DE VERIFICACION
        // ---------------------------------------------

        const codigoVerificacion =
            Math.floor(
                100000 + Math.random() * 900000
            ).toString();


        // Código válido durante 15 minutos
        const codigoVerificacionExpiracion =
            new Date(
                Date.now() + 15 * 60 * 1000
            );


        // ---------------------------------------------
        // GUARDAR USUARIO
        // ---------------------------------------------

        const {
            data,
            error
        } = await crearUsuarios(
            nombre,
            email,
            rolPorDefecto,
            hashedContrasena,
            codigoVerificacion,
            codigoVerificacionExpiracion
        );


        if (error) {

            console.error(
                'Error creando usuario:',
                error
            );

            return res.status(500).json({
                error: 'Error al crear el usuario',
                detalle: error.message
            });
        }


        // ---------------------------------------------
        // USUARIO CREADO
        // ---------------------------------------------

        const usuarioCreado =
            Array.isArray(data)
                ? data[0]
                : data;


        // ---------------------------------------------
        // ENVIAR CORREO
        // ---------------------------------------------

        const resultadoEnvio =
            await enviarCodigoVerificacion(
                email,
                nombre,
                codigoVerificacion
            );


        // ---------------------------------------------
        // RESPUESTA DEL USUARIO
        // ---------------------------------------------

        const usuarioRespuesta = {

            id_usuario:
                usuarioCreado.id_usuario,

            nombre:
                usuarioCreado.nombre,

            email:
                usuarioCreado.email,

            rol:
                usuarioCreado.rol
        };


        // ---------------------------------------------
        // SI BREVO FALLA
        // ---------------------------------------------

        if (!resultadoEnvio.exito) {

            return res.status(200).json({

                message:
                    'Usuario registrado con éxito, pero no se pudo enviar el correo de verificación',

                emailEnviado: false,

                usuario: usuarioRespuesta
            });
        }


        // ---------------------------------------------
        // TODO CORRECTO
        // ---------------------------------------------

        return res.status(201).json({

            message:
                'Usuario registrado con éxito, correo de verificación enviado',

            emailEnviado: true,

            usuario: usuarioRespuesta
        });


    } catch (error) {

        console.error(
            'Error en registro:',
            error
        );

        return res.status(500).json({
            error: error.message
        });
    }
};



// =====================================================
// LOGIN
// =====================================================

export const login = async (req, res) => {

    try {

        const {
            email,
            contrasena
        } = req.body;


        // ---------------------------------------------
        // VALIDAR DATOS
        // ---------------------------------------------

        if (!email || !contrasena) {

            return res.status(400).json({
                error:
                    'El email y la contraseña son requeridos'
            });
        }


        // ---------------------------------------------
        // BUSCAR USUARIO
        // ---------------------------------------------

        const {
            data: usuario,
            error
        } = await obtenerPorEmail(email);


        if (error || !usuario) {

            return res.status(401).json({
                error: 'Credenciales incorrectas'
            });
        }


        // ---------------------------------------------
        // COMPARAR CONTRASEÑA
        // ---------------------------------------------

        const contrasenaValida =
            await bcrypt.compare(
                contrasena,
                usuario.contrasena
            );


        if (!contrasenaValida) {

            return res.status(401).json({
                error: 'Credenciales incorrectas'
            });
        }


        // ---------------------------------------------
        // VERIFICAR CUENTA
        // ---------------------------------------------

        if (!usuario.isVerified) {

            return res.status(403).json({

                error:
                    'Tu cuenta no ha sido verificada. Por favor ingresa el código enviado a tu correo.'
            });
        }


        // ---------------------------------------------
        // CREAR TOKEN
        // ---------------------------------------------

        const token = jwt.sign(

            {
                id_usuario:
                    usuario.id_usuario,

                rol:
                    usuario.rol
            },

            process.env.JWT_SECRET,

            {
                expiresIn: '1d'
            }
        );


        // ---------------------------------------------
        // RESPUESTA
        // ---------------------------------------------

        return res.status(200).json({

            message:
                'Inicio de sesión exitoso',

            token,

            usuario: {

                id_usuario:
                    usuario.id_usuario,

                nombre:
                    usuario.nombre,

                email:
                    usuario.email,

                rol:
                    usuario.rol
            }
        });


    } catch (error) {

        console.error(
            'Error en login:',
            error
        );

        return res.status(500).json({
            error: error.message
        });
    }
};



// =====================================================
// VERIFICAR CUENTA
// =====================================================

export const verificarCuenta = async (req, res) => {

    try {

        const {
            email,
            codigo
        } = req.body;


        // ---------------------------------------------
        // VALIDAR DATOS
        // ---------------------------------------------

        if (!email || !codigo) {

            return res.status(400).json({

                error:
                    'El email y el código de verificación son requeridos'
            });
        }


        // ---------------------------------------------
        // BUSCAR USUARIO
        // ---------------------------------------------

        const {
            data: usuario,
            error: errorUsuario
        } = await supabase

            .from('usuarios')

            .select(`
                id_usuario,
                email,
                isVerified,
                CodigoVerificacion,
                codigoVerificacionExpiracion
            `)

            .eq('email', email)

            .single();


        if (errorUsuario || !usuario) {

            return res.status(404).json({

                error:
                    'Usuario no encontrado'
            });
        }


        // ---------------------------------------------
        // VERIFICAR SI YA ESTÁ VERIFICADO
        // ---------------------------------------------

        if (usuario.isVerified) {

            return res.status(400).json({

                error:
                    'La cuenta ya se encuentra verificada'
            });
        }


        // ---------------------------------------------
        // COMPARAR CÓDIGO
        // ---------------------------------------------

        if (
            String(usuario.CodigoVerificacion).trim()
            !==
            String(codigo).trim()
        ) {

            return res.status(400).json({

                error:
                    'El código de verificación es incorrecto'
            });
        }


        // ---------------------------------------------
        // VERIFICAR EXPIRACIÓN
        // ---------------------------------------------

        const ahora = new Date();

        const codigoExpiracion =
            new Date(
                usuario.codigoVerificacionExpiracion
            );


        if (
            !usuario.codigoVerificacionExpiracion ||
            ahora > codigoExpiracion
        ) {

            return res.status(400).json({

                error:
                    'El código ha expirado. Por favor solicita uno nuevo'
            });
        }


        // ---------------------------------------------
        // ACTIVAR CUENTA
        // ---------------------------------------------

        const {
            error: errorUpdate
        } = await supabase

            .from('usuarios')

            .update({

                isVerified: true,

                CodigoVerificacion: null,

                codigoVerificacionExpiracion: null

            })

            .eq(
                'id_usuario',
                usuario.id_usuario
            );


        if (errorUpdate) {

            console.error(
                'Error actualizando usuario:',
                errorUpdate
            );

            return res.status(500).json({

                error:
                    'Error al actualizar el estado de verificación'
            });
        }


        // ---------------------------------------------
        // RESPUESTA
        // ---------------------------------------------

        return res.status(200).json({

            message:
                'Cuenta verificada exitosamente. Ya puedes iniciar sesión en S-Inventory.'
        });


    } catch (error) {

        console.error(
            'Error en verificación:',
            error
        );

        return res.status(500).json({
            error: error.message
        });
    }
};