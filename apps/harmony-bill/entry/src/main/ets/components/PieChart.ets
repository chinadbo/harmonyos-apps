export interface PieChartDataItem {
  label: string;
  value: number;
  color: string;
}

@Component
export struct PieChart {
  @Prop data: PieChartDataItem[] = [];
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @State private chartWidth: number = 320;
  @State private chartHeight: number = 220;

  build() {
    Column({ space: 12 }) {
      if (this.data.length === 0) {
        Text('暂无消费占比数据')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .height(220)
          .textAlign(TextAlign.Center)
      } else {
        Canvas(this.context2D)
          .width('100%')
          .height(220)
          .backgroundColor('#FFFFFFFF')
          .onReady(() => {
            this.drawChart();
          })
          .onAreaChange((_, value) => {
            this.chartWidth = Number(value.width);
            this.chartHeight = Number(value.height);
            this.drawChart();
          })

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.data, (item: PieChartDataItem) => {
            Row({ space: 6 }) {
              Blank()
                .width(10)
                .height(10)
                .borderRadius(5)
                .backgroundColor(item.color)
              Text(item.label + ' ' + ((item.value / this.getTotal()) * 100).toFixed(0) + '%')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }
            .margin({ right: 8, bottom: 8 })
          })
        }
      }
    }
    .width('100%')
  }

  private getTotal(): number {
    let total = 0;
    this.data.forEach((item) => {
      total += item.value;
    });
    return total <= 0 ? 1 : total;
  }

  private drawChart(): void {
    if (this.data.length === 0) {
      return;
    }
    const total = this.getTotal();
    const centerX = this.chartWidth / 2;
    const centerY = this.chartHeight / 2;
    const radius = Math.min(this.chartWidth, this.chartHeight) * 0.32;
    let startAngle = -Math.PI / 2;

    this.context2D.clearRect(0, 0, this.chartWidth, this.chartHeight);
    this.data.forEach((item) => {
      const angle = (item.value / total) * Math.PI * 2;
      this.context2D.beginPath();
      this.context2D.moveTo(centerX, centerY);
      this.context2D.arc(centerX, centerY, radius, startAngle, startAngle + angle);
      this.context2D.closePath();
      this.context2D.fillStyle = item.color;
      this.context2D.fill();
      startAngle += angle;
    });

    this.context2D.beginPath();
    this.context2D.arc(centerX, centerY, radius * 0.52, 0, Math.PI * 2);
    this.context2D.closePath();
    this.context2D.fillStyle = '#FFFFFFFF';
    this.context2D.fill();
  }
}
