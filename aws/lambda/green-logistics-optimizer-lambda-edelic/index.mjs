import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);

// We know Lambda extracts the zip to /var/task
const poly = require('/var/task/node_modules/polyapi/index.js');

export const handler = async (event) => {
    try {
        const body = event.body ? JSON.parse(event.body) : {};
        const { origin, destination, weight_kg } = body;

        // Use the default export if it exists, otherwise use the module itself
        const sdk = poly.default || poly;

        const result = await sdk.greenLogisticsOptimizer.optimizeGreenRoute(
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
        console.error("PolyAPI Stack Trace:", error.stack);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message })
        };
    }
};