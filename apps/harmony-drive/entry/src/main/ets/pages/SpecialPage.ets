/**
 * 专项练习：按 tag 分类（罚款/记分/标志/事故/综合）
 */
import router from '@ohos.router'
import { TAGS } from '../data/Question'
import { QuestionBank } from '../data/QuestionBank'

@Component
struct SpecialCard {
  @Prop icon: string = ''
  @Prop label: string = ''
  @Prop count: number = 0
  @Prop color: string = '#1C64F2'
  onTap: () => void = () => {}

  build() {
    Row() {
      Text(this.icon)
        .fontSize(24)
        .width(48)
        .height(48)
        .textAlign(TextAlign.Center)
        .borderRadius(14)
        .backgroundColor(this.color + '1A')
      Column() {
        Text(this.label)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2937')
        Text(`${this.count} 题`)
          .fontSize(12)
          .fontColor('#6B7280')
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })
      Blank()
      Text('›')
        .fontSize(22)
        .fontColor('#C4C9D2')
    }
    .width('100%')
    .padding(16)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .margin({ bottom: 12 })
    .onClick(() => this.onTap())
  }
}

@Entry
@Component
struct SpecialPage {
  @StorageLink('currentSubject') currentSubject: number = 1
  @State counts: Map<string, number> = new Map()

  aboutToAppear(): void {
    this.reload()
  }

  onPageShow(): void {
    this.reload()
  }

  reload(): void {
    const m = new Map<string, number>()
    TAGS.forEach(t => {
      m.set(t.key, QuestionBank.filterByTag(this.currentSubject, t.key).length)
    })
    this.counts = m
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#1F2937')
          .padding({ left: 4, right: 4 })
          .onClick(() => router.back())
        Text(`专项练习 · ${this.currentSubject === 1 ? '科目一' : '科目四'}`)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .margin({ left: 6 })
      }
      .width('100%')
      .padding({ left: 14, right: 16, top: 10, bottom: 12 })

      Scroll() {
        Column() {
          Text('按考点专项突破，薄弱项重点攻克')
            .fontSize(12)
            .fontColor('#9CA3AF')
            .width('100%')
            .margin({ bottom: 12 })

          ForEach(TAGS, (tag) => {
            SpecialCard({
              icon: tag.icon,
              label: tag.label,
              count: this.counts.get(tag.key) ?? 0,
              color: tag.key === 'fine' ? '#F59E0B' : tag.key === 'deduction' ? '#8B5CF6' :
                tag.key === 'sign' ? '#1C64F2' : tag.key === 'accident' ? '#DC2626' : '#16A34A',
              onTap: () => {
                router.pushUrl({
                  url: 'pages/PracticePage',
                  params: { subject: this.currentSubject, tag: tag.key } as Record<string, Object>
                })
              }
            })
          }, (tag) => tag.key)
        }
        .padding({ left: 14, right: 14, top: 2, bottom: 20 })
        .constraintSize({ minWidth: '100%' })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
