import router from '@ohos.router';
import { DEFAULT_RECORDING_CONFIG, RecordingConfig } from '../model/RecordingConfig';

@Entry
@Component
struct HomePage {
  @State config: RecordingConfig = AppStorage.Get<RecordingConfig>('recordingConfig') ?? DEFAULT_RECORDING_CONFIG;

  aboutToAppear(): void {
    const storedConfig: RecordingConfig | undefined = AppStorage.Get<RecordingConfig>('recordingConfig');
    if (storedConfig) {
      this.config = storedConfig;
    } else {
      AppStorage.SetOrCreate('recordingConfig', this.config);
    }
  }

  @Builder
  private navCard(title: string, subtitle: string, target: string): void {
    Row() {
      Column({ space: 6 }) {
        Text(title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Text(subtitle)
          .fontSize(14)
          .fontColor('#6B7280')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Text('>')
        .fontSize(18)
        .fontColor('#9CA3AF')
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .onClick(() => {
      router.pushUrl({ url: target });
    })
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 8 }) {
          Text('HarmonyRecorder')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
          Text('Screen capture, floating controls, annotations, playback, and GIF export in one HarmonyOS app.')
            .fontSize(15)
            .fontColor('#4B5563')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Column({ space: 10 }) {
          Text('Current defaults')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          Text(`Resolution: ${this.config.resolution}`)
          Text(`Frame rate: ${this.config.frameRate} fps`)
          Text(`Audio: ${this.config.enableAudio ? 'on' : 'off'}`)
          Text(`Countdown: ${this.config.countdownSeconds}s`)
          Text(`Annotation: ${this.config.enableAnnotation ? 'on' : 'off'}`)
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#EEF2FF')
        .borderRadius(20)
        .alignItems(HorizontalAlign.Start)

        this.navCard('Start recording', 'Configure and start a capture session.', 'pages/RecordingPage')
        this.navCard('Recording library', 'Browse saved recordings and thumbnails.', 'pages/RecordingListPage')
        this.navCard('GIF converter', 'Export a saved recording to GIF.', 'pages/GifConvertPage')
        this.navCard('Settings', 'Update recording defaults.', 'pages/SettingsPage')
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F4F6')
  }
}
