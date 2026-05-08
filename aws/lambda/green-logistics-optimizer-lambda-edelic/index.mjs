import polyapi from 'polyapi';
const poly = polyapi.default || polyapi;

export const handler = async (event) => {
    try {
        const body = event.body ? JSON.parse(event.body) : {};
        const { origin, destination, weight_kg } = body;

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