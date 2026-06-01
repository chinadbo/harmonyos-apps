import common from '@ohos.app.ability.common'
import TemplateDao from '../database/TemplateDao'
import { Template } from '../model/Template'
import { getTripTypeLabel } from '../model/Constants'

@Component
export struct TemplatePage {
  @Consume('navPathStack') navPathStack: NavPathStack
  @State currentTab: number = 0
  @State builtinTemplates: Template[] = []
  @State customTemplates: Template[] = []
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  async aboutToAppear(): Promise<void> {
    await this.loadTemplates()
  }

  private async loadTemplates(): Promise<void> {
    this.builtinTemplates = await TemplateDao.listBuiltinTemplates(this.context)
    this.customTemplates = await TemplateDao.listCustomTemplates(this.context)
  }

  @Builder
  private buildTemplateList(list: Template[]) {
    if (list.length === 0) {
      Text('暂无模板')
        .width('100%')
        .padding(20)
        .fontSize(14)
        .fontColor('#94A3B8')
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
    } else {
      Column({ space: 12 }) {
        ForEach(list, (template: Template) => {
          Column({ space: 8 }) {
            Row() {
              Column({ space: 4 }) {
                Text(template.name)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#0F172A')
                Text(getTripTypeLabel(template.tripType))
                  .fontSize(13)
                  .fontColor('#64748B')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text(`${template.items.length} 项`)
                .fontSize(12)
                .fontColor('#2563EB')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor('#EFF6FF')
                .borderRadius(12)
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .onClick(() => {
            this.navPathStack.pushPath({ name: 'template_detail', param: { templateId: template.id } })
          })
        }, (template: Template) => template.id)
      }
      .width('100%')
    }
  }

  build() {
    Column({ space: 16 }) {
      Text('场景模板')
        .width('100%')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0F172A')

      Tabs({ barPosition: BarPosition.Start, index: this.currentTab }) {
        TabContent() {
          Scroll() {
            Column() {
              this.buildTemplateList(this.builtinTemplates)
            }
            .width('100%')
            .padding({ top: 12, bottom: 24 })
          }
          .scrollBar(BarState.Off)
        }
        .tabBar('内置模板')

        TabContent() {
          Scroll() {
            Column() {
              this.buildTemplateList(this.customTemplates)
            }
            .width('100%')
            .padding({ top: 12, bottom: 24 })
          }
          .scrollBar(BarState.Off)
        }
        .tabBar('自定义模板')
      }
      .onChange((index: number) => {
        this.currentTab = index
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F8FAFC')
  }
}
