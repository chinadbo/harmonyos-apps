import { QRRecord } from '../model/QRRecord'

@Component
export struct HistoryItem {
  @Prop record: QRRecord
  onDelete?: (record: QRRecord) => void
  onToggleFavorite?: (record: QRRecord) => void
  onClick?: (record: QRRecord) => void

  private formatDate(timestamp: number): string {
    const date = new Date(timestamp)
    const month = `${date.getMonth() + 1}`.padStart(2, '0')
    const day = `${date.getDate()}`.padStart(2, '0')
    const hour = `${date.getHours()}`.padStart(2, '0')
    const minute = `${date.getMinutes()}`.padStart(2, '0')
    return `${month}-${day} ${hour}:${minute}`
  }

  @Builder
  DeleteActionBuilder() {
    Row() {
      Text('删除')
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
    }
    .width(84)
    .height('100%')
    .backgroundColor('#FFEF4444')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (this.onDelete) {
        this.onDelete(this.record)
      }
    })
  }

  build() {
    ListItem() {
      Row({ space: 12 }) {
        Text(this.record.type === 'scan' ? '扫' : '生')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.record.type === 'scan' ? '#0A59F7' : '#14B866')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .backgroundColor('#FFF1F5F9')
          .borderRadius(20)

        Column({ space: 4 }) {
          Row() {
            Text(this.record.contentType.toUpperCase())
              .fontSize(12)
              .fontColor('#FF64748B')
            Blank()
            if (this.record.isFavorite === 1) {
              Text('★')
                .fontSize(14)
                .fontColor('#FFF59E0B')
            }
          }
          .width('100%')

          Text(this.record.content)
            .fontSize(15)
            .fontColor('#FF0F172A')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.formatDate(this.record.createdAt))
            .fontSize(12)
            .fontColor('#FF94A3B8')
        }
        .layoutWeight(1)

        Column({ space: 10 }) {
          Button(this.record.isFavorite === 1 ? '取消收藏' : '收藏')
            .type(ButtonType.Capsule)
            .fontSize(12)
            .backgroundColor('#FFE2E8F0')
            .fontColor('#FF0F172A')
            .onClick(() => {
              if (this.onToggleFavorite) {
                this.onToggleFavorite(this.record)
              }
            })
        }
      }
      .padding(16)
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(18)
      .onClick(() => {
        if (this.onClick) {
          this.onClick(this.record)
        }
      })
    }
    .swipeAction({ end: { builder: this.DeleteActionBuilder.bind(this) } })
    .margin({ left: 16, right: 16, top: 10 })
  }
}
