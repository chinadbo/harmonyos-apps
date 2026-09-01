import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { RecordingFile } from '../model/RecordingFile';
import { gifConverter } from '../service/GifConverter';

@Entry
@Component
struct GifConvertPage {
  @State file?: RecordingFile = AppStorage.Get<RecordingFile>('selectedRecording');
  @State frameRateIndex: number = 1;
  @State progress: number = 0;
  @State outputPath: string = '';
  @State isConverting: boolean = false;

  private getContext(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  private async convert(): Promise<void> {
    if (!this.file) {
      promptAction.showToast({ message: 'Select a recording first.' });
      return;
    }

    try {
      this.isConverting = true;
      this.progress = 0;
      const frameRate: number = this.frameRateIndex === 0 ? 8 : this.frameRateIndex === 1 ? 12 : 16;
      this.outputPath = await gifConverter.convertVideoToGif(this.getContext(), this.file.path, frameRate, (progress: number) => {
        this.progress = progress;
      });
      promptAction.showToast({ message: 'GIF export completed.' });
    } catch (error) {
      promptAction.showToast({ message: `GIF export failed: ${JSON.stringify(error)}` });
    } finally {
      this.isConverting = false;
    }
  }

  build() {
    Column({ space: 18 }) {
      Text('GIF converter')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 10 }) {
        Text(this.file ? this.file.name : 'No selected recording')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Start)
        Select([{ value: '8 fps' }, { value: '12 fps' }, { value: '16 fps' }])
          .selected(this.frameRateIndex)
          .onSelect((index: number) => {
            this.frameRateIndex = index;
          })
        Button(this.isConverting ? 'Converting...' : 'Start GIF export')
          .width('100%')
          .backgroundColor('#111827')
          .fontColor('#FFFFFF')
          .enabled(!this.isConverting)
          .onClick(() => this.convert())
        Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
          .width('100%')
        if (this.outputPath.length > 0) {
          Text(`Saved to ${this.outputPath}`)
            .fontSize(12)
            .fontColor('#4B5563')
        }
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#F3F4F6')
  }
}

export default GifConvertPage;
