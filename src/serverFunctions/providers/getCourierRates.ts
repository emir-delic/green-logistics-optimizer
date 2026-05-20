/**
 * @polyapi.function
 * Simulated Courier Shipping Rate Provider
 */
export async function getCourierRates(origin: string, destination: string, weightKg: number) {
  return {
    carrier: "COURIER_EXPRESS",
    quote_id: `QT-${Math.floor(1000000 + Math.random() * 9000000)}`,
    service: "Express Worldwide",
    currency: "EUR",
    total_price: 42.50,
    estimated_delivery: "2026-04-26T14:00:00Z",
    constraints: {
      max_weight_kg: 70,
      carbon_neutral_option: true
    }
  };
}