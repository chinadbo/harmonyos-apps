/**
 * 考点速记：Swiper 翻卡，正面问题反面要点
 */
import router from '@ohos.router'

interface TipCard {
  category: string
  question: string
  answer: string
  color: string
}

const TIPS: TipCard[] = [
  {
    category: '记分规则',
    question: '饮酒后驾驶机动车的，一次记多少分？',
    answer: '记 12 分，并处暂扣驾驶证 6 个月、罚款 1000–2000 元。饮酒驾驶营运机动车则 15 日拘留 + 罚款 5000 元 + 吊销驾照。',
    color: '#F59E0B'
  },
  {
    category: '记分规则',
    question: '驾驶与准驾车型不符的机动车记几分？',
    answer: '记 9 分。驾驶不相符车型视为无证驾驶性质的违法行为，扣留车辆并处罚款。',
    color: '#F59E0B'
  },
  {
    category: '记分规则',
    question: '一次记 12 分的情形有哪些？',
    answer: '酒后驾驶、造成事故后逃逸（不构成犯罪）、使用伪造/变造牌证、高速公路上倒车/逆行/掉头、替人记分牟利等。一个周期内两次满 12 分需参加学习考试。',
    color: '#F59E0B'
  },
  {
    category: '罚款处罚',
    question: '伪造、变造驾驶证会怎样处罚？',
    answer: '收缴伪造证件，扣留车辆，处 15 日以下拘留，并处 2000–5000 元罚款；构成犯罪的追究刑事责任。',
    color: '#DC2626'
  },
  {
    category: '罚款处罚',
    question: '驾驶拼装或报废机动车上路怎么罚？',
    answer: '收缴车辆强制报废，吊销驾驶证，并处 1000–2000 元罚款（驾驶报废车）或 200–2000 元罚款（拼装车，并吊销驾照）。',
    color: '#DC2626'
  },
  {
    category: '信号标志',
    question: '黄色虚线与白色虚线在道路中央的区别？',
    answer: '黄色虚线分隔对向车道，可在安全时越线超车或转弯；白色虚线分隔同向车道，用于指示车道界线。',
    color: '#1C64F2'
  },
  {
    category: '信号标志',
    question: '红色圆圈图标代表什么类别的交通标志？',
    answer: '红色圆圈（禁止标志）表示禁止或限制车辆、行人通行的行为，如禁止驶入、禁止停车、禁止掉头等，遇到此类标志须寻找替代路线。',
    color: '#1C64F2'
  },
  {
    category: '信号标志',
    question: '闪光警告信号灯闪烁时如何通行？',
    answer: '持续闪烁的黄灯为闪光警告信号灯，提示车辆、行人注意瞭望，确认安全后通过，不停车但不减速通过是错误的。',
    color: '#1C64F2'
  },
  {
    category: '安全行车',
    question: '高速公路最低车速是多少？',
    answer: '同方向 2 车道：左侧车道最低 100km/h；同方向 3 车道以上：最左 110km/h、中间 90km/h。所有车道最低不得低于 60km/h。',
    color: '#16A34A'
  },
  {
    category: '安全行车',
    question: '安全距离口诀"4 秒法则"是什么？',
    answer: '在雨雪、结冰、夜间等条件下，与前车保持至少 4 秒的行驶距离；正常干燥路面保持 3 秒，湿滑路面加倍。',
    color: '#16A34A'
  },
  {
    category: '紧急处置',
    question: '车辆在高速公路上故障怎么办？',
    answer: '立即开启危险报警闪光灯，将车移至应急车道内停车，车上人员迅速转移至护栏外，在来车方向 150 米外设置三角警示牌，拨打救援电话。',
    color: '#8B5CF6'
  },
  {
    category: '紧急处置',
    question: '车辆落水后如何自救？',
    answer: '在车辆下沉初期解开安全带，第一时间打开车窗或用安全锤砸侧窗四角逃生；车外水压大时不要强行开门，应先破窗。',
    color: '#8B5CF6'
  },
  {
    category: '事故处理',
    question: '发生无伤亡的轻微剐蹭如何快速处理？',
    answer: '对现场拍照（前后、碰撞部位、全景带车牌）后立即撤离现场，到快处快赔点或通过 App 定责，不得长时间占用快车道争执。',
    color: '#DC2626'
  },
  {
    category: '事故处理',
    question: '伤员大出血时首选的急救措施是？',
    answer: '用干净的敷料或毛巾直接压迫止血并包扎；四肢大出血可用止血带在近心端扎紧，记录时间，尽快送医。',
    color: '#DC2626'
  },
  {
    category: '文明驾驶',
    question: '夜间会车如何正确使用灯光？',
    answer: '距对向来车 150 米内改用近光灯；在城市照明良好路段也使用近光灯。远光灯致对方眩目极易引发事故。',
    color: '#16A34A'
  }
]

@Entry
@Component
struct TipsPage {
  @State flipped: Set<number> = new Set()
  @State current: number = 0

  private flip(i: number): void {
    if (this.flipped.has(i)) {
      this.flipped.delete(i)
    } else {
      this.flipped.add(i)
    }
    this.flipped = new Set(this.flipped)
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#1F2937')
          .padding({ left: 4, right: 4 })
          .onClick(() => router.back())
        Text('考点速记')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
          .margin({ left: 6 })
        Blank()
        Text(`${this.current + 1} / ${TIPS.length}`)
          .fontSize(13)
          .fontColor('#6B7280')
      }
      .width('100%')
      .padding({ left: 14, right: 16, top: 10, bottom: 8 })

      Text('左右滑动切换 · 点击卡片翻面查看要点')
        .fontSize(12)
        .fontColor('#9CA3AF')
        .margin({ top: 8, bottom: 16 })

      Swiper() {
        ForEach(TIPS, (tip: TipCard, i: number) => {
          Column() {
            if (!this.flipped.has(i)) {
              // 正面
              Column() {
                Text(tip.category)
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(14)
                  .backgroundColor(tip.color + 'CC')
                Text(tip.question)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1F2937')
                  .textAlign(TextAlign.Center)
                  .lineHeight(30)
                  .margin({ top: 30, bottom: 30 })
                  .padding({ left: 20, right: 20 })
                Text('点击翻面')
                  .fontSize(12)
                  .fontColor('#9CA3AF')
              }
              .width('100%')
              .height(360)
              .borderRadius(24)
              .backgroundColor('#FFFFFF')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            } else {
              // 反面
              Column() {
                Text('要点')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(tip.color)
                  .alignSelf(ItemAlign.Start)
                Text(tip.answer)
                  .fontSize(16)
                  .fontColor('#1F2937')
                  .lineHeight(28)
                  .margin({ top: 18 })
                  .alignSelf(ItemAlign.Start)
                  .padding({ left: 4, right: 4 })
                Text('点击返回')
                  .fontSize(12)
                  .fontColor('#9CA3AF')
                  .margin({ top: 20 })
              }
              .width('100%')
              .height(360)
              .borderRadius(24)
              .backgroundColor(tip.color + '14')
              .padding(24)
              .justifyContent(FlexAlign.Center)
            }
          }
          .borderRadius(24)
          .onClick(() => this.flip(i))
          .animation({ duration: 260, curve: Curve.EaseOut })
        }, (tip: TipCard, i: number) => `tip-${i}`)
      }
      .indicator(true)
      .indicatorStyle({ selectedColor: '#1C64F2' })
      .itemSpace(14)
      .layoutWeight(1)
      .onChange((idx: number) => {
        this.current = idx
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
