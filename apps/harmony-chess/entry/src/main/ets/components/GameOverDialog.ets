/**
 * 对局结束对话框
 */
import { Color } from '../model/Types';

@CustomDialog
export struct GameOverDialog {
  controller: CustomDialogController;
  @Prop status: string; // checkmate | stalemate | draw | resigned
  @Prop winner: Color | null;
  onSave: () => void = () => {};
  onClose: () => void = () => {};

  private statusText(): string {
    let title = '';
    switch (this.status) {
      case 'checkmate':
        title = this.winner === Color.White ? '白方将杀获胜' : '黑方将杀获胜';
        break;
      case 'stalemate':
        title = '逼和（无子可动）';
        break;
      case 'draw':
        title = '和棋';
        break;
      case 'resigned':
        title = this.winner === Color.White ? '黑方认输，白方胜' : '白方认输，黑方胜';
        break;
      default:
        title = '对局结束';
    }
    return title;
  }

  build() {
    Column({ space: 12 }) {
      Text(this.statusText())
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      Text('是否保存本局棋谱以便复盘？')
        .fontSize(14)
        .fontColor('#666666')
      Row({ space: 12 }) {
        Button('保存棋谱')
          .onClick(() => {
            this.onSave();
            this.controller.close();
          })
        Button('关闭')
          .backgroundColor('#CCCCCC')
          .fontColor('#333333')
          .onClick(() => {
            this.onClose();
            this.controller.close();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ top: 8 })
    }
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}
