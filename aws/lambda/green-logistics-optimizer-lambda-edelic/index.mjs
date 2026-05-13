import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

// This ensures the internal 'require' in polyapi finds the nested .poly folder
const require = createRequire(import.meta.url);
const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Resolve the absolute path to the library
const polyapiPath = path.join(__dirname, 'node_modules', 'polyapi', 'index.js');
const polyapi = require(polyapiPath);

export const handler = async (event) => {
    try {
        const body = event.body ? JSON.parse(event.body) : {};
        const { origin, destination, weight_kg } = body;

        // The SDK might be nested under .default depending on how CJS was bundled
        const sdk = polyapi.default || polyapi;

        // Use the method from your specific generated SDK
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
        console.error("PolyAPI Error Trace:", error.stack);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message, stack: error.stack })
        };
    }
};