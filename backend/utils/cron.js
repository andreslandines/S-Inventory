import cron from "node-cron";
import { generarInformeSemanal } from "../controllers/reportes.js";

cron.schedule("0 8 * * 1", async () => {
    try {
        console.log("Generando informe semanal automáticamente...");

        const req = {};
        const res = {
            status: (codigo) => ({
                json: (data) => {
                    console.log(`Informe semanal: ${codigo}`, data);
                }
            })
        };

        await generarInformeSemanal(req, res);

    } catch (error) {
        console.error("Error generando informe automático:", error);
    }
});

console.log("Reporte semanal automático activado");