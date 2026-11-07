/**
 * 数字滚动动画组件：值变化时 animateTo 平滑过渡
 */

@Component
export struct NumberRoll {
  @Prop @Watch('onValueChanged') value: number = 0
  @State display: number = 0
  @Prop color: string = '#1F2329'
  @Prop fontSize: number = 16
  @Prop fontWeight: number = 700
  @Prop precision: number = 2
  @Prop prefix: string = ''
  @Prop fontFamily: string = 'sans-serif'

  aboutToAppear(): void {
    this.display = this.value
  }

  private onValueChanged(): void {
    animateTo({
      duration: 500,
      curve: Curve.EaseOut,
      onFinish: () => {
      }
    }, () => {
      this.display = this.value
    })
  }

  build() {
    Text(this.prefix + this.display.toFixed(this.precision))
      .fontSize(this.fontSize)
      .fontWeight(this.fontWeight)
      .fontColor(this.color)
      .fontFamily(this.fontFamily)
      .maxLines(1)
  }
}
