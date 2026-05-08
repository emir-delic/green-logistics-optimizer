// Change this line to a relative import
import poly from './node_modules/polyapi/index.js'; 

export const handler = async (event) => {
    try {
        const body = event.body ? JSON.parse(event.body) : {};
        const { origin, destination, weight_kg } = body;

        if (!origin || !destination) {
            return { statusCode: 400, body: JSON.stringify({ error: "Missing parameters." }) };
        }

        // Trigger PolyAPI
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
        console.error("PolyAPI Error:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message })
        };
    }
};