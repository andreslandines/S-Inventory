
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


// ======================================================
// REGISTRO
// ======================================================

export const registro = async (req, res) => {

    try {

        const {
            nombre,
            contrasena,
            email
            
        } = req.body;


        // ----------------------------------------------
        // Validar datos
        // ----------------------------------------------

        if (!nombre || !contrasena || !email) {

            return res.status(400).json({
                error: 'El nombre, email y contraseña son requeridos'
            });

        }


        // ----------------------------------------------
        // Verificar si el email ya existe
        // ----------------------------------------------

        const {
            data: usuarioExiste,
            error: errorBusqueda
        } = await obtenerPorEmail(email);


        if (errorBusqueda) {

            console.error(
                'Error buscando usuario:',
                errorBusqueda
            );

            return res.status(500).json({
                error: 'Error al verificar el email'
            }); 

        }


        if (usuarioExiste) {

            return res.status(400).json({
                error: 'El email ya existe'
            });

        }


        // ----------------------------------------------
        // Encriptar contraseña
        // ----------------------------------------------

        const hashedContrasena =
            await bcrypt.hash(contrasena, 10);


        // ----------------------------------------------
        // Rol por defecto
        // ----------------------------------------------

        const rolPorDefecto = 'usuario';


        // ----------------------------------------------
        // Generar código de verificación
        // ----------------------------------------------

        const CodigoVerificacion =
            Math.floor(
                100000 + Math.random() * 900000
            ).toString();


        // Código válido durante 15 minutos

        const codigoVerificacionExpiracion =
            new Date(
                Date.now() + 15 * 60 * 1000
            );


        // ----------------------------------------------
        // Crear usuario en Supabase
        // ----------------------------------------------

        const {
            data,
            error
        } = await crearUsuarios(
            nombre,
            email,
            rolPorDefecto,
            hashedContrasena,
            CodigoVerificacion,
            codigoVerificacionExpiracion
        );


        if (error) {

            console.error(
                'Error al crear usuario:',
                error
            );

            return res.status(500).json({
                error: 'Error al crear el usuario'
            });

        }


        // ----------------------------------------------
        // Obtener usuario creado
        // ----------------------------------------------

        const usuarioCreado =
            Array.isArray(data)
                ? data[0]
                : data;


        if (!usuarioCreado) {

            return res.status(500).json({
                error: 'No se pudo obtener el usuario creado'
            });

        }


        // ----------------------------------------------
        // Enviar código de verificación
        // ----------------------------------------------

        const resultadoEnvio =
            await enviarCodigoVerificacion(
                email,
                nombre,
                CodigoVerificacion
            );


        // ----------------------------------------------
        // Datos que se devuelven al frontend
        // ----------------------------------------------

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


        // ----------------------------------------------
        // Si Brevo falla
        // ----------------------------------------------

        if (!resultadoEnvio.exito) {

            return res.status(201).json({

                message:
                    'Usuario registrado correctamente, pero no se pudo enviar el código de verificación',

                emailEnviado: false,

                usuario: usuarioRespuesta

            });

        }


        // ----------------------------------------------
        // Registro exitoso
        // ----------------------------------------------

        return res.status(201).json({

            message:
                'Usuario registrado correctamente. Se envió el código de verificación a su correo',

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


// ======================================================
// LOGIN
// ======================================================

export const login = async (req, res) => {

    try {

        const {
            email,
            contrasena
        } = req.body;


        // ----------------------------------------------
        // Validar datos
        // ----------------------------------------------

        if (!email || !contrasena) {

            return res.status(400).json({
                error: 'El email y la contraseña son requeridos'
            });

        }


        // ----------------------------------------------
        // Buscar usuario
        // ----------------------------------------------

        const {
            data: usuario,
            error
        } = await obtenerPorEmail(email);


        if (error) {

            console.error(
                'Error buscando usuario:',
                error
            );

            return res.status(500).json({
                error: 'Error al buscar el usuario'
            });

        }


        if (!usuario) {

            return res.status(401).json({
                error: 'Credenciales incorrectas'
            });

        }


        // ----------------------------------------------
        // Comparar contraseña
        // ----------------------------------------------

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


        // ----------------------------------------------
        // Verificar cuenta
        // ----------------------------------------------

        if (!usuario.isVerified) {

            return res.status(403).json({

                error:
                    'Tu cuenta no ha sido verificada. Ingresa el código enviado a tu correo antes de iniciar sesión.'

            });

        }


        // ----------------------------------------------
        // Crear token JWT
        // ----------------------------------------------

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


        // ----------------------------------------------
        // Respuesta
        // ----------------------------------------------

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


// ======================================================
// VERIFICAR CUENTA
// ======================================================

export const verificarCuenta = async (req, res) => {

    try {

        const {
            email,
            codigo
        } = req.body;


        // ----------------------------------------------
        // Validar datos
        // ----------------------------------------------

        if (!email || !codigo) {

            return res.status(400).json({

                error:
                    'El email y el código de verificación son requeridos'

            });

        }


        // ----------------------------------------------
        // Buscar usuario
        // ----------------------------------------------

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

            console.error(
                'Error buscando usuario:',
                errorUsuario
            );

            return res.status(404).json({

                error:
                    'Usuario no encontrado'

            });

        }


        // ----------------------------------------------
        // Verificar si ya está verificada
        // ----------------------------------------------

        if (usuario.isVerified) {

            return res.status(400).json({

                error:
                    'La cuenta ya se encuentra verificada'

            });

        }


        // ----------------------------------------------
        // Comparar código
        // ----------------------------------------------

        if (
            String(usuario.CodigoVerificacion).trim() !==
            String(codigo).trim()
        ) {

            return res.status(400).json({

                error:
                    'El código de verificación es incorrecto'

            });

        }


        // ----------------------------------------------
        // Verificar expiración
        // ----------------------------------------------

        const ahora = new Date();

        const codigoExpiracion =
            new Date(
                usuario.codigoVerificacionExpiracion
            );


        if (ahora > codigoExpiracion) {

            return res.status(400).json({

                error:
                    'El código ha expirado. Solicita uno nuevo'

            });

        }


        // ----------------------------------------------
        // Activar cuenta
        // ----------------------------------------------

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


        // ----------------------------------------------
        // Verificación exitosa
        // ----------------------------------------------

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

