import type { HealthEvent } from '../model/HealthEvent'
import { DateUtils } from '../common/DateUtils'

@Component
export struct HealthItem {
  @Prop item: HealthEvent
  @Prop highlight: boolean = false
  @Prop onEdit: (item: HealthEvent) => void = () => {}
  @Prop onDelete: (id: number) => void = () => {}

  build() {
    Row({ space: 12 }) {
      Column() {
        Text(DateUtils.formatDisplayDate(this.item.eventDate))
          .fontSize(12)
          .fontColor('#999999')
        Circle()
          .width(10)
          .height(10)
          .fill(this.highlight ? '#FF7A45' : '#7AB6FF')
          .margin({ top: 8, bottom: 8 })
        Blank()
      }
      .width(56)

      Column({ space: 8 }) {
        Row() {
          Text(this.item.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
          Text(this.item.eventType)
            .fontSize(12)
            .fontColor(this.highlight ? '#FF7A45' : '#666666')
        }
        Text(this.item.hospital || '未填写地点')
          .fontSize(13)
          .fontColor('#666666')
        if (this.item.nextDate) {
          Text(`下次提醒：${DateUtils.formatDisplayDate(this.item.nextDate)}`)
            .fontSize(12)
            .fontColor(this.highlight ? '#FF7A45' : '#999999')
        }
        if (this.item.note) {
          Text(this.item.note)
            .fontSize(12)
            .fontColor('#999999')
        }
        Row({ space: 10 }) {
          Button('编辑')
            .type(ButtonType.Capsule)
            .fontSize(12)
            .onClick(() => this.onEdit(this.item))
          Button('删除')
            .type(ButtonType.Capsule)
            .backgroundColor('#FFE8E8')
            .fontColor('#D9363E')
            .fontSize(12)
            .onClick(() => this.onDelete(this.item.id))
        }
      }
      .layoutWeight(1)
      .padding(14)
      .borderRadius(16)
      .backgroundColor(this.highlight ? '#FFF5F0' : '#FFFFFF')
    }
    .alignItems(VerticalAlign.Top)
  }
}
