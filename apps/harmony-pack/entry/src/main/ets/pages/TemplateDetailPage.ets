import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'
import TemplateDao from '../database/TemplateDao'
import WidgetService from '../service/WidgetService'
import { Template, TemplateItem } from '../model/Template'
import { getCategoryLabel, getTripTypeLabel } from '../model/Constants'

@Component
export struct TemplateDetailPage {
  @Consume('navPathStack') navPathStack: NavPathStack
  @Prop routeParams: Record<string, string | number> = {}
  @State template: Template = new Template()
  @State targetTripIdText: string = ''
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  async aboutToAppear(): Promise<void> {
    const templateId = String(this.routeParams.templateId || '')
    const tripId = Number(this.routeParams.tripId || 0)
    if (tripId > 0) {
      this.targetTripIdText = `${tripId}`
    }
    const template = await TemplateDao.findById(this.context, templateId)
    if (template) {
      this.template = template
    }
  }

  private async applyTemplate(): Promise<void> {
    const tripId = Number(this.targetTripIdText || '0')
    if (tripId <= 0) {
      promptAction.showToast({ message: '请输入要应用的行程 ID' })
      return
    }
    await TemplateDao.applyTemplateToTrip(this.context, this.template.id, tripId)
    const formIds = (AppStorage.Get('formIds') as number[]) || []
    await WidgetService.refreshForms(this.context, formIds)
    promptAction.showToast({ message: '模板已应用到行程' })
    this.navPathStack.pop()
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 6 }) {
          Text(this.template.name || '模板详情')
            .width('100%')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
          Text(getTripTypeLabel(this.template.tripType))
            .fontSize(14)
            .fontColor('#64748B')
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)

        Column({ space: 12 }) {
          TextInput({ text: this.targetTripIdText, placeholder: '输入目标行程 ID' })
            .type(InputType.Number)
            .onChange((value: string) => {
              this.targetTripIdText = value
            })
          Button('一键应用到行程')
            .width('100%')
            .height(46)
            .backgroundColor('#2563EB')
            .borderRadius(24)
            .onClick(async () => {
              await this.applyTemplate()
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 12 }) {
          Text('模板物品')
            .width('100%')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
          ForEach(this.template.items, (item: TemplateItem) => {
            Column({ space: 4 }) {
              Row() {
                Text(item.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#0F172A')
                Blank()
                Text(`x${item.quantity}`)
                  .fontSize(12)
                  .fontColor('#2563EB')
              }
              .width('100%')
              Text(getCategoryLabel(item.category))
                .fontSize(12)
                .fontColor('#64748B')
                .width('100%')
              if (item.note.length > 0) {
                Text(item.note)
                  .fontSize(12)
                  .fontColor('#94A3B8')
                  .width('100%')
              }
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
          }, (item: TemplateItem, index?: number) => `${item.name}-${index}`)
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
