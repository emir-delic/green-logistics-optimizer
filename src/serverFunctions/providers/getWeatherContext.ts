/**
 * @polyapi.function
 * Simulated Weather Context Provider
 */
export async function getWeatherContext(city: string) {
  return {
    location: city,
    lat: 48.57,
    lon: 7.75,
    weather: {
      condition: "Heavy Rain",
      temp_celsius: 12.5,
      wind_speed_ms: 8.4,
      visibility_meters: 2500
    },
    hazard_level: "Medium",
    impact_on_delivery: "+2 hours"
  };
}