import { supabase } from "../config/supabase.js";
import { enviarInformeSemanal } from "../utils/sendEmail.js";

export const generarInformeSemanal = async (req, res) => {
    try {
        const hoy = new Date();

        const inicioSemana = new Date(hoy);
        inicioSemana.setDate(hoy.getDate() - 6);
        inicioSemana.setHours(0, 0, 0, 0);

        const finSemana = new Date(hoy);
        finSemana.setHours(23, 59, 59, 999);

        const { data: productos, error: errorProductos } = await supabase
            .from("productos")
            .select("*");

        if (errorProductos) {
            return res.status(500).json({
                error: "Error obteniendo productos"
            });
        }

        const { data: ventas, error: errorVentas } = await supabase
            .from("ventas")
            .select("*")
            .gte("fecha", inicioSemana.toISOString())
            .lte("fecha", finSemana.toISOString());

        if (errorVentas) {
            return res.status(500).json({
                error: "Error obteniendo ventas"
            });
        }

        const { data: vencimientos, error: errorVencimientos } = await supabase
            .from("vencimientos")
            .select("*")
            .order("fecha_vencimiento", { ascending: true });

        if (errorVencimientos) {
            return res.status(500).json({
                error: "Error obteniendo vencimientos"
            });
        }

        const totalVentas = ventas.reduce(
            (total, venta) => total + Number(venta.total || 0),
            0
        );

        const stockTotal = productos.reduce(
            (total, producto) => total + Number(producto.stock || 0),
            0
        );

        const htmlReporte = `
            <div style="
                font-family: Arial, sans-serif;
                max-width: 600px;
                margin: 0 auto;
                padding: 30px;
                border-radius: 12px;
                background: #0F172A;
                text-align: center;
                color: #FFFFFF;
            ">

                <h1 style="
                    color: #1E3A8A;
                    background: #FFFFFF;
                    padding: 15px;
                    border-radius: 8px;
                    margin-bottom: 25px;
                ">
                    Informe semanal - S-Inventory
                </h1>

                <h2 style="
                    color: #FFFFFF;
                    margin-top: 25px;
                ">
                    Inventario
                </h2>

                <p>
                    Total de productos:
                    <strong>${productos.length}</strong>
                </p>

                <p style="color: #CBD5E1;">
                    Stock total:
                    <strong style="color: #FFFFFF;">${stockTotal}</strong>
                </p>

                <h2 style="
                    color: #FFFFFF;
                    margin-top: 30px;
                ">
                    Ventas de la semana
                </h2>

                <p>
                    Cantidad de ventas:
                    <strong>${ventas.length}</strong>
                </p>

                <p style="color: #CBD5E1;">
                    Total vendido:
                    <strong style="color: #FFFFFF;">$${totalVentas}</strong>
                </p>

                <h2 style="
                    color: #FFFFFF;
                    margin-top: 30px;
                ">
                    Vencimientos
                </h2>

                <p style="color: #CBD5E1;">
                    Total de vencimientos registrados:
                    <strong style="color: #FFFFFF;">${vencimientos.length}</strong>
                </p>

                <h2 style="
                    color: #FFFFFF;
                    margin-top: 30px;
                ">
                    Productos
                </h2>

                <div style="
                    margin-top: 20px;
                    text-align: center;
                ">
                    ${productos.map(producto => `
                        <div style="
                            background: #FFFFFF;
                            color: #1E3A8A;
                            padding: 12px;
                            margin: 8px 0;
                            border-radius: 8px;
                            font-weight: bold;
                        ">
                            ${producto.nombre} - Stock: ${producto.stock}
                        </div>
                    `).join("")}
                </div>

                <p style="
                    color: #CBD5E1;
                    font-size: 12px;
                    margin-top: 30px;
                ">
                    S-Inventory<br>
                    Sistema de gestión de inventario
                </p>

            </div>
        `;

        const resultado = await enviarInformeSemanal(htmlReporte);

        if (!resultado.exito) {
            return res.status(500).json({
                error: "No se pudo enviar el informe semanal"
            });
        }

        res.status(200).json({
            mensaje: "Informe semanal enviado correctamente"
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            error: "Error generando el informe semanal"
        });
    }
};