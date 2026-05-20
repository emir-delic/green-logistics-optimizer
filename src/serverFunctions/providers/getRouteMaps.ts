/**
 * @polyapi.function
 * Simulated Mapping and Route Matrix Provider
 */
export async function getRouteMaps(origin: string, destination: string) {
  return {
    code: "Ok",
    durations: [[37800]], 
    distances: [[1052000]], 
    units: {
      duration: "seconds",
      distance: "meters"
    },
    route_summary: "A2 / A36 via Frankfurt and Mulhouse"
  };
}