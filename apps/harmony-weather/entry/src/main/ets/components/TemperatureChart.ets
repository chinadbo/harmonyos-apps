import { DailyWeather } from '../model/WeatherModel';

@Component
export struct TemperatureChart {
  @Prop days: Array<DailyWeather>;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private readonly chartWidth: number = 640;
  private readonly chartHeight: number = 180;

  aboutToAppear(): void {
    this.drawChart();
  }

  private maxTemp(): number {
    let max = 0;
    this.days.forEach((item: DailyWeather) => {
      const value = Number(item.maxtempC);
      if (value > max) {
        max = value;
      }
    });
    return max;
  }

  private minTemp(): number {
    let min = 0;
    if (this.days.length > 0) {
      min = Number(this.days[0].mintempC);
    }
    this.days.forEach((item: DailyWeather) => {
      const value = Number(item.mintempC);
      if (value < min) {
        min = value;
      }
    });
    return min;
  }

  private pointY(value: number): number {
    const max = this.maxTemp();
    const min = this.minTemp();
    const range = Math.max(1, max - min);
    return this.chartHeight - ((value - min) / range) * (this.chartHeight - 40) - 20;
  }

  private drawChart(): void {
    this.context2D.clearRect(0, 0, this.chartWidth, this.chartHeight);
    this.context2D.strokeStyle = '#66FFFFFF';
    this.context2D.lineWidth = 2;
    this.context2D.beginPath();

    this.days.forEach((day: DailyWeather, index: number) => {
      const x = 40 + index * 90;
      const y = this.pointY(Number(day.maxtempC));
      if (index === 0) {
        this.context2D.moveTo(x, y);
      } else {
        this.context2D.lineTo(x, y);
      }
    });
    this.context2D.stroke();

    this.days.forEach((day: DailyWeather, index: number) => {
      const x = 40 + index * 90;
      const y = this.pointY(Number(day.maxtempC));
      this.context2D.fillStyle = '#FFFFFF';
      this.context2D.beginPath();
      this.context2D.arc(x, y, 5, 0, Math.PI * 2);
      this.context2D.fill();
      this.context2D.font = '18px sans-serif';
      this.context2D.fillText(`${day.maxtempC}°`, x - 12, y - 12);
    });
  }

  build() {
    Column({ space: 12 }) {
      Text('7-Day Temperature Trend')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#F7FBFF')

      Canvas(this.context2D)
        .width('100%')
        .height(this.chartHeight)
        .backgroundColor('#14FFFFFF')
        .borderRadius(24)
        .onReady(() => {
          this.drawChart();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
