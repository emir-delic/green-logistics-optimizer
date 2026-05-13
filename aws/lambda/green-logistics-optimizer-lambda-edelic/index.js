// Native CommonJS require
const poly = require('./node_modules/polyapi/index.js');

exports.handler = async (event) => {
    try {
        const body = event.body ? JSON.parse(event.body) : {};
        const { origin, destination, weight_kg } = body;

        if (!origin || !destination) {
            return { 
                statusCode: 400, 
                body: JSON.stringify({ error: "Missing parameters." }) 
            };
        }

        // Trigger the PolyAPI Orchestrator
        // The SDK will now find .poly/lib/index.js because it's using the same resolution engine
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