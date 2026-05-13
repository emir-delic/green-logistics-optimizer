import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);

// Native CJS require anchored to this file's location
const polyapi = require('./node_modules/polyapi/index.js');
const poly = polyapi.default || polyapi;

export const handler = async (event) => {
    try {
        const body = event.body ? JSON.parse(event.body) : {};
        const { origin, destination, weight_kg } = body;

        if (!origin || !destination) {
            return { statusCode: 400, body: JSON.stringify({ error: "Missing parameters." }) };
        }

        // Trigger the PolyAPI Orchestrator
        const result = await poly.greenLogisticsOptimizer.optimizeGreenRoute(
            origin, 
            destination, 
            weight_kg || 5
        );

        return {
            statusCode: 200,
            headers: { 
                "Content-Type": "application/json",
                "X-Sovereign-Status": "Verified"
            },
            body: JSON.stringify(result),
        };

    } catch (error) {
        console.error("PolyAPI Handshake Error:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message })
        };
    }
};