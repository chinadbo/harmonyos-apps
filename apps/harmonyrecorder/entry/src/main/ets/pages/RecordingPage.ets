import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { AnnotationCanvas, DrawStroke } from '../components/AnnotationCanvas';
import { AnnotationToolbar, AnnotationTool } from '../components/AnnotationToolbar';
import { DEFAULT_RECORDING_CONFIG, RecordingConfig } from '../model/RecordingConfig';
import { RecordingState } from '../model/RecordingState';
import { recordingService } from '../service/RecordingService';
import { windowManager } from '../service/WindowManager';

@Entry
@Component
struct RecordingPage {
  @State config: RecordingConfig = AppStorage.Get<RecordingConfig>('recordingConfig') ?? DEFAULT_RECORDING_CONFIG;
  @State recordingState: RecordingState = recordingService.getState();
  @State countdownValue: number = recordingService.getCountdownValue();
  @State durationMs: number = recordingService.getDurationMs();
  @State strokes: Array<DrawStroke> = [];
  @State selectedTool: AnnotationTool = 'pen';
  @State selectedColor: string = '#FF3B30';
  private unsubscribe?: () => void;

  aboutToAppear(): void {
    this.unsubscribe = recordingService.subscribe((state: RecordingState, countdownValue: number, durationMs: number) => {
      this.recordingState = state;
      this.countdownValue = countdownValue;
      this.durationMs = durationMs;
    });
    const storedConfig: RecordingConfig | undefined = AppStorage.Get<RecordingConfig>('recordingConfig');
    if (storedConfig) {
      this.config = storedConfig;
      recordingService.updateConfig(storedConfig);
    }
  }

  aboutToDisappear(): void {
    this.unsubscribe?.();
  }

  private getContext(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  private formatDuration(durationMs: number): string {
    const totalSeconds: number = Math.floor(durationMs / 1000);
    const minutes: number = Math.floor(totalSeconds / 60);
    const seconds: number = totalSeconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  private async startRecording(): Promise<void> {
    try {
      recordingService.updateConfig(this.config);
      await recordingService.startRecording(this.getContext());
      promptAction.showToast({ message: 'Recording started.' });
    } catch (error) {
      promptAction.showToast({ message: `Unable to start recording: ${JSON.stringify(error)}` });
    }
  }

  private async stopRecording(): Promise<void> {
    const recordingFile = await recordingService.stopRecording();
    await windowManager.destroyFloatingWindow();
    if (recordingFile) {
      AppStorage.SetOrCreate('selectedRecording', recordingFile);
      router.pushUrl({ url: 'pages/RecordingPreviewPage' });
    }
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('Screen recording')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        Column({ space: 8 }) {
          Text(`State: ${this.recordingState}`)
          Text(`Duration: ${this.formatDuration(this.durationMs)}`)
          if (this.recordingState === RecordingState.COUNTING) {
            Text(`Starting in ${this.countdownValue}`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#DC2626')
          }
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          Row({ space: 12 }) {
            Button('Start')
              .layoutWeight(1)
              .backgroundColor('#10B981')
              .fontColor('#FFFFFF')
              .enabled(this.recordingState === RecordingState.IDLE)
              .onClick(() => this.startRecording())
            Button('Pause')
              .layoutWeight(1)
              .backgroundColor('#F59E0B')
              .fontColor('#111827')
              .enabled(this.recordingState === RecordingState.RECORDING)
              .onClick(async () => {
                await recordingService.pauseRecording();
              })
          }
          .width('100%')

          Row({ space: 12 }) {
            Button('Resume')
              .layoutWeight(1)
              .backgroundColor('#3B82F6')
              .fontColor('#FFFFFF')
              .enabled(this.recordingState === RecordingState.PAUSED)
              .onClick(async () => {
                await recordingService.resumeRecording();
              })
            Button('Stop')
              .layoutWeight(1)
              .backgroundColor('#EF4444')
              .fontColor('#FFFFFF')
              .enabled(this.recordingState === RecordingState.RECORDING || this.recordingState === RecordingState.PAUSED)
              .onClick(() => this.stopRecording())
          }
          .width('100%')

          Button('Enter floating mode')
            .width('100%')
            .backgroundColor('#111827')
            .fontColor('#FFFFFF')
            .enabled(this.recordingState === RecordingState.RECORDING || this.recordingState === RecordingState.PAUSED)
            .onClick(async () => {
              await windowManager.showFloatingWindow(this.getContext(), 'pages/FloatingPage');
              promptAction.showToast({ message: 'Floating controls opened.' });
            })
        }
        .width('100%')

        if (this.config.enableAnnotation) {
          Column({ space: 12 }) {
            Text('Annotation overlay')
              .width('100%')
              .textAlign(TextAlign.Start)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            AnnotationCanvas({
              strokes: $strokes,
              selectedTool: this.selectedTool,
              selectedColor: this.selectedColor
            })
            AnnotationToolbar({
              selectedTool: $selectedTool,
              selectedColor: $selectedColor,
              onUndo: () => {
                if (this.strokes.length > 0) {
                  this.strokes = this.strokes.slice(0, this.strokes.length - 1);
                }
              },
              onClear: () => {
                this.strokes = [];
              }
            })
          }
          .width('100%')
          .padding(18)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
        }
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F4F6')
  }
}

export default RecordingPage;
