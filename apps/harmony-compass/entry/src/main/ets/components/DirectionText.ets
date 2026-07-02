@Component
export struct DirectionText {
  @Prop heading: number = 0;

  private getDirectionName(heading: number): string {
    let normalized = ((heading % 360) + 360) % 360;
    let index = Math.round(normalized / 45) % 8;
    const directions: string[] = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[index];
  }

  private getDirectionFullName(heading: number): string {
    let normalized = ((heading % 360) + 360) % 360;
    let index = Math.round(normalized / 45) % 8;
    const fullNames: string[] = [
      'North', 'Northeast', 'East', 'Southeast',
      'South', 'Southwest', 'West', 'Northwest'
    ];
    return fullNames[index];
  }

  build() {
    Column() {
      Text(this.getDirectionName(this.heading))
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor('#e94560')
        .textAlign(TextAlign.Center)

      Text(this.getDirectionFullName(this.heading))
        .fontSize(20)
        .fontColor('#8892b0')
        .textAlign(TextAlign.Center)
        .margin({ top: 4 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}