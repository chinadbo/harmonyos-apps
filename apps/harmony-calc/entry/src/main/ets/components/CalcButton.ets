export type CalcButtonStyle = 'number' | 'operator' | 'function';

@Component
export struct CalcButton {
  @Prop text: string = '';
  @Prop styleType: CalcButtonStyle = 'number';
  @Prop widthRatio: number = 1;
  @Prop onTap: () => void = () => {};
  @State private pressed: boolean = false;

  @Builder
  private buildLabel(): void {
    Text(this.text)
      .fontSize(26)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.White)
  }

  private getBackgroundColor(): string {
    if (this.styleType === 'operator') {
      return '#FF9F0A';
    }
    if (this.styleType === 'function') {
      return '#3A3A3C';
    }
    return '#2C2C2E';
  }

  build() {
    Button() {
      this.buildLabel();
    }
    .type(ButtonType.Normal)
    .width(`calc(${this.widthRatio} * 100%)`)
    .layoutWeight(this.widthRatio)
    .height(68)
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(34)
    .scale({ x: this.pressed ? 0.94 : 1, y: this.pressed ? 0.94 : 1 })
    .animation({ duration: 120, curve: Curve.EaseOut })
    .onTouch((event?: TouchEvent) => {
      if (!event) {
        return;
      }
      if (event.type === TouchType.Down) {
        this.pressed = true;
      }
      if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressed = false;
      }
    })
    .onClick(() => {
      this.onTap();
    });
  }
}
