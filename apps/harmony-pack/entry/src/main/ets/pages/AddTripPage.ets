import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'
import TripDao from '../database/TripDao'
import ReminderService from '../service/ReminderService'
import WidgetService from '../service/WidgetService'
import { Trip } from '../model/Trip'
import { TRIP_TYPE_OPTIONS } from '../model/Constants'

@Component
export struct AddTripPage {
  @Consume('navPathStack') navPathStack: NavPathStack
  @Prop routeParams: Record<string, string | number> = {}
  @State tripId: number = 0
  @State title: string = ''
  @State destination: string = ''
  @State note: string = ''
  @State tripType: string = 'leisure'
  @State startDate: Date = new Date()
  @State endDate: Date = new Date(Date.now() + 24 * 60 * 60 * 1000)
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  async aboutToAppear(): Promise<void> {
    this.tripId = Number(this.routeParams.tripId || 0)
    if (this.tripId > 0) {
      const trip = await TripDao.findById(this.context, this.tripId)
      if (trip) {
        this.title = trip.title
        this.destination = trip.destination
        this.note = trip.note
        this.tripType = trip.tripType
        this.startDate = new Date(trip.startDate)
        this.endDate = new Date(trip.endDate)
      }
    }
  }

  private async saveTrip(): Promise<void> {
    if (this.title.trim().length === 0 || this.destination.trim().length === 0) {
      promptAction.showToast({ message: '请填写行程标题和目的地' })
      return
    }
    const trip = new Trip({
      id: this.tripId,
      title: this.title.trim(),
      destination: this.destination.trim(),
      note: this.note.trim(),
      tripType: this.tripType,
      startDate: this.startDate.getTime(),
      endDate: this.endDate.getTime(),
      createdAt: Date.now(),
      updatedAt: Date.now()
    })
    const tripId = await TripDao.save(this.context, trip)
    trip.id = tripId
    await ReminderService.syncTripReminders(this.context, trip)
    const formIds = (AppStorage.Get('formIds') as number[]) || []
    await WidgetService.refreshForms(this.context, formIds)
    promptAction.showToast({ message: '行程已保存' })
    this.navPathStack.pop()
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text(this.tripId > 0 ? '编辑行程' : '新建行程')
          .width('100%')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')

        Column({ space: 12 }) {
          TextInput({ text: this.title, placeholder: '请输入行程标题' })
            .onChange((value: string) => {
              this.title = value
            })
          TextInput({ text: this.destination, placeholder: '请输入目的地' })
            .onChange((value: string) => {
              this.destination = value
            })
          TextInput({ text: this.note, placeholder: '备注信息' })
            .onChange((value: string) => {
              this.note = value
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 12 }) {
          Text('出行类型')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .width('100%')

          Row({ space: 8 }) {
            ForEach(TRIP_TYPE_OPTIONS, (option: { value: string; label: string }) => {
              Button(option.label)
                .type(ButtonType.Capsule)
                .backgroundColor(this.tripType === option.value ? '#2563EB' : '#F1F5F9')
                .fontColor(this.tripType === option.value ? '#FFFFFF' : '#334155')
                .onClick(() => {
                  this.tripType = option.value
                })
            }, (option: { value: string; label: string }) => option.value)
          }
          .width('100%')
          .wrap(true)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 10 }) {
          Text('出发日期')
            .width('100%')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          DatePicker({ start: new Date(2020, 0, 1), end: new Date(2035, 11, 31), selected: this.startDate })
            .onDateChange((value: Date) => {
              this.startDate = value
              if (this.endDate.getTime() < value.getTime()) {
                this.endDate = value
              }
            })
          Text('返回日期')
            .width('100%')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          DatePicker({ start: this.startDate, end: new Date(2035, 11, 31), selected: this.endDate })
            .onDateChange((value: Date) => {
              this.endDate = value
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Button('保存行程')
          .width('100%')
          .height(48)
          .backgroundColor('#2563EB')
          .borderRadius(24)
          .onClick(async () => {
            await this.saveTrip()
          })
      }
      .width('100%')
      .padding(16)
      .padding({ bottom: 32 })
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#F8FAFC')
  }
}
