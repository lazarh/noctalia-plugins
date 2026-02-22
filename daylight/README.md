# Daylight

A bar widget that displays a sun or moon icon based on the current time of day, with a panel showing sunrise time, sunset time, and total daylight duration.

## Features

- Shows sun icon during daytime, moon icon at night
- Left click opens a panel with sunrise, sunset and daylight duration
- Right click opens the context menu for quick access to settings
- Optional location override — defaults to Noctalia's built-in Location Service
- When a custom location is set, data is fetched directly from [Open-Meteo](https://open-meteo.com/)
- Hourly refresh to keep sunrise/sunset times accurate throughout the day

## Configuration

| Setting | Description |
|---|---|
| **Location** | Optional. City and ISO country code (e.g. `London, GB`). Overrides the location determined by Noctalia's Location Service. Leave empty to use the global location. |

## Data sources

- **No location override**: uses Noctalia's built-in `LocationService` (Open-Meteo via the global location setting)
- **Location override**: geocodes the city via [Open-Meteo Geocoding API](https://open-meteo.com/en/docs/geocoding-api), then fetches daily sunrise/sunset and `is_day` from [Open-Meteo Forecast API](https://open-meteo.com/en/docs)

## Requirements

- Noctalia 4.3.0 or higher
