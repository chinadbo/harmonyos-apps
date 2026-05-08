import { Card } from '../model/Card';
import { TtsService } from '../service/TtsService';

@Component
export struct FlashCard {
  @Prop card: Card = {} as Card;
  @State isFlipped: boolean = false;
  @State rotationY: number = 0;
  @State showBack: boolean = false;

  build() {
    Stack() {
      // 正面
      Column() {
        Text(this.card.front)
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A2E')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 12 })

        if (this.card.phonetic) {
          Text(this.card.phonetic)
            .fontSize(18)
            .fontColor('#6B7280')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 16 })
        }

        // 使用 emoji 代替图片资源，避免缺少 ic_volume 资源文件
        Button({ type: ButtonType.Normal }) {
          Text('🔊').fontSize(20)
        }
        .height(44)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#E8F4FD')
        .borderRadius(22)
        .onClick(() => {
          TtsService.getInstance().speak(this.card.front).catch(() => {});
        })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .visibility(this.showBack ? Visibility.Hidden : Visibility.Visible)

      // 背面
      Column() {
        Text(this.card.back)
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A2E')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 16 })
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.card.example) {
          Text(this.card.example)
            .fontSize(16)
            .fontColor('#6B7280')
            .textAlign(TextAlign.Center)
            .fontStyle(FontStyle.Italic)
            .padding({ left: 16, right: 16 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .visibility(this.showBack ? Visibility.Visible : Visibility.Hidden)
    }
    .width('100%')
    .height(280)
    .backgroundColor(this.showBack ? '#F0FDF4' : '#EFF6FF')
    .borderRadius(20)
    .shadow({ radius: 12, color: '#0000001A', offsetX: 0, offsetY: 4 })
    .rotate({ y: 1, angle: this.rotationY })
    .onClick(() => {
      this.flipCard();
    })
  }

  private flipCard(): void {
    const duration = 200;
    if (this.isFlipped) {
      animateTo({ duration: duration, curve: Curve.EaseIn }, () => {
        this.rotationY = 90;
      });
      // 在动画中途切换内容，再翻回
      animateTo({ duration: duration, curve: Curve.EaseOut, delay: duration }, () => {
        this.showBack = false;
        this.rotationY = 0;
      });
      this.isFlipped = false;
    } else {
      animateTo({ duration: duration, curve: Curve.EaseIn }, () => {
        this.rotationY = 90;
      });
      animateTo({ duration: duration, curve: Curve.EaseOut, delay: duration }, () => {
        this.showBack = true;
        this.rotationY = 0;
      });
      this.isFlipped = true;
    }
  }

  resetFlip(): void {
    this.isFlipped = false;
    this.rotationY = 0;
    this.showBack = false;
  }
}
