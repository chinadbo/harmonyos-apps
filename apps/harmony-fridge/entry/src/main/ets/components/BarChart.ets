import { CategoryStat } from '../model/FoodItem';

@Component
export struct BarChart {
  @Prop data: CategoryStat[] = [];
  // P0修复：在声明时初始化 context2D，确保 Canvas 组件绑定到同一实例
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @State private canvasWidth: number = 300;

  private drawChart(width: number, height: number): void {
    const context: CanvasRenderingContext2D = this.context2D;
    context.clearRect(0, 0, width, height);
    const safeData: CategoryStat[] = this.data.length > 0 ? this.data : [new CategoryStat('暂无', 0)];
    const maxValue: number = safeData.reduce((max: number, item: CategoryStat) => Math.max(max, item.count), 1);
    const barWidth: number = width / (safeData.length * 1.8);
    safeData.forEach((item: CategoryStat, index: number) => {
      const x: number = 24 + index * (barWidth + 20);
      const barHeight: number = maxValue === 0 ? 6 : (item.count / maxValue) * (height - 70);
      const y: number = height - 40 - barHeight;
      context.fillStyle = '#6EA56A';
      context.fillRect(x, y, barWidth, barHeight);
      context.fillStyle = '#345532';
      context.font = '12px sans-serif';
      context.fillText(item.category, x, height - 16);
      context.fillText(`${item.count}`, x + 4, y - 6);
    });
  }

  build() {
    Canvas(this.context2D)
      .width('100%')
      .height(240)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .onAreaChange((_oldValue: Area, newValue: Area) => {
        this.canvasWidth = newValue.width as number;
      })
      .onReady(() => {
        // P0修复：onReady 中直接使用已初始化的 context2D 绘制
        this.drawChart(this.canvasWidth > 0 ? this.canvasWidth : 300, 240);
      })
  }
}
