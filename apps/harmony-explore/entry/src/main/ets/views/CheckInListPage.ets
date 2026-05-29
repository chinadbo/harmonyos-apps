import { CheckInDetailModel } from '../model/CheckInModel'
import { CheckInCard } from '../components/CheckInCard'
import { DatabaseService } from '../service/DatabaseService'
import { DateUtils } from '../utils/DateUtils'
import { RouteNames } from '../utils/Constants'

interface CheckInGroup {
  date: string
  items: CheckInDetailModel[]
}

@Component
export struct CheckInListPage {
  @Prop pathStack: NavPathStack
  @Watch('onRefreshChanged') @StorageLink('refreshToken') refreshToken: number = 0
  @State private groups: CheckInGroup[] = []
  private readonly databaseService: DatabaseService = DatabaseService.getInstance()

  aboutToAppear(): void {
    this.loadCheckIns()
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Text($r('app.string.title_checkin_list'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text($r('app.string.subtitle_checkin_list'))
          .fontSize(13)
          .fontColor('#666666')
      }
      .width('100%')

      if (this.groups.length === 0) {
        Column() {
          Text($r('app.string.empty_checkin'))
            .fontSize(14)
            .fontColor('#8A8A8A')
        }
        .width('100%')
        .padding(24)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
      } else {
        List({ space: 16 }) {
          ForEach(this.groups, (group: CheckInGroup) => {
            ListItem() {
              Column({ space: 10 }) {
                Text(group.date)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                ForEach(group.items, (item: CheckInDetailModel) => {
                  Column() {
                    CheckInCard({ item })
                  }
                  .onClick(() => {
                    AppStorage.SetOrCreate('selectedCheckInId', item.id)
                    this.pathStack.pushPathByName(RouteNames.CHECKIN_DETAIL, null)
                  })
                }, (item: CheckInDetailModel) => `${item.id}`)
              }
              .alignItems(HorizontalAlign.Start)
            }
          }, (group: CheckInGroup) => group.date)
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  private onRefreshChanged(): void {
    this.loadCheckIns()
  }

  private async loadCheckIns(): Promise<void> {
    const list: CheckInDetailModel[] = await this.databaseService.getCheckInList()
    const grouped: Map<string, CheckInDetailModel[]> = new Map<string, CheckInDetailModel[]>()
    list.forEach((item: CheckInDetailModel) => {
      const key: string = DateUtils.formatDate(item.checkInAt)
      const items: CheckInDetailModel[] = grouped.get(key) ?? []
      items.push(item)
      grouped.set(key, items)
    })
    const groups: CheckInGroup[] = []
    grouped.forEach((items: CheckInDetailModel[], date: string) => {
      groups.push({ date, items })
    })
    this.groups = groups
  }
}
