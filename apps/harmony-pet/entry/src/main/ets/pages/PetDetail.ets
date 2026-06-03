import router from '@ohos.router'
import common from '@ohos.app.ability.common'
import { PetDao } from '../database/PetDao'
import { WeightDao } from '../database/WeightDao'
import { FeedDao } from '../database/FeedDao'
import { HealthDao } from '../database/HealthDao'
import { PhotoDao } from '../database/PhotoDao'
import type { Pet } from '../model/Pet'
import type { WeightRecord } from '../model/WeightRecord'
import type { FeedLog } from '../model/FeedLog'
import type { HealthEvent } from '../model/HealthEvent'
import type { PetPhoto } from '../model/PetPhoto'
import { DateUtils } from '../common/DateUtils'

@Entry
@Component
export struct PetDetail {
  @StorageLink('dataVersion') dataVersion: number = 0
  @State petId: number = 0
  @State pet: Pet | null = null
  @State weights: WeightRecord[] = []
  @State feeds: FeedLog[] = []
  @State healthEvents: HealthEvent[] = []
  @State photos: PetPhoto[] = []
  @State tabIndex: number = 0

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number>
    this.petId = Number(params?.petId ?? AppStorage.get<number>('activePetId') ?? 0)
    AppStorage.setOrCreate('activePetId', this.petId)
    this.loadData()
  }

  private getAbilityContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext
  }

  private async loadData(): Promise<void> {
    if (this.petId <= 0) {
      return
    }
    const context = this.getAbilityContext()
    const petDao: PetDao = new PetDao(context)
    const weightDao: WeightDao = new WeightDao(context)
    const feedDao: FeedDao = new FeedDao(context)
    const healthDao: HealthDao = new HealthDao(context)
    const photoDao: PhotoDao = new PhotoDao(context)
    this.pet = await petDao.queryById(this.petId)
    this.weights = await weightDao.queryByPetId(this.petId)
    this.feeds = await feedDao.queryByPetId(this.petId)
    this.healthEvents = await healthDao.queryByPetId(this.petId)
    this.photos = await photoDao.queryByPetId(this.petId)
    AppStorage.setOrCreate('activePetName', this.pet?.name ?? '我的宠物')
    AppStorage.setOrCreate('todayFeedCount', await feedDao.queryTodayCount(this.petId))
  }

  private goBack(): void {
    const stack = AppStorage.get<NavPathStack>('navPathStack') as unknown as Record<string, Function>
    if (stack && typeof stack.pop === 'function') {
      stack.pop()
    }
    router.back()
  }

  private openPage(name: string): void {
    const params = { petId: this.petId }
    const stack = AppStorage.get<NavPathStack>('navPathStack') as unknown as Record<string, Function>
    if (stack && typeof stack.pushPathByName === 'function') {
      stack.pushPathByName(name, params)
    }
    router.pushUrl({ url: `pages/${name}`, params })
  }

  @Builder buildOverviewCard(title: string, value: string, extra: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontColor('#777777')
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
      Text(extra)
        .fontSize(12)
        .fontColor('#999999')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .borderRadius(18)
    .backgroundColor('#FFFFFF')
  }

  @Builder buildShortcut(title: string, subtitle: string, pageName: string) {
    Row() {
      Column({ space: 6 }) {
        Text(title)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
        Text(subtitle)
          .fontSize(12)
          .fontColor('#888888')
      }
      .layoutWeight(1)
      Text('进入')
        .fontSize(12)
        .fontColor('#FF8A00')
    }
    .padding(16)
    .borderRadius(18)
    .backgroundColor('#FFFFFF')
    .onClick(() => this.openPage(pageName))
  }

  build() {
    const latestWeight = DateUtils.recentWeight([...this.weights])
    const nextHealth = DateUtils.nextHealthEvent([...this.healthEvents])
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('返回')
            .type(ButtonType.Capsule)
            .backgroundColor('#FFFFFF')
            .fontColor('#666666')
            .onClick(() => this.goBack())
          Blank()
          Button('编辑')
            .type(ButtonType.Capsule)
            .onClick(() => {
              const stack = AppStorage.get<NavPathStack>('navPathStack') as unknown as Record<string, Function>
              if (stack && typeof stack.pushPathByName === 'function') {
                stack.pushPathByName('EditPet', { petId: this.petId })
              }
              router.pushUrl({ url: 'pages/EditPet', params: { petId: this.petId } })
            })
        }

        Column({ space: 12 }) {
          if (this.pet?.avatarUri) {
            Image(this.pet.avatarUri)
              .width(90)
              .height(90)
              .borderRadius(45)
              .objectFit(ImageFit.Cover)
          } else {
            Stack() {
              Text('爪')
                .fontSize(34)
                .fontColor('#FF8A00')
            }
            .width(90)
            .height(90)
            .borderRadius(45)
            .backgroundColor('#FFF6E9')
          }
          Text(this.pet?.name ?? '未命名')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
          Text(`${this.pet?.species ?? ''} · ${this.pet?.breed ?? '未填写品种'}`)
            .fontSize(14)
            .fontColor('#666666')
          Text(DateUtils.calculateAge(this.pet?.birthDate ?? ''))
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .padding(20)
        .borderRadius(24)
        .backgroundColor('#FFFFFF')

        Tabs({ index: this.tabIndex }) {
          TabContent() {
            Column({ space: 12 }) {
              this.buildOverviewCard('最近体重', latestWeight ? `${latestWeight.weight.toFixed(1)} kg` : '--', latestWeight ? latestWeight.recordDate : '暂无体重记录')
              this.buildOverviewCard('今日喂食', `${this.feeds.filter((item: FeedLog) => DateUtils.isToday(item.feedTime)).length} 次`, '包含主粮与零食')
              this.buildOverviewCard('下次提醒', nextHealth?.title ?? '暂无提醒', nextHealth?.nextDate ? `${DateUtils.formatDisplayDate(nextHealth.nextDate)} 到期` : '未来 30 天内无提醒')
            }
            .width('100%')
          }
          .tabBar('概览')

          TabContent() {
            Column({ space: 12 }) {
              this.buildShortcut('体重记录', this.weights.length > 0 ? `已记录 ${this.weights.length} 条` : '还没有体重记录', 'WeightLog')
            }
          }
          .tabBar('体重')

          TabContent() {
            Column({ space: 12 }) {
              this.buildShortcut('喂食日志', this.feeds.length > 0 ? `已记录 ${this.feeds.length} 条` : '还没有喂食记录', 'FeedLog')
            }
          }
          .tabBar('喂食')

          TabContent() {
            Column({ space: 12 }) {
              this.buildShortcut('健康事件', this.healthEvents.length > 0 ? `已记录 ${this.healthEvents.length} 条` : '还没有健康事件', 'HealthEvent')
            }
          }
          .tabBar('健康')

          TabContent() {
            Column({ space: 12 }) {
              this.buildShortcut('照片墙', this.photos.length > 0 ? `已上传 ${this.photos.length} 张` : '还没有照片', 'PhotoWall')
            }
          }
          .tabBar('相册')
        }
        .width('100%')
        .height(420)
      }
      .padding(16)
      .backgroundColor('#F6F7FB')
      .width('100%')
    }
  }
}
