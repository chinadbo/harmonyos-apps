import router from '@ohos.router'
import common from '@ohos.app.ability.common'
import { FeedDao } from '../database/FeedDao'
import type { FeedLog as FeedLogModel } from '../model/FeedLog'
import { FeedItem } from '../components/FeedItem'
import { DateUtils } from '../common/DateUtils'

@Entry
@Component
export struct FeedLog {
  @StorageLink('dataVersion') dataVersion: number = 0
  @State petId: number = 0
  @State items: FeedLogModel[] = []
  @State foodType: string = '主粮'
  @State amount: string = ''
  @State unit: string = 'g'
  @State note: string = ''
  @State feedTime: string = DateUtils.toDateTimeText(new Date(), new Date().getHours(), new Date().getMinutes())
  private foodTypes: string[] = ['主粮', '罐头', '零食', '营养品']

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number>
    this.petId = Number(params?.petId ?? AppStorage.get<number>('activePetId') ?? 0)
    this.loadItems()
  }

  private getAbilityContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  private async loadItems(): Promise<void> {
    if (this.petId <= 0) {
      return
    }
    const dao: FeedDao = new FeedDao(this.getAbilityContext())
    this.items = await dao.queryByPetId(this.petId)
    AppStorage.setOrCreate('todayFeedCount', await dao.queryTodayCount(this.petId))
  }

  private goBack(): void {
    const stack = AppStorage.get<NavPathStack>('navPathStack') as unknown as Record<string, Function>
    if (stack && typeof stack.pop === 'function') {
      stack.pop()
    }
    router.back()
  }

  private async addFeedLog(): Promise<void> {
    const amountValue: number = Number(this.amount)
    if (!amountValue || this.petId <= 0) {
      return
    }
    const dao: FeedDao = new FeedDao(this.getAbilityContext())
    await dao.insert({
      petId: this.petId,
      foodType: this.foodType,
      amount: amountValue,
      unit: this.unit,
      feedTime: this.feedTime,
      note: this.note,
      createdAt: DateUtils.nowTimestamp()
    })
    this.amount = ''
    this.note = ''
    AppStorage.setOrCreate('dataVersion', (AppStorage.get<number>('dataVersion') ?? 0) + 1)
    await this.loadItems()
  }

  build() {
    const groups = DateUtils.groupFeedLogsByDate(this.items)
    const todayItems = this.items.filter((item: FeedLogModel) => DateUtils.isToday(item.feedTime))
    const todayTotal = todayItems.reduce((sum: number, item: FeedLogModel) => sum + item.amount, 0)
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('返回')
            .type(ButtonType.Capsule)
            .backgroundColor('#FFFFFF')
            .fontColor('#666666')
            .onClick(() => this.goBack())
          Blank()
          Text('喂食日志')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
          Blank()
        }

        Row({ space: 12 }) {
          Column({ space: 6 }) {
            Text('今日喂食次数')
              .fontSize(13)
              .fontColor('#777777')
            Text(`${todayItems.length} 次`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          Column({ space: 6 }) {
            Text('今日总量')
              .fontSize(13)
              .fontColor('#777777')
            Text(`${todayTotal} ${this.unit}`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
        }

        Column({ space: 12 }) {
          Text('添加喂食记录')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
          Row({ space: 8 }) {
            ForEach(this.foodTypes, (item: string) => {
              Button(item)
                .type(ButtonType.Capsule)
                .backgroundColor(item === this.foodType ? '#FF8A00' : '#FFFFFF')
                .fontColor(item === this.foodType ? '#FFFFFF' : '#666666')
                .onClick(() => this.foodType = item)
            }, (item: string) => item)
          }
          TextInput({ placeholder: '数量', text: this.amount })
            .onChange((value: string) => this.amount = value)
            .backgroundColor('#FFFFFF')
          TextInput({ placeholder: '单位，例如 g / ml', text: this.unit })
            .onChange((value: string) => this.unit = value)
            .backgroundColor('#FFFFFF')
          TextInput({ placeholder: '备注', text: this.note })
            .onChange((value: string) => this.note = value)
            .backgroundColor('#FFFFFF')
          DatePicker({ start: new Date('2010-01-01'), end: new Date(), selected: new Date() })
            .onChange((value: Date) => this.feedTime = DateUtils.toDateTimeText(value, new Date().getHours(), new Date().getMinutes()))
            .backgroundColor('#FFFFFF')
          Button('添加记录')
            .width('100%')
            .onClick(() => this.addFeedLog())
        }
        .padding(16)
        .borderRadius(20)
        .backgroundColor('#FFFFFF')

        Column({ space: 12 }) {
          ForEach(groups, (group: { date: string; items: FeedLogModel[] }) => {
            Column({ space: 10 }) {
              Text(group.date)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#666666')
                .width('100%')
              ForEach(group.items, (item: FeedLogModel) => {
                FeedItem({ item })
              }, (item: FeedLogModel) => `${item.id}`)
            }
            .alignItems(HorizontalAlign.Start)
          }, (group: { date: string; items: FeedLogModel[] }) => group.date)
        }
        .width('100%')
      }
      .padding(16)
      .backgroundColor('#F6F7FB')
    }
  }
}
