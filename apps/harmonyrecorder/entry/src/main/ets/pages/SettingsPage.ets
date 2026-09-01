import router from '@ohos.router';
import { DEFAULT_RECORDING_CONFIG, RecordingConfig } from '../model/RecordingConfig';
import { recordingService } from '../service/RecordingService';

@Entry
@Component
struct SettingsPage {
  @State config: RecordingConfig = AppStorage.Get<RecordingConfig>('recordingConfig') ?? DEFAULT_RECORDING_CONFIG;

  private saveConfig(): void {
    AppStorage.SetOrCreate('recordingConfig', this.config);
    recordingService.updateConfig(this.config);
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('Recording settings')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        Column({ space: 10 }) {
          Text('Resolution')
            .width('100%')
            .textAlign(TextAlign.Start)
          Select([{ value: '720p' }, { value: '1080p' }, { value: 'native' }])
            .selected(this.config.resolution === '720p' ? 0 : this.config.resolution === '1080p' ? 1 : 2)
            .onSelect((index: number) => {
              const options: Array<'720p' | '1080p' | 'native'> = ['720p', '1080p', 'native'];
              this.config = { ...this.config, resolution: options[index] };
            })

          Text('Frame rate')
            .width('100%')
            .textAlign(TextAlign.Start)
          Select([{ value: '30 fps' }, { value: '60 fps' }])
            .selected(this.config.frameRate === 30 ? 0 : 1)
            .onSelect((index: number) => {
              this.config = { ...this.config, frameRate: index === 0 ? 30 : 60 };
            })

          Text('Countdown')
            .width('100%')
            .textAlign(TextAlign.Start)
          Select([{ value: '0 s' }, { value: '3 s' }, { value: '5 s' }, { value: '10 s' }])
            .selected(this.config.countdownSeconds === 0 ? 0 : this.config.countdownSeconds === 3 ? 1 : this.config.countdownSeconds === 5 ? 2 : 3)
            .onSelect((index: number) => {
              const options: Array<0 | 3 | 5 | 10> = [0, 3, 5, 10];
              this.config = { ...this.config, countdownSeconds: options[index] };
            })

          Toggle({ type: ToggleType.Switch, isOn: this.config.enableAudio })
            .onChange((value: boolean) => {
              this.config = { ...this.config, enableAudio: value };
            })
          Text('Enable microphone audio')
            .width('100%')
            .textAlign(TextAlign.Start)

          Toggle({ type: ToggleType.Switch, isOn: this.config.enableAnnotation })
            .onChange((value: boolean) => {
              this.config = { ...this.config, enableAnnotation: value };
            })
          Text('Enable annotation overlay by default')
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Button('Save settings')
          .width('100%')
          .height(52)
          .backgroundColor('#111827')
          .fontColor('#FFFFFF')
          .onClick(() => this.saveConfig())
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F4F6')
  }
}

export default SettingsPage;
