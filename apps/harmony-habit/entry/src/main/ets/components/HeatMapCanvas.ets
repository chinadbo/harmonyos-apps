import { COLOR_PALETTE } from '../common/Constants';

export interface HeatMapPoint {
  date: string;
  level: number;
}

@Component
export struct HeatMapCanvas {
  @Prop points: HeatMapPoint[] = [];
  @Prop title: string = '近 12 周热力图';
  @Prop colorIndex: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear(): void {
    this.drawHeatMap();
  }

  private cellColor(level: number): string {
    const accent = COLOR_PALETTE[this.colorIndex % COLOR_PALETTE.length];
    if (level <= 0) {
      return '#E5E7EB';
    }
    if (level === 1) {
      return '#D6E4FF';
    }
    if (level === 2) {
      return '#8FB8FF';
    }
    return accent;
  }

  private drawHeatMap(): void {
    const size = 14;
    const gap = 6;
    this.context2D.clearRect(0, 0, 240, 140);
    for (let index = 0; index < this.points.length; index++) {
      const col = Math.floor(index / 7);
      const row = index % 7;
      this.context2D.fillStyle = this.cellColor(this.points[index].level);
      this.context2D.beginPath();
      this.context2D.roundRect(col * (size + gap), row * (size + gap), size, size, 4);
      this.context2D.fill();
    }
  }

  build() {
    Column({ space: 12 }) {
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E2430')
        .width('100%')
        .textAlign(TextAlign.Start)

      Canvas(this.context2D)
        .width(240)
        .height(140)
        .backgroundColor('#FFFFFF')
        .onReady(() => {
          this.drawHeatMap();
        })
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
  }
}
