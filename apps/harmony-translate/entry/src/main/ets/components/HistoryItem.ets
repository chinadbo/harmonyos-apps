import { TranslateRecord } from '../model/TranslateRecord';
import { TimeUtil } from '../utils/TimeUtil';
import { getLanguageName, getLanguageFlag } from '../model/Language';

@Component
export struct HistoryItem {
  @Prop record: TranslateRecord;
  onTap: () => void = () => {};
  onDelete: () => void = () => {};
  onFavorite: () => void = () => {};

  build() {
    Row() {
      Column() {
        Text(`${this.record.sourceText.substring(0, 50)}${this.record.sourceText.length > 50 ? '...' : ''}`)
          .fontSize(15)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(`${this.record.resultText.substring(0, 50)}${this.record.resultText.length > 50 ? '...' : ''}`)
          .fontSize(14)
          .fontColor('#666666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 4 })

        Row() {
          Text(`${getLanguageFlag(this.record.sourceLang)} ${getLanguageName(this.record.sourceLang)} → ${getLanguageFlag(this.record.targetLang)} ${getLanguageName(this.record.targetLang)}`)
            .fontSize(12)
            .fontColor('#999999')

          Text(TimeUtil.relativeTime(this.record.createdAt))
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 6 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text(this.record.isFavorite ? '⭐' : '☆')
          .fontSize(20)
          .onClick(() => this.onFavorite())
          .margin({ bottom: 8 })

        Text('🗑️')
          .fontSize(20)
          .onClick(() => this.onDelete())
      }
      .width(40)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => this.onTap())
  }
}
