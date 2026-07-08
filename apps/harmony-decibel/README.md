# HarmonyDecibel

A professional noise level meter and decibel detector for HarmonyOS.

## Features

- **Real-time Decibel Measurement**: Continuous noise level monitoring with microphone input
- **Statistical Analysis**: Average, maximum, and minimum dB values during measurement sessions
- **Visual History Curve**: Canvas-based real-time graph of the last 60 seconds of measurements
- **Noise Level Reference**: Built-in reference table for common noise sources and hearing safety guidelines
- **Customizable Threshold Alerts**: Set custom dB thresholds with vibration and audio alerts
- **Calibration Offset**: Adjust for device-specific microphone sensitivity
- **Measurement History**: Save and review past measurement sessions with RDB persistent storage
- **Theme Support**: Light and dark theme options

## Architecture

```
HarmonyDecibel/
├── capture/           - AudioCaptureManager (microphone input)
├── analysis/          - DecibelAnalyzer (RMS → dB SPL conversion)
├── data/              - RDB repository for sessions + Preferences for settings
├── services/          - ThresholdAlertService (vibration + tone)
├── components/        - DecibelDisplay, ControlPanel, ReferenceCard
└── pages/             - Index, History, Settings, Reference
```

## Tech Stack

- HarmonyOS API 16
- ArkUI with V1 decorators (@Component, @State, @Prop)
- AVAudioCapturer for audio acquisition
- RDB (relationalStore) for measurement history
- Canvas 2D for real-time decibel curve
- Vibrator for threshold alerts

## Build

```bash
# Requires HarmonyOS SDK and DevEco Studio
hpm install
hpm build
```

## Permissions

- `ohos.permission.MICROPHONE` — Noise measurement
- `ohos.permission.VIBRATE` — Alert notifications
- `ohos.permission.KEEP_BACKGROUND_RUNNING` — Background monitoring (optional)

## License

MIT
