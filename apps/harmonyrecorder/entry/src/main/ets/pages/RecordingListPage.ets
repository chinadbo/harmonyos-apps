import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { RecordingItem } from '../components/RecordingItem';
import { RecordingFile } from '../model/RecordingFile';
import { FileUtils } from '../utils/FileUtils';

@Entry
@Component
struct RecordingListPage {
  @State files: Array<RecordingFile> = [];
  @State loading: boolean = true;

  aboutToAppear(): void {
    this.loadFiles();
  }

  private getContext(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  private async loadFiles(): Promise<void> {
    this.loading = true;
    this.files = await FileUtils.listRecordings(this.getContext());
    this.loading = false;
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('Recording library')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('Refresh')
          .backgroundColor('#111827')
          .fontColor('#FFFFFF')
          .onClick(() => this.loadFiles())
      }
      .width('100%')

      if (this.loading) {
        LoadingProgress()
          .width(48)
          .height(48)
      } else if (this.files.length === 0) {
        Column({ space: 10 }) {
          Text('No recordings yet')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
          Text('Start a capture session from the recording page to populate the library.')
            .fontSize(14)
            .fontColor('#6B7280')
        }
        .width('100%')
        .padding(28)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
      } else {
        List({ space: 12 }) {
          ForEach(this.files, (file: RecordingFile) => {
            ListItem() {
              Column({ space: 10 }) {
                RecordingItem({ file })
                Row({ space: 12 }) {
                  Button('Preview')
                    .layoutWeight(1)
                    .backgroundColor('#3B82F6')
                    .fontColor('#FFFFFF')
                    .onClick(() => {
                      AppStorage.SetOrCreate('selectedRecording', file);
                      router.pushUrl({ url: 'pages/RecordingPreviewPage' });
                    })
                  Button('Delete')
                    .layoutWeight(1)
                    .backgroundColor('#FCA5A5')
                    .fontColor('#7F1D1D')
                    .onClick(async () => {
                      await FileUtils.removeFile(file.path);
                      promptAction.showToast({ message: 'Recording deleted.' });
                      await this.loadFiles();
                    })
                }
                .width('100%')
              }
            }
          }, (file: RecordingFile) => file.id)
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#F3F4F6')
  }
}

export default RecordingListPage;
