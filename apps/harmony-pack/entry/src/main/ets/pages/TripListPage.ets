import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'
import TripDao from '../database/TripDao'
import { TripSummary, Trip } from '../model/Trip'
import { TripStatus } from '../model/Constants'
import TripCard from '../components/TripCard'

@Component
export struct TripListPage {
  @Consume('navPathStack') navPathStack: NavPathStack
  @State upcomingTrips: TripSummary[] = []
  @State activeTrips: TripSummary[] = []
  @State completedTrips: TripSummary[] = []
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear(): void {
    this.loadTrips()
  }

  private async loadTrips(): Promise<void> {
    this.upcomingTrips = await TripDao.queryByStatus(this.context, TripStatus.UPCOMING)
    this.activeTrips = await TripDao.queryByStatus(this.context, TripStatus.ACTIVE)
    this.completedTrips = await TripDao.queryByStatus(this.context, TripStatus.COMPLETED)
  }

  @Builder
  private buildSection(title: string, list: TripSummary[]) {
    Column({ space: 12 }) {
      Row() {
        Text(title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')
        Blank()
        Text(`${list.length}`)
          .fontSize(14)
          .fontColor('#64748B')
      }
      .width('100%')

      if (list.length === 0) {
        Text('暂无数据')
          .width('100%')
          .padding(16)
          .fontSize(14)
          .fontColor('#94A3B8')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
      } else {
        ForEach(list, (summary: TripSummary) => {
          TripCard({
            summary: summary,
            onClick: (tripId: number) => {
              this.navPathStack.pushPath({ name: 'trip_detail', param: { tripId: tripId } })
            }
          })
        }, (summary: TripSummary) => `${summary.trip.id}`)
      }
    }
    .width('100%')
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 4 }) {
          Text('我的行程')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
          Text('管理你的旅行计划与打包状态')
            .fontSize(14)
            .fontColor('#64748B')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button('+ 新建')
          .height(40)
          .backgroundColor('#2563EB')
          .borderRadius(20)
          .onClick(() => {
            this.navPathStack.pushPath({ name: 'add_trip', param: {} })
          })
      }
      .width('100%')

      Scroll() {
        Column({ space: 16 }) {
          this.buildSection('待出发', this.upcomingTrips)
          this.buildSection('进行中', this.activeTrips)
          this.buildSection('已完成', this.completedTrips)
        }
        .width('100%')
        .padding({ bottom: 24 })
      }
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F8FAFC')
  }
}
