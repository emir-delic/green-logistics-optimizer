import poly from 'polyapi'; // Ensure polyapi is in your Lambda Layer or package.json

export const handler = async (event) => {
    try {
        const body = event.body ? JSON.parse(event.body) : {};
        const { origin, destination, weight_kg } = body;

        if (!origin || !destination) {
            return { statusCode: 400, body: JSON.stringify({ error: "Missing parameters." }) };
        }

        // Trigger the Sovereign Orchestrator on PolyAPI eu1
        // This call leaves the US-controlled AWS environment to process in the EU1 zone
        const result = await poly.greenLogisticsOptimizer.optimizeGreenRoute(
            origin, 
            destination, 
            weight_kg
        );

        return {
            statusCode: 200,
            headers: { 
                "Content-Type": "application/json",
                "X-Data-Sovereignty": "Verified-PolyAPI-EU1" 
            },
            body: JSON.stringify(result),
        };

    } catch (error) {
        console.error("PolyAPI Orchestration Error:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: "Sovereign Orchestration Failed" })
        };
    }
};