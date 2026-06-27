@Component
export struct StepCounter {
  @Prop steps: number

  build() {
    Text(`Steps: ${this.steps}`)
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .fontColor('#182431')
  }
}
