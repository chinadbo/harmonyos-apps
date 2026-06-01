import { TripSummary } from '../model/Trip'
import { getTripStatusLabel, getTripTypeLabel } from '../model/Constants'

@Component
export struct TripCard {
  @Prop summary: TripSummary = {
    trip: {
      id: 0,
      title: '',
      destination: '',
      startDate: Date.now(),
      endDate: Date.now(),
      tripType: 'leisure',
      status: 'upcoming',
      note: '',
      reminder24Id: 0,
      reminder2Id: 0,
      createdAt: Date.now(),
      updatedAt: Date.now(),
      getDurationDays: (): number => 1
    },
    totalItems: 0,
    packedItems: 0,
    progress: 0
  }
  @Prop onClick: (tripId: number) => void = () => {
  }

  private formatDateRange(): string {
    const start = new Date(this.summary.trip.startDate)
    const end = new Date(this.summary.trip.endDate)
    const startText = `${start.getMonth() + 1}/${start.getDate()}`
    const endText = `${end.getMonth() + 1}/${end.getDate()}`
    return `${startText} - ${endText}`
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.summary.trip.title || this.summary.trip.destination)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
          Text(this.summary.trip.destination)
            .fontSize(14)
            .fontColor('#6B7280')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 6 }) {
          Text(getTripStatusLabel(this.summary.trip.status))
            .fontSize(12)
            .fontColor('#2563EB')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('#DBEAFE')
            .borderRadius(12)
          Text(`${this.summary.progress}%`)
            .fontSize(22)
            .fontWeight(FontWeight.Bolder)
            .fontColor('#0F172A')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row({ space: 10 }) {
        Text(this.formatDateRange())
          .fontSize(13)
          .fontColor('#475569')
        Text(getTripTypeLabel(this.summary.trip.tripType))
          .fontSize(13)
          .fontColor('#475569')
      }
      .width('100%')

      Column({ space: 8 }) {
        Row() {
          Text('打包进度')
            .fontSize(13)
            .fontColor('#64748B')
          Blank()
          Text(`${this.summary.packedItems}/${this.summary.totalItems}`)
            .fontSize(13)
            .fontColor('#64748B')
        }
        .width('100%')

        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width('100%')
            .height(8)
            .backgroundColor('#E5E7EB')
            .borderRadius(8)

          Row()
            .width(`${Math.max(4, this.summary.progress)}%`)
            .height(8)
            .backgroundColor('#3B82F6')
            .borderRadius(8)
        }
        .width('100%')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({ radius: 12, color: '#12000000', offsetX: 0, offsetY: 6 })
    .onClick(() => {
      this.onClick(this.summary.trip.id)
    })
  }
}
