import admin from "firebase-admin";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

let firebaseInicializado = false;

export const obtenerFirebaseAdmin = () => {
    if (!firebaseInicializado) {
        const aplicaciones = admin.getApps();

        if (aplicaciones.length === 0) {
            const rutaCredenciales = fileURLToPath(
                new URL(
                    "../private/firebase-service-account.json",
                    import.meta.url
                )
            );

            const credenciales = JSON.parse(
                readFileSync(rutaCredenciales, "utf8")
            );

            admin.initializeApp({
                credential: admin.cert(credenciales),
            });
        }

        firebaseInicializado = true;
    }

    return admin;
};
