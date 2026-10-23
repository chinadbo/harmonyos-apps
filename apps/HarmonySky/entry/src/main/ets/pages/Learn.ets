import { LearnCard } from '../model/models';
import { learnCards } from '../engine/stardata';
import { StarSkyCanvas } from '../components/StarSkyCanvas';
import { SkyCard } from '../components/SkyCard';
import { NavBar } from '../components/NavBar';

@Entry
@Component
struct Learn {
  @State index: number = 0;
  @State flipped: boolean = false;
  private cards: LearnCard[] = learnCards;

  build() {
    Stack() {
      StarSkyCanvas()
      Column() {
        Scroll() {
          Column({ space: 12 }) {
            Text('天文知识卡')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F2F5FF')

            Text(`${this.index + 1} / ${this.cards.length}`)
              .fontSize(12)
              .fontColor('#9AA3C7')

            SkyCard() {
              Column({ space: 10 }) {
                Text(this.cards[this.index].title)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#F5D76E')
                Text(this.cards[this.index].subtitle)
                  .fontSize(13)
                  .fontColor('#9AA3C7')

                if (this.flipped) {
                  // 背面：正文 + 冷知识
                  Column({ space: 10 }) {
                    Text(this.cards[this.index].body)
                      .fontSize(14)
                      .fontColor('#F2F5FF')
                      .lineHeight(24)
                    ForEach(this.cards[this.index].facts, (f: string) => {
                      Row({ space: 6 }) {
                        Text('◆')
                          .fontSize(12)
                          .fontColor('#F5D76E')
                        Text(f)
                          .fontSize(13)
                          .fontColor('#C9D2F2')
                          .layoutWeight(1)
                      }
                      .width('100%')
                    }, (f: string) => f)
                  }
                  .transition(TransitionEffect.OPACITY.animation({ duration: 250 }))
                } else {
                  Column() {
                    Text('🌌')
                      .fontSize(64)
                    Text('点击卡片查看正文与冷知识')
                      .fontSize(13)
                      .fontColor('#9AA3C7')
                  }
                  .padding(30)
                  .alignItems(HorizontalAlign.Center)
                  .transition(TransitionEffect.OPACITY.animation({ duration: 250 }))
                }
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                this.flipped = !this.flipped;
              })
            }

            // 翻卡与切换
            Row({ space: 10 }) {
              Button('◀ 上一张')
                .fontSize(14)
                .height(40)
                .backgroundColor('#161B3A')
                .fontColor('#F2F5FF')
                .onClick(() => {
                  this.flipped = false;
                  this.index = (this.index - 1 + this.cards.length) % this.cards.length;
                })
              Button(this.flipped ? '收起' : '翻面')
                .fontSize(14)
                .height(40)
                .backgroundColor('#5B8DEF')
                .fontColor('#FFFFFF')
                .onClick(() => {
                  this.flipped = !this.flipped;
                })
              Button('下一张 ▶')
                .fontSize(14)
                .height(40)
                .backgroundColor('#161B3A')
                .fontColor('#F2F5FF')
                .onClick(() => {
                  this.flipped = false;
                  this.index = (this.index + 1) % this.cards.length;
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)

            // 目录缩略
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
              ForEach(this.cards, (c: LearnCard, i: number) => {
                Text(c.title)
                  .fontSize(12)
                  .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                  .margin(3)
                  .borderRadius(12)
                  .backgroundColor(this.index === i ? '#F5D76E' : '#22284E')
                  .fontColor(this.index === i ? '#0B1026' : '#C9D2F2')
                  .onClick(() => {
                    this.flipped = false;
                    this.index = i;
                  })
              }, (c: LearnCard) => c.id)
            }
            .width('100%')
            .padding({ bottom: 8 })
          }
          .padding(16)
          .constraintSize({ minHeight: '100%' })
        }
        .align(Alignment.Top)
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        NavBar({ current: 4 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0B1026')
  }
}
