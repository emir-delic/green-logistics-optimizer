import { createRequire } from 'node:module';
import path from 'node:path';
const require = createRequire(import.meta.url);

// FORCE the path to the physical file in the Lambda environment
const polyapiPath = path.resolve('/var/task/node_modules/polyapi/index.js');
const polyapi = require(polyapiPath);
const poly = polyapi.default || polyapi;

export const handler = async (event) => {
    try {
        const body = event.body ? JSON.parse(event.body) : {};
        const { origin, destination, weight_kg } = body;

        // Call the Sovereign Orchestrator
        const result = await poly.greenLogisticsOptimizer.optimizeGreenRoute(
            origin, 
            destination, 
            weight_kg || 5
        );

        return {
            statusCode: 200,
            headers: { "Content-Type": "application/json" },
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