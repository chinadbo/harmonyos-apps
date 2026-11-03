import { Theme } from '../model/Theme';

const KEY_CLEAR: string = 'C';
const KEY_CONFIRM: string = 'OK';
const MAX_INPUT_LEN: number = 3;

@Component
export struct KeypadComponent {
  @Link inputValue: string;
  onConfirm: () => void = () => {
  };

  private keys: string[] = ['1', '2', '3', '4', '5', '6', '7', '8', '9', KEY_CLEAR, '0', KEY_CONFIRM];

  build() {
    Grid() {
      ForEach(this.keys, (key: string) => {
        GridItem() {
          this.KeyCell(key)
        }
      }, (key: string) => key)
    }
    .columnsTemplate('1fr 1fr 1fr')
    .columnsGap(10)
    .rowsGap(10)
    .width('100%')
    .height(278)
  }

  @Builder
  KeyCell(key: string) {
    Text(this.display(key))
      .fontSize(22)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.keyColor(key))
      .backgroundColor(this.keyBackground(key))
      .borderRadius(14)
      .width('100%')
      .height(62)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        this.onPress(key);
      })
  }

  private display(key: string): string {
    if (key === KEY_CLEAR) {
      return '清除';
    }
    if (key === KEY_CONFIRM) {
      return '确认';
    }
    return key;
  }

  private keyColor(key: string): ResourceColor {
    if (key === KEY_CONFIRM) {
      return Color.White;
    }
    if (key === KEY_CLEAR) {
      return Theme.DANGER;
    }
    return Theme.TEXT_DARK;
  }

  private keyBackground(key: string): ResourceColor {
    if (key === KEY_CONFIRM) {
      return Theme.PRIMARY;
    }
    if (key === KEY_CLEAR) {
      return Theme.DANGER_LIGHT;
    }
    return Theme.KEY_BG;
  }

  private onPress(key: string): void {
    if (key === KEY_CLEAR) {
      this.inputValue = '';
      return;
    }
    if (key === KEY_CONFIRM) {
      this.onConfirm();
      return;
    }
    if (this.inputValue.length >= MAX_INPUT_LEN) {
      return;
    }
    if (this.inputValue === '0') {
      this.inputValue = key;
      return;
    }
    this.inputValue += key;
  }
}
