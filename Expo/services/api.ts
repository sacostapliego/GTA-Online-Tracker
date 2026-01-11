export interface WeeklyUpdate {
  weekOf: string;
  podiumVehicle: string;
  prizeRide: string;
  bonuses: string[];
  discounts: string[];
}

// TODO: Replace with actual data source URL
const DATA_SOURCE_URL = '';

export const fetchWeeklyUpdate = async (): Promise<WeeklyUpdate | null> => {
  try {
    const response = await fetch(DATA_SOURCE_URL);
    if (!response.ok) {
        throw new Error('Network response was not ok');
    }
    const data = await response.json();
    return data as WeeklyUpdate;
  } catch (error) {
    console.error('Failed to fetch weekly update:', error);
    return null;
  }
};