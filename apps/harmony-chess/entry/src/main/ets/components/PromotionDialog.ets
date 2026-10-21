/**
 * 兵升变选择对话框
 */
import { PieceType } from '../model/Types';

@CustomDialog
export struct PromotionDialog {
  controller: CustomDialogController;
  onSelect: (t: PieceType) => void = (t: PieceType) => {};

  build() {
    Column() {
      Text('兵升变')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })
      Row({ space: 16 }) {
        Button('后 ♕')
          .fontSize(20)
          .onClick(() => {
            this.onSelect(PieceType.Queen);
            this.controller.close();
          })
        Button('车 ♖')
          .fontSize(20)
          .onClick(() => {
            this.onSelect(PieceType.Rook);
            this.controller.close();
          })
        Button('象 ♗')
          .fontSize(20)
          .onClick(() => {
            this.onSelect(PieceType.Bishop);
            this.controller.close();
          })
        Button('马 ♘')
          .fontSize(20)
          .onClick(() => {
            this.onSelect(PieceType.Knight);
            this.controller.close();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}
