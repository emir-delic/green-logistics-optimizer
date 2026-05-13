import { createRequire } from 'node:module';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const __dirname = path.dirname(fileURLToPath(import.meta.url));

/**
 * BYPASS: We are pointing directly to the brain (.poly/lib/index.js)
 * instead of requiring 'polyapi', which is where the resolution fails.
 */
const brainPath = path.join(__dirname, 'node_modules', 'polyapi', '.poly', 'lib', 'index.js');
const poly = require(brainPath);

export const handler = async (event) => {
    try {
        const body = event.body ? JSON.parse(event.body) : {};
        const { origin, destination, weight_kg } = body;

        // Use the default export or the object itself
        const sdk = poly.default || poly;

        // Directly call your orchestrator logic
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
        // Detailed logging to see exactly why it fails if it still does
        console.error("Direct Path:", brainPath);
        console.error("PolyAPI Handshake Error:", error.stack);
        return {
            statusCode: 500,
            body: JSON.stringify({ 
                error: error.message,
                path_attempted: brainPath 
            })
        };
    }
};