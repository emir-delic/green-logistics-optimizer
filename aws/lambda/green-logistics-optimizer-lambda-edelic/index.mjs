import poly from 'polyapi';
import fs from 'node:fs';

export const handler = async (event) => {
    // --- 1. DEBUG: Layer Verification (Check CW Logs if it still fails) ---
    const layerPath = '/opt/nodejs/node_modules/polyapi';
    if (!fs.existsSync(layerPath)) {
        console.error(`FATAL: PolyAPI Layer not found at ${layerPath}`);
        console.log("Existing paths in /opt/nodejs:", fs.readdirSync('/opt/nodejs').catch(() => "none"));
    }

    try {
        // 2. Parse user input from API Gateway
        const body = event.body ? JSON.parse(event.body) : {};
        const { origin, destination, weight_kg } = body;

        // Validation
        if (!origin || !destination) {
            return { 
                statusCode: 400, 
                body: JSON.stringify({ error: "Missing origin or destination parameters." }) 
            };
        }

        console.log(`Requesting green route optimization: ${origin} -> ${destination} (${weight_kg || 5}kg)`);

        // 3. Trigger the Sovereign Orchestrator on PolyAPI eu1
        // This coordinates DHL, Climatiq, and Weather via the EU Sovereign Cloud
        const result = await poly.greenLogisticsOptimizer.optimizeGreenRoute(
            origin, 
            destination, 
            weight_kg || 5
        );

        // 4. Success Response
        return {
            statusCode: 200,
            headers: { 
                "Content-Type": "application/json",
                "X-Data-Sovereignty": "Verified-PolyAPI-EU1",
                "X-Orchestration-Region": "eu1.polyapi.io"
            },
            body: JSON.stringify(result),
        };

    } catch (error) {
        // Log the full error for CloudWatch debugging
        console.error("PolyAPI Orchestration Error:", {
            message: error.message,
            stack: error.stack,
            details: error
        });

        return {
            statusCode: 500,
            body: JSON.stringify({ 
                error: "Sovereign Orchestration Failed",
                message: error.message 
            })
        };
    }
};