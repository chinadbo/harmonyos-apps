import { DiaryListItem, DiaryMood } from '../model/DiaryModel';
import { getMoodOption } from '../utils/MoodConfig';

@Component
export struct DiaryCard {
  @Prop item: DiaryListItem = { id: 0, title: '', excerpt: '', mood: DiaryMood.Calm, date: '', updatedAt: 0, imagePaths: [] };
  onClick: (id: number) => void = () => {};

  build() {
    const mood = getMoodOption(this.item.mood);
    Row({ space: 14 }) {
      Column({ space: 8 }) {
        Row() {
          Text(this.item.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#0F172A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Blank()
          Text(mood.label)
            .fontSize(12)
            .fontColor(mood.textColor)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(mood.color)
            .borderRadius(14)
        }
        .width('100%')
        Text(this.item.date)
          .fontSize(12)
          .fontColor('#64748B')
        Text(this.item.excerpt.length > 0 ? this.item.excerpt : '这篇日记还没有写下正文')
          .fontSize(14)
          .lineHeight(22)
          .fontColor('#334155')
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.item.imagePaths.length > 0) {
        Image(this.item.imagePaths[0])
          .width(74)
          .height(74)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .shadow({ radius: 18, color: '#140F172A', offsetX: 0, offsetY: 8 })
    .onClick(() => this.onClick(this.item.id))
  }
}
