import media from '@ohos.multimedia.media';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import fs from '@ohos.file.fs';
import { RecordingFile } from '../model/RecordingFile';

@Entry
@Component
struct RecordingPreviewPage {
  @State file?: RecordingFile = AppStorage.Get<RecordingFile>('selectedRecording');
  @State isPrepared: boolean = false;
  private player?: media.AVPlayer;
  private fileHandle?: fs.File;

  async aboutToAppear(): Promise<void> {
    if (!this.file) {
      return;
    }

    this.player = await media.createAVPlayer();
    this.fileHandle = await fs.open(this.file.path, fs.OpenMode.READ_ONLY);
    this.player.fdSrc = {
      fd: this.fileHandle.fd
    };
    await this.player.prepare();
    this.isPrepared = true;
  }

  async aboutToDisappear(): Promise<void> {
    if (this.player) {
      await this.player.release();
      this.player = undefined;
    }
    if (this.fileHandle) {
      await fs.close(this.fileHandle);
      this.fileHandle = undefined;
    }
  }

  build() {
    Column({ space: 18 }) {
      Text('Recording preview')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      if (!this.file) {
        Text('No recording selected.')
      } else {
        Column({ space: 12 }) {
          Text(this.file.name)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          Text(this.file.path)
            .fontSize(12)
            .fontColor('#6B7280')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.isPrepared ? 'Player prepared. Use Play to start preview.' : 'Preparing player...')
            .fontSize(14)
            .fontColor('#4B5563')

          Row({ space: 12 }) {
            Button('Play')
              .layoutWeight(1)
              .backgroundColor('#10B981')
              .fontColor('#FFFFFF')
              .enabled(this.isPrepared)
              .onClick(async () => {
                await this.player?.play();
              })
            Button('Pause')
              .layoutWeight(1)
              .backgroundColor('#F59E0B')
              .fontColor('#111827')
              .enabled(this.isPrepared)
              .onClick(async () => {
                await this.player?.pause();
              })
          }
          .width('100%')

          Row({ space: 12 }) {
            Button('To GIF')
              .layoutWeight(1)
              .backgroundColor('#6366F1')
              .fontColor('#FFFFFF')
              .onClick(() => {
                router.pushUrl({ url: 'pages/GifConvertPage' });
              })
            Button('Share')
              .layoutWeight(1)
              .backgroundColor('#E5E7EB')
              .fontColor('#111827')
              .onClick(() => {
                promptAction.showToast({ message: 'Share integration can be attached to the saved file path.' });
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#F3F4F6')
  }
}

export default RecordingPreviewPage;
