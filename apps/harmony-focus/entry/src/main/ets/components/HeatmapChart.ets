import { getLastNDates } from '../common/Utils'

@Component
export struct HeatmapChart {
  @Prop data: Record<string, number> = {}
  @Prop days: number = 28

  private getWeeks(): string[][] {
    const dates: string[] = getLastNDates(this.days)
    const weeks: string[][] = []
    for (let index = 0; index < dates.length; index += 7) {
      weeks.push(dates.slice(index, index + 7))
    }
    return weeks
  }

  private getCellColor(date: string): string {
    const value: number = this.data[date] ?? 0
    if (value <= 0) {
      return '#EDF2F7'
    }
    if (value === 1) {
      return '#FFD8D8'
    }
    if (value === 2) {
      return '#FFA8A8'
    }
    if (value === 3) {
      return '#FF8787'
    }
    return '#FF6B6B'
  }

  build() {
    Column({ space: 8 }) {
      Text('最近专注热力图')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#212529')
        .width('100%')
        .textAlign(TextAlign.Start)
      Column({ space: 6 }) {
        ForEach(this.getWeeks(), (week: string[]) => {
          Row({ space: 6 }) {
            ForEach(week, (date: string) => {
              Column({ space: 2 }) {
                Blank()
                  .width(34)
                  .height(34)
                  .backgroundColor(this.getCellColor(date))
                  .borderRadius(8)
                Text(date.slice(5))
                  .fontSize(9)
                  .fontColor('#868E96')
              }
            }, (date: string) => date)
          }
        }, (week: string[], index?: number) => `${index}`)
      }
      Row({ space: 8 }) {
        Text('少')
          .fontSize(10)
          .fontColor('#868E96')
        ForEach(['#EDF2F7', '#FFD8D8', '#FFA8A8', '#FF8787', '#FF6B6B'], (color: string) => {
          Blank().width(14).height(14).backgroundColor(color).borderRadius(4)
        }, (color: string) => color)
        Text('多')
          .fontSize(10)
          .fontColor('#868E96')
      }
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .width('100%')
  }
}
