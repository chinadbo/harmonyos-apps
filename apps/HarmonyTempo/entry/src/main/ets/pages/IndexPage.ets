import common from '@ohos.app.ability.common';
import { BeatIndicator } from '../components/BeatIndicator';
import { BpmController } from '../components/BpmController';
import { TimeSignatureSelector } from '../components/TimeSignatureSelector';
import { TapTempoButton } from '../components/TapTempoButton';
import { SoundSelector } from '../components/SoundSelector';
import { COLORS, DEFAULT_BPM, DEFAULT_TIMER_MINUTES, MAX_BPM, MAX_TIMER_MINUTES, MIN_BPM, PAGE_ABOUT, PAGE_SETTINGS } from '../constants/AppConstants';
import { preferencesService } from '../services/PreferencesService';
import { metronomeService } from '../services/MetronomeService';
import { soundPoolService } from '../services/SoundPoolService';
import type { BeatState } from '../constants/AppTypes';

@Component
export struct IndexPage {
  @Prop stack: NavPathStack = new NavPathStack();
  @StorageLink('isDarkMode') isDarkMode: boolean = true;
  @State private bpm: number = DEFAULT_BPM;
  @State private timeSignature: string = '4/4';
  @State private soundType: string = 'classic';
  @State private currentBeat: number = 1;
  @State private beatsPerMeasure: number = 4;
  @State private isAccent: boolean = true;
  @State private isPlaying: boolean = false;
  @State private timerMinutes: number = DEFAULT_TIMER_MINUTES;
  @State private remainingSeconds: number = DEFAULT_TIMER_MINUTES * 60;
  @State private ready: boolean = false;
  @State private errorMessage: string = '';

  aboutToAppear(): void {
    void this.loadPageState();
  }

  private async loadPageState(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      await preferencesService.init(context);
      const settings = await preferencesService.getSettings();
      this.bpm = settings.bpm;
      this.timeSignature = settings.timeSignature;
      this.soundType = settings.soundType;
      this.isDarkMode = settings.isDarkMode;
      AppStorage.setOrCreate('isDarkMode', settings.isDarkMode);
      await soundPoolService.init(context);
      this.configureMetronome();
      this.ready = true;
    } catch (error) {
      this.errorMessage = 'Unable to initialize HarmonyTempo.';
    }
  }

  aboutToDisappear(): void {
    metronomeService.release();
    void soundPoolService.release();
  }

  private configureMetronome(): void {
    metronomeService.configure({
      bpm: this.bpm,
      timeSignature: this.timeSignature,
      durationMinutes: this.timerMinutes,
      onBeat: (state: BeatState) => {
        this.currentBeat = state.currentBeat;
        this.beatsPerMeasure = state.beatsPerMeasure;
        this.isAccent = state.isAccent;
      },
      onTimer: (remainingSeconds: number) => {
        this.remainingSeconds = remainingSeconds;
      },
      onStop: () => {
        this.isPlaying = false;
        this.currentBeat = 1;
      },
      playSound: (isAccent: boolean) => {
        if (isAccent) {
          soundPoolService.playAccent(this.soundType);
        } else {
          soundPoolService.playBeat(this.soundType);
        }
      }
    });
    this.remainingSeconds = metronomeService.getRemainingSeconds();
  }

  private async updateBpm(nextBpm: number): Promise<void> {
    const clamped: number = Math.min(MAX_BPM, Math.max(MIN_BPM, nextBpm));
    this.bpm = clamped;
    metronomeService.updateBpm(clamped);
    await preferencesService.setBpm(clamped);
  }

  private async updateTimeSignature(value: string): Promise<void> {
    this.timeSignature = value;
    this.beatsPerMeasure = Number(value.split('/')[0]);
    this.currentBeat = 1;
    metronomeService.updateTimeSignature(value);
    await preferencesService.setTimeSignature(value);
  }

  private async updateSoundType(value: string): Promise<void> {
    this.soundType = value;
    await preferencesService.setSoundType(value);
  }

  private adjustTimer(delta: number): void {
    const nextValue: number = Math.min(MAX_TIMER_MINUTES, Math.max(1, this.timerMinutes + delta));
    this.timerMinutes = nextValue;
    metronomeService.updateDurationMinutes(nextValue);
    this.remainingSeconds = metronomeService.getRemainingSeconds();
  }

  private togglePlayback(): void {
    if (!this.ready) {
      return;
    }
    metronomeService.toggle();
    this.isPlaying = metronomeService.isRunning();
  }

  private formatTime(totalSeconds: number): string {
    const safeValue: number = Math.max(0, totalSeconds);
    const minutes: number = Math.floor(safeValue / 60);
    const seconds: number = safeValue % 60;
    const paddedSeconds: string = seconds < 10 ? `0${seconds}` : `${seconds}`;
    return `${minutes}:${paddedSeconds}`;
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Column({ space: 6 }) {
            Text('HarmonyTempo')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.textPrimary)
            Text('A focused metronome for steady practice')
              .fontSize(15)
              .fontColor(COLORS.textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Button('Settings')
            .backgroundColor(COLORS.surfaceAlt)
            .fontColor(COLORS.textPrimary)
            .onClick(() => {
              this.stack.pushPath({ name: PAGE_SETTINGS, param: {} });
            })
        }
        .width('100%')

        BeatIndicator({
          currentBeat: this.currentBeat,
          beatsPerMeasure: this.beatsPerMeasure,
          isAccent: this.isAccent,
          isDarkMode: this.isDarkMode
        })

        Row({ space: 12 }) {
          Button(this.isPlaying ? 'Stop' : 'Start')
            .layoutWeight(1)
            .height(54)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .backgroundColor(this.isPlaying ? COLORS.danger : COLORS.primary)
            .fontColor(COLORS.textPrimary)
            .onClick(() => {
              this.togglePlayback();
            })
          Button('About')
            .width(100)
            .height(54)
            .fontSize(18)
            .backgroundColor(COLORS.surfaceAlt)
            .fontColor(COLORS.textPrimary)
            .onClick(() => {
              this.stack.pushPath({ name: PAGE_ABOUT, param: {} });
            })
        }
        .width('100%')

        Row() {
          Column({ space: 6 }) {
            Text('Practice Timer')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(COLORS.textPrimary)
            Text(this.formatTime(this.remainingSeconds))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.warning)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Row({ space: 10 }) {
            Button('-')
              .width(44)
              .height(44)
              .backgroundColor(COLORS.surfaceAlt)
              .onClick(() => {
                this.adjustTimer(-1);
              })
            Text(`${this.timerMinutes} min`)
              .fontSize(18)
              .fontColor(COLORS.textPrimary)
            Button('+')
              .width(44)
              .height(44)
              .backgroundColor(COLORS.surfaceAlt)
              .onClick(() => {
                this.adjustTimer(1);
              })
          }
        }
        .padding(18)
        .backgroundColor(COLORS.surface)
        .borderRadius(24)
        .width('100%')

        BpmController({
          bpm: this.bpm,
          onDecrease: () => {
            this.updateBpm(this.bpm - 1);
          },
          onIncrease: () => {
            this.updateBpm(this.bpm + 1);
          },
          onChange: (value: number) => {
            this.updateBpm(value);
          }
        })

        TimeSignatureSelector({
          selected: this.timeSignature,
          onSelect: (value: string) => {
            this.updateTimeSignature(value);
          }
        })

        SoundSelector({
          selected: this.soundType,
          onSelect: (value: string) => {
            this.updateSoundType(value);
          }
        })

        TapTempoButton({
          onTempoDetected: (value: number) => {
            this.updateBpm(value);
          }
        })

        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor(COLORS.danger)
            .width('100%')
        }
      }
      .padding(20)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .scrollBar(BarState.Off)
    .backgroundColor(COLORS.background)
    .width('100%')
    .height('100%')
  }
}
