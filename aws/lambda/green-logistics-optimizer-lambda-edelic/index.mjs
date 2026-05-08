import polyapi from 'polyapi';

const poly = polyapi.default || polyapi;

export const handler = async (event) => {
    try {
        const body = event.body ? JSON.parse(event.body) : {};
        const { origin, destination, weight_kg } = body;

        if (!origin || !destination) {
            return { statusCode: 400, body: JSON.stringify({ error: "Missing parameters." }) };
        }

        // Call the Sovereign Orchestrator
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
        console.error("Orchestration Error:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message })
        };
    }
};