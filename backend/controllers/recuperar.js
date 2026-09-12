import { crearCodigoDeRecuperacion, marcarComoUsado, obtenerCodigoValido } from "../models/recuperar.js";
import { actualizarUsuario, obtenerPorEmail } from "../models/usuarios.js";
import bcrypt from 'bcryptjs';
import { enviarCodigoRecuperacion , enviarConfirmacionCambioContrasena} from "../utils/sendEmail.js";




//CONFIGURAR LA LOGICA PARA ENVIAR EL CORREO DE RECUPERACION

export const forgotPassword= async (req,res) =>{
    try {
        const { email } = req.body;

        if(!email){
            return res.status(400).json({error: 'El correo electronico es requerido'})
        }

        //verificar si el usuario existe
        const { data:usuario, error:errorUsuario}= await obtenerPorEmail(email);

        if(errorUsuario || !usuario) {
            return res.status(404).json({error: 'Usuario no encontrado'});
        }

        //GENERAMOS LOS CODIGOS DE RECUPERACION

        const codigo =Math.floor(100000 + Math.random() * 900000).toString();

        //GUARDAR EL CODIGO EN LA BASE DE DATOS

        const {error:errorCodigo}=await crearCodigoDeRecuperacion(usuario.id_usuario,codigo);

        if(errorCodigo){
            return res.status(500).json({error: 'Error al generar el codigo de recuperacion'});
        }
         //CREAMOS EL EMAIL DEL CODIGO

        await enviarCodigoRecuperacion(
            email,
            usuario.nombre,
            codigo
        );

        return res.status(200).json({
            message: 'Código de recuperación enviado al correo'
        });

        
    }catch (error) {
        console.error('Error en forgotContrasena:', error);
        return res.status(500).json({error: 'Error al enviar el codigo de recuperacion'});
    }
}


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
    }

    
};