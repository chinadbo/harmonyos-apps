import router from '@ohos.router'
import common from '@ohos.app.ability.common'
import { HealthDao } from '../database/HealthDao'
import { ReminderService } from '../service/ReminderService'
import type { HealthEvent as HealthEventModel } from '../model/HealthEvent'
import { HealthItem } from '../components/HealthItem'
import { DateUtils } from '../common/DateUtils'

@Entry
@Component
export struct HealthEvent {
  @StorageLink('dataVersion') dataVersion: number = 0
  @State petId: number = 0
  @State items: HealthEventModel[] = []
  @State dialogVisible: boolean = false
  @State editingId: number = 0
  @State eventType: string = '疫苗'
  @State title: string = ''
  @State eventDate: string = DateUtils.today()
  @State nextDate: string = ''
  @State hospital: string = ''
  @State note: string = ''
  private eventTypes: string[] = ['疫苗', '就医', '驱虫', '洗澡', '美容']

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
    const dao: HealthDao = new HealthDao(this.getAbilityContext())
    this.items = await dao.queryByPetId(this.petId)
  }

  private goBack(): void {
    const stack = AppStorage.get<NavPathStack>('navPathStack') as unknown as Record<string, Function>
    if (stack && typeof stack.pop === 'function') {
      stack.pop()
    }
    router.back()
  }

  private resetForm(): void {
    this.editingId = 0
    this.eventType = '疫苗'
    this.title = ''
    this.eventDate = DateUtils.today()
    this.nextDate = ''
    this.hospital = ''
    this.note = ''
  }

  private editItem(item: HealthEventModel): void {
    this.editingId = item.id
    this.eventType = item.eventType
    this.title = item.title
    this.eventDate = item.eventDate
    this.nextDate = item.nextDate
    this.hospital = item.hospital
    this.note = item.note
    this.dialogVisible = true
  }

  private async saveItem(): Promise<void> {
    if (!this.title.trim()) {
      return
    }
    const dao: HealthDao = new HealthDao(this.getAbilityContext())
    let reminderId: number = 0
    if (this.eventType === '疫苗' && this.nextDate) {
      reminderId = await new ReminderService().publishVaccineReminder(this.nextDate, this.title)
    }
    if (this.editingId > 0) {
      const oldItem = this.items.find((item: HealthEventModel) => item.id === this.editingId)
      if (oldItem?.reminderId) {
        await new ReminderService().cancelReminder(oldItem.reminderId)
      }
      await dao.update({
        id: this.editingId,
        petId: this.petId,
        eventType: this.eventType,
        title: this.title,
        eventDate: this.eventDate,
        nextDate: this.nextDate,
        hospital: this.hospital,
        note: this.note,
        reminderId,
        createdAt: DateUtils.nowTimestamp()
      })
    } else {
      await dao.insert({
        petId: this.petId,
        eventType: this.eventType,
        title: this.title,
        eventDate: this.eventDate,
        nextDate: this.nextDate,
        hospital: this.hospital,
        note: this.note,
        reminderId,
        createdAt: DateUtils.nowTimestamp()
      })
    }
    this.dialogVisible = false
    this.resetForm()
    AppStorage.setOrCreate('dataVersion', (AppStorage.get<number>('dataVersion') ?? 0) + 1)
    await this.loadItems()
  }

  private async deleteItem(id: number): Promise<void> {
    const dao: HealthDao = new HealthDao(this.getAbilityContext())
    const item = this.items.find((entry: HealthEventModel) => entry.id === id)
    if (item?.reminderId) {
      await new ReminderService().cancelReminder(item.reminderId)
    }
    await dao.delete(id)
    AppStorage.setOrCreate('dataVersion', (AppStorage.get<number>('dataVersion') ?? 0) + 1)
    await this.loadItems()
  }

  @Builder eventDialog() {
    Column({ space: 12 }) {
      Text(this.editingId > 0 ? '编辑健康事件' : '添加健康事件')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      Row({ space: 8 }) {
        ForEach(this.eventTypes, (item: string) => {
          Button(item)
            .type(ButtonType.Capsule)
            .backgroundColor(item === this.eventType ? '#FF8A00' : '#FFFFFF')
            .fontColor(item === this.eventType ? '#FFFFFF' : '#666666')
            .onClick(() => this.eventType = item)
        }, (item: string) => item)
      }
      TextInput({ placeholder: '标题', text: this.title })
        .onChange((value: string) => this.title = value)
      TextInput({ placeholder: '地点/医院', text: this.hospital })
        .onChange((value: string) => this.hospital = value)
      TextInput({ placeholder: '备注', text: this.note })
        .onChange((value: string) => this.note = value)
      DatePicker({ start: new Date('2010-01-01'), end: new Date('2100-12-31'), selected: new Date(`${this.eventDate}T00:00:00`) })
        .onChange((value: Date) => this.eventDate = DateUtils.toDateOnly(value))
      DatePicker({ start: new Date('2010-01-01'), end: new Date('2100-12-31'), selected: this.nextDate ? new Date(`${this.nextDate}T00:00:00`) : new Date() })
        .onChange((value: Date) => this.nextDate = DateUtils.toDateOnly(value))
      Row({ space: 10 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#F3F3F3')
          .fontColor('#666666')
          .onClick(() => {
            this.dialogVisible = false
            this.resetForm()
          })
        Button('保存')
          .layoutWeight(1)
          .onClick(() => this.saveItem())
      }
    }
    .padding(20)
  }

  build() {
    const grouped: Record<string, HealthEventModel[]> = {}
    this.eventTypes.forEach((type: string) => {
      grouped[type] = this.items.filter((item: HealthEventModel) => item.eventType === type)
    })
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('返回')
            .type(ButtonType.Capsule)
            .backgroundColor('#FFFFFF')
            .fontColor('#666666')
            .onClick(() => this.goBack())
          Blank()
          Text('健康事件')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
          Blank()
          Button('添加')
            .type(ButtonType.Capsule)
            .onClick(() => {
              this.resetForm()
              this.dialogVisible = true
            })
        }

        ForEach(this.eventTypes, (type: string) => {
          if ((grouped[type] ?? []).length > 0) {
            Column({ space: 12 }) {
              Text(type)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .width('100%')
              ForEach(grouped[type], (item: HealthEventModel) => {
                HealthItem({
                  item,
                  highlight: DateUtils.isWithinDays(item.nextDate, 30),
                  onEdit: (target: HealthEventModel) => this.editItem(target),
                  onDelete: (id: number) => this.deleteItem(id)
                })
              }, (item: HealthEventModel) => `${item.id}`)
            }
            .alignItems(HorizontalAlign.Start)
          }
        }, (type: string) => type)
      }
      .padding(16)
      .backgroundColor('#F6F7FB')
    }
    .bindContentCover($$this.dialogVisible, this.eventDialog(), { modalTransition: ModalTransition.DEFAULT })
  }
}
