import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'
import ItemDao from '../database/ItemDao'
import TripDao from '../database/TripDao'
import ReminderService from '../service/ReminderService'
import WidgetService from '../service/WidgetService'
import { Trip } from '../model/Trip'
import { CategoryItemGroup } from '../model/Item'
import { getTripTypeLabel } from '../model/Constants'
import ProgressRing from '../components/ProgressRing'
import CategoryGroup from '../components/CategoryGroup'

@Component
export struct TripDetailPage {
  @Consume('navPathStack') navPathStack: NavPathStack
  @Prop routeParams: Record<string, string | number> = {}
  @State trip: Trip = new Trip()
  @State groups: CategoryItemGroup[] = []
  @State progress: number = 0
  @State totalItems: number = 0
  @State packedItems: number = 0
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear(): void {
    this.loadData()
  }

  private getTripId(): number {
    return Number(this.routeParams.tripId || 0)
  }

  private async loadData(): Promise<void> {
    const tripId = this.getTripId()
    const trip = await TripDao.findById(this.context, tripId)
    if (trip) {
      this.trip = trip
    }
    this.groups = await ItemDao.listGroupedByCategory(this.context, tripId)
    const progressInfo = await ItemDao.getTripProgress(this.context, tripId)
    this.totalItems = progressInfo.total
    this.packedItems = progressInfo.packed
    this.progress = progressInfo.progress
  }

  private formatDate(): string {
    const start = new Date(this.trip.startDate)
    const end = new Date(this.trip.endDate)
    return `${start.getFullYear()}/${start.getMonth() + 1}/${start.getDate()} - ${end.getMonth() + 1}/${end.getDate()}`
  }

  private async syncWidget(): Promise<void> {
    const formIds = (AppStorage.Get('formIds') as number[]) || []
    await WidgetService.refreshForms(this.context, formIds)
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 6 }) {
          Text(this.trip.title || '行程详情')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
          Text(this.trip.destination)
            .fontSize(16)
            .fontColor('#475569')
          Text(`${this.formatDate()} · ${getTripTypeLabel(this.trip.tripType)}`)
            .fontSize(13)
            .fontColor('#64748B')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Row({ space: 16 }) {
          ProgressRing({ progress: this.progress, title: '打包完成率' })

          Column({ space: 12 }) {
            Text(`已完成 ${this.packedItems}/${this.totalItems}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')
            Button('添加物品')
              .width('100%')
              .height(40)
              .backgroundColor('#2563EB')
              .borderRadius(20)
              .onClick(() => {
                this.navPathStack.pushPath({ name: 'add_item', param: { tripId: this.getTripId() } })
              })
            Button('编辑行程')
              .width('100%')
              .height(40)
              .backgroundColor('#E2E8F0')
              .fontColor('#0F172A')
              .borderRadius(20)
              .onClick(() => {
                this.navPathStack.pushPath({ name: 'add_trip', param: { tripId: this.getTripId() } })
              })
            Button('同步提醒')
              .width('100%')
              .height(40)
              .backgroundColor('#EFF6FF')
              .fontColor('#2563EB')
              .borderRadius(20)
              .onClick(async () => {
                await ReminderService.syncTripReminders(this.context, this.trip)
                promptAction.showToast({ message: '已创建出发前 24h 和 2h 提醒' })
              })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 12 }) {
          Row() {
            Text('打包清单')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')
            Blank()
            Button('应用模板')
              .height(34)
              .backgroundColor('#F8FAFC')
              .fontColor('#2563EB')
              .borderRadius(18)
              .onClick(() => {
                this.navPathStack.pushPath({ name: 'template_list', param: { tripId: this.getTripId() } })
              })
          }
          .width('100%')

          if (this.groups.length === 0) {
            Text('还没有物品，先添加或从模板导入。')
              .width('100%')
              .padding(20)
              .fontSize(14)
              .fontColor('#94A3B8')
              .backgroundColor('#FFFFFF')
              .borderRadius(18)
          } else {
            ForEach(this.groups, (group: CategoryItemGroup) => {
              CategoryGroup({
                group: group,
                onToggleItem: async (itemId: number, isPacked: boolean) => {
                  await ItemDao.togglePacked(this.context, itemId, isPacked)
                  await this.loadData()
                  await this.syncWidget()
                },
                onEditItem: (itemId: number) => {
                  this.navPathStack.pushPath({ name: 'add_item', param: { tripId: this.getTripId(), itemId: itemId } })
                }
              })
            }, (group: CategoryItemGroup) => group.category)
          }
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .padding({ bottom: 28 })
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#F8FAFC')
  }
}
