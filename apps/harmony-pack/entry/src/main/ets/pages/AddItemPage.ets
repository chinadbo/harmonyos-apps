import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'
import ItemDao from '../database/ItemDao'
import WidgetService from '../service/WidgetService'
import { Item } from '../model/Item'
import { CATEGORY_OPTIONS } from '../model/Constants'

@Component
export struct AddItemPage {
  @Consume('navPathStack') navPathStack: NavPathStack
  @Prop routeParams: Record<string, string | number> = {}
  @State itemId: number = 0
  @State tripId: number = 0
  @State name: string = ''
  @State note: string = ''
  @State category: string = 'other'
  @State quantityText: string = '1'
  @State importance: number = 1
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  async aboutToAppear(): Promise<void> {
    this.itemId = Number(this.routeParams.itemId || 0)
    this.tripId = Number(this.routeParams.tripId || 0)
    if (this.itemId > 0) {
      const item = await ItemDao.findById(this.context, this.itemId)
      if (item) {
        this.name = item.name
        this.note = item.note
        this.category = item.category
        this.quantityText = `${item.quantity}`
        this.importance = item.importance || 1
        this.tripId = item.tripId
      }
    }
  }

  private async saveItem(): Promise<void> {
    if (this.name.trim().length === 0) {
      promptAction.showToast({ message: '请填写物品名称' })
      return
    }
    const item = new Item({
      id: this.itemId,
      tripId: this.tripId,
      name: this.name.trim(),
      note: this.note.trim(),
      category: this.category,
      quantity: Math.max(1, Number(this.quantityText || '1')),
      importance: this.importance,
      sortOrder: this.itemId,
      createdAt: Date.now(),
      updatedAt: Date.now()
    })
    await ItemDao.save(this.context, item)
    const formIds = (AppStorage.Get('formIds') as number[]) || []
    await WidgetService.refreshForms(this.context, formIds)
    promptAction.showToast({ message: '物品已保存' })
    this.navPathStack.pop()
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text(this.itemId > 0 ? '编辑物品' : '添加物品')
          .width('100%')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A')

        Column({ space: 12 }) {
          TextInput({ text: this.name, placeholder: '物品名称' })
            .onChange((value: string) => {
              this.name = value
            })
          TextInput({ text: this.quantityText, placeholder: '数量' })
            .type(InputType.Number)
            .onChange((value: string) => {
              this.quantityText = value
            })
          TextInput({ text: this.note, placeholder: '备注' })
            .onChange((value: string) => {
              this.note = value
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 12 }) {
          Text('分类选择')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .width('100%')
          Row({ space: 8 }) {
            ForEach(CATEGORY_OPTIONS, (option: { value: string; label: string }) => {
              Button(option.label)
                .type(ButtonType.Capsule)
                .backgroundColor(this.category === option.value ? '#2563EB' : '#F1F5F9')
                .fontColor(this.category === option.value ? '#FFFFFF' : '#334155')
                .onClick(() => {
                  this.category = option.value
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

        Column({ space: 12 }) {
          Text('重要程度')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .width('100%')
          Slider({ value: this.importance, min: 1, max: 5, step: 1, style: SliderStyle.OutSet })
            .onChange((value: number) => {
              this.importance = Math.round(value)
            })
          Text(`当前：${this.importance} 星`)
            .fontSize(14)
            .fontColor('#64748B')
            .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Button('保存物品')
          .width('100%')
          .height(48)
          .backgroundColor('#2563EB')
          .borderRadius(24)
          .onClick(async () => {
            await this.saveItem()
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
