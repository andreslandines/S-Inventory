
import { supabase } from "../config/supabase.js";

export const guardarTokenFcm = async (id_usuario, token) => {
    const { data, error } = await supabase
        .from("dispositivos_fcm")
        .upsert(
            {
                id_usuario,
                token,
                plataforma: "android",
                actualizado_en: new Date().toISOString(),
            },
            {
                onConflict: "token",
            }
        )
        .select()
        .single();

    return { data, error };
};
