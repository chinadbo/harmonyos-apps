import { TimeEntry } from '../model/TimeEntry'

@Component
export struct EntryItem {
  @Prop entry: TimeEntry = {
    id: 0,
    projectId: 0,
    startTime: 0,
    endTime: 0,
    duration: 0,
    note: '',
    createdAt: 0
  }
  @Prop projectName: string = ''
  @Prop projectColor: string = '#4FC3F7'

  private formatTimeRange(start: number, end: number): string {
    const startDate = new Date(start)
    const endDate = new Date(end)
    const sh = this.pad(startDate.getHours())
    const sm = this.pad(startDate.getMinutes())
    const eh = this.pad(endDate.getHours())
    const em = this.pad(endDate.getMinutes())
    return `${sh}:${sm} - ${eh}:${em}`
  }

  private formatDuration(seconds: number): string {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    if (h > 0) {
      return `${h}h ${m}m`
    }
    return `${m}m`
  }

  private pad(n: number): string {
    return n < 10 ? '0' + n.toString() : n.toString()
  }

  build() {
    Row() {
      // Color indicator bar
      Column()
        .width(4)
        .height(40)
        .borderRadius(2)
        .backgroundColor(this.projectColor)
        .margin({ right: 12 })

      // Content
      Column() {
        Row() {
          Text(this.projectName)
            .fontSize(15)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
          Text(this.formatDuration(this.entry.duration))
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')

        Row() {
          Text(this.formatTimeRange(this.entry.startTime, this.entry.endTime))
            .fontSize(13)
            .fontColor('#999999')
            .layoutWeight(1)
          if (this.entry.note.length > 0) {
            Text(this.entry.note)
              .fontSize(13)
              .fontColor('#999999')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .constraintSize({ maxWidth: '50%' })
          }
        }
        .width('100%')
        .margin({ top: 4 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }
}
