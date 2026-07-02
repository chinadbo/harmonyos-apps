# HarmonyCompass

A beautiful, native HarmonyOS NEXT compass application with real-time heading display, GPS coordinates, and smooth sensor-driven animations.

## Features

- **Real-time Compass**: 360° heading with smooth needle animation
- **Canvas-drawn Rose**: Custom-rendered compass face with degree markings and cardinal directions
- **Sensor Fusion**: Uses device orientation sensor with low-pass filtering for jitter-free readings
- **GPS Location**: Displays latitude, longitude, and altitude
- **Dark Theme**: Elegant dark UI optimized for outdoor visibility
- **Smooth Animation**: 60fps canvas rendering with interpolated rotation

## Architecture

```
HarmonyCompass/
├── AppScope/                  # App-level configuration
├── entry/src/main/
│   ├── ets/
│   │   ├── entryability/      # EntryAbility
│   │   ├── pages/             # IndexPage (main UI)
│   │   ├── components/        # UI components
│   │   │   ├── CompassFace.ets    # Canvas compass rose
│   │   │   ├── DegreeDisplay.ets  # Heading degree readout
│   │   │   └── DirectionText.ets  # Cardinal direction text
│   │   ├── services/          # Business logic
│   │   │   ├── SensorService.ets   # Orientation sensor manager
│   │   │   └── LocationService.ets # GPS location manager
│   │   └── utils/             # Utilities
│   │       └── LowPassFilter.ets   # Sensor smoothing
│   └── resources/             # Strings, colors, profiles
```

## Tech Stack

- **Language**: ArkTS
- **UI**: ArkUI with CanvasRenderingContext2D
- **Sensors**: `@ohos.sensor` (Orientation)
- **Location**: `@ohos.geoLocationManager`
- **API Level**: 16+

## Permissions

- `ohos.permission.LOCATION` - For GPS coordinates
- `ohos.permission.APPROXIMATELY_LOCATION` - For approximate location

> Orientation sensor does not require explicit permission.

## Build

```bash
# Using DevEco Studio or command line
hvigor build
```

## Screenshots

The app features:
- Large rotating compass rose with N/E/S/W markings
- Bold degree display (0-360°)
- Cardinal direction name (North, Northeast, etc.)
- Location info card with Lat/Lon/Alt
- Refresh button for GPS update

## Design

- Color scheme: Dark navy (#1a1a2e) background with red accent (#e94560)
- Compass face: Deep blue (#16213e) with white/gray markings
- Needle: Red (North) / Blue (South) with subtle highlight
- Optimized for outdoor readability in direct sunlight

## License

MIT
