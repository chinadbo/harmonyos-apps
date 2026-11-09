@Component
export struct NumberRoll {
  @Prop @Watch('roll') value: number = 0;
  @Prop fontSize: number = 36;
  @Prop color: string = '#FFFFFF';
  @Prop fontWeightVal: number = 700;
  @State shown: number = 0;
  @State opacityV: number = 1;
  @State offsetY: number = 0;
  private timerId: number = -1;

  aboutToAppear(): void {
    this.shown = this.value;
  }

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearTimeout(this.timerId);
      this.timerId = -1;
    }
  }

  private roll(): void {
    const target = this.value;
    if (target === this.shown) {
      return;
    }
    this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
      this.opacityV = 0;
      this.offsetY = -14;
    });
    this.timerId = setTimeout(() => {
      this.timerId = -1;
      this.shown = target;
      this.getUIContext().animateTo({ duration: 400, curve: Curve.EaseOut }, () => {
        this.opacityV = 1;
        this.offsetY = 0;
      });
    }, 210);
  }

  build() {
    Text(`${this.shown}`)
      .fontSize(this.fontSize)
      .fontWeight(this.fontWeightVal)
      .fontColor(this.color)
      .opacity(this.opacityV)
      .translate({ y: this.offsetY })
  }
}
