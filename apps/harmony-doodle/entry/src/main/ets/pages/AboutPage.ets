import { router } from '@ohos.router';

@Component
export struct AboutPage {
  build() {
    Column() {
      Row() {
        Button('←')
          .width(40)
          .height(40)
          .fontSize(20)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            router.back();
          })

        Text('About')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })

      Column() {
        Text('🎨')
          .fontSize(80)
          .margin({ top: 40, bottom: 16 })

        Text('HarmonyDoodle')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text('v1.0.0')
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 8 })

        Text('A creative drawing and doodle board for HarmonyOS')
          .fontSize(14)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
          .margin({ top: 16, left: 32, right: 32 })

        Column() {
          Text('Features')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 16 })

          Text('• Freehand drawing with multi-touch support')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })
          Text('• Multiple brush tools: Pencil, Marker, Eraser, Highlighter')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })
          Text('• Shape tools: Line, Rectangle, Circle, Arrow')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })
          Text('• Color picker with 20 preset colors')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })
          Text('• Layer management with opacity control')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })
          Text('• Undo/Redo with history stack')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })
          Text('• Save and share your artworks')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 8 })
          Text('• Dark mode support')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .padding(32)
        .margin({ top: 24 })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)

        Text('© 2026 chinadbo')
          .fontSize(12)
          .fontColor('#CCCCCC')
          .margin({ top: 32 })
      }
      .layoutWeight(1)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
}
