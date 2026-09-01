import promptAction from '@ohos.promptAction';
import { recordingService } from '../service/RecordingService';
import { RecordingState } from '../model/RecordingState';
import { windowManager } from '../service/WindowManager';

@Reusable
@Component
export struct FloatingWindow {
  @State private state: RecordingState = recordingService.getState();
  @State private durationMs: number = recordingService.getDurationMs();
  private unsubscribe?: () => void;

  aboutToAppear(): void {
    this.unsubscribe = recordingService.subscribe((state: RecordingState, _: number, durationMs: number) => {
      this.state = state;
      this.durationMs = durationMs;
    });
  }

  aboutToDisappear(): void {
    this.unsubscribe?.();
  }

  private formatDuration(durationMs: number): string {
    const totalSeconds: number = Math.floor(durationMs / 1000);
    const minutes: number = Math.floor(totalSeconds / 60);
    const seconds: number = totalSeconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  build() {
    Column({ space: 12 }) {
      Text(this.formatDuration(this.durationMs))
        .fontColor('#FFFFFF')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Row({ space: 10 }) {
        if (this.state === RecordingState.RECORDING) {
          Button('Pause')
            .backgroundColor('#F59E0B')
            .fontColor('#111827')
            .onClick(async () => {
              await recordingService.pauseRecording();
            })
        } else if (this.state === RecordingState.PAUSED) {
          Button('Resume')
            .backgroundColor('#10B981')
            .fontColor('#FFFFFF')
            .onClick(async () => {
              await recordingService.resumeRecording();
            })
        }

        Button('Stop')
          .backgroundColor('#EF4444')
          .fontColor('#FFFFFF')
          .onClick(async () => {
            await recordingService.stopRecording();
            await windowManager.destroyFloatingWindow();
            promptAction.showToast({ message: 'Recording stopped.' });
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding(16)
    .backgroundColor('#CC111827')
    .borderRadius(120)
  }
}
