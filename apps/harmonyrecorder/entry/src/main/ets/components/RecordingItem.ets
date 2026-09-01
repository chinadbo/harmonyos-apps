import { RecordingFile } from '../model/RecordingFile';

@Component
export struct RecordingItem {
  @Prop file: RecordingFile;

  build() {
    Column({ space: 8 }) {
      Text(this.file.name)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(`Created ${this.file.createdAt}`)
        .fontSize(12)
        .fontColor('#6B7280')
      Row({ space: 16 }) {
        Text(`${this.file.duration}s`)
          .fontSize(12)
          .fontColor('#4B5563')
        Text(`${Math.max(1, Math.floor(this.file.size / 1024))} KB`)
          .fontSize(12)
          .fontColor('#4B5563')
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}
