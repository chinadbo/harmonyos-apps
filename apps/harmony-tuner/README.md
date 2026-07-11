# HarmonyTuner

Professional instrument tuner for HarmonyOS. Real-time pitch detection with FFT analysis and visual needle gauge.

## Features

- **Real-time Tuning** — Live pitch detection via microphone using FFT + autocorrelation
- **Multi-instrument Support** — Guitar, Ukulele, Violin, Bass with standard tuning presets
- **Visual Needle Gauge** — Canvas-based tuning meter with color-coded zones
- **Tuning History** — Track and review your tuning sessions
- **Customizable Reference** — Adjustable A4 frequency (432-444 Hz) and sensitivity
- **Note Display** — Clear note name + octave with cent deviation readout

## Technical Highlights

1. **AudioCapturer PCM Streaming** — Real-time 44.1kHz mono capture with 2048-sample buffer
2. **FFT Implementation** — ArkTS Cooley-Tukey algorithm for frequency domain analysis
3. **Pitch Detection** — Dual algorithm: FFT peak detection + autocorrelation validation
4. **Parabolic Interpolation** — Sub-bin precision for accurate frequency estimation
5. **Canvas Rendering** — Real-time needle gauge with color-coded tuning zones

## Architecture

```
entry/src/main/ets/
├── audio/          — Audio capture & buffer management
├── signal/         — FFT, pitch detection, frequency utils
├── tuner/          — Tuner engine & instrument configs
├── data/           — Tuning history & records
├── pages/          — UI pages (Index, InstrumentSelect, History, Settings)
└── components/     — Reusable UI components
```

## Build

```bash
hvigorw assembleHap
```

## Permissions

- `ohos.permission.MICROPHONE` — Required for audio pitch detection

## License

MIT
