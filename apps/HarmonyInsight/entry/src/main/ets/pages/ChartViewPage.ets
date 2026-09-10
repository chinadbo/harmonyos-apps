import router from '@ohos.router';
import canvas from '@ohos.graphics.canvas';
import { RDBHelper } from '../data/RDBHelper';
import { ChartDataModel, ChartType, ChartConfig, ChartRecord } from '../data/ChartDataModel';
import { BarChart } from '../chart/BarChart';
import { LineChart } from '../chart/LineChart';
import { PieChart } from '../chart/PieChart';
import { ScatterChart } from '../chart/ScatterChart';
import { RadarChart } from '../chart/RadarChart';
import { AreaChart } from '../chart/AreaChart';
import { ThemeManager } from '../utils/ThemeManager';

@Component
export struct ChartViewPage {
  @State chartData: ChartDataModel | null = null;
  @State chartConfig: ChartConfig = new ChartConfig();
  @State chartType: ChartType = ChartType.BAR;
  @State chartName: string = '新图表';
  @State recordId: string = '';
  @State isEdit: boolean = false;
  @State theme: 'light' | 'dark' = ThemeManager.current;
  @State highlightIndex: number = -1;

  aboutToAppear(): void {
    const params = router.getParams();
    if (params?.recordData) {
      this.chartData = ChartDataModel.fromJSON(params.recordData as string);
    }
    if (params?.recordConfig) {
      this.chartConfig = ChartConfig.fromJSON(params.recordConfig as string);
      this.theme = this.chartConfig.theme;
    }
    if (params?.recordType) {
      this.chartType = params.recordType as ChartType;
    }
    if (params?.recordName) {
      this.chartName = params.recordName as string;
    }
    if (params?.recordId) {
      this.recordId = params.recordId as string;
    }
    if (params?.isEdit) {
      this.isEdit = params.isEdit as boolean;
    }
  }

  // 保存图表到历史
  async saveChart(): Promise<void> {
    if (!this.chartData) return;

    const record: ChartRecord = {
      id: this.recordId,
      name: this.chartName,
      type: this.chartType,
      data: this.chartData.toJSON(),
      config: this.chartConfig.toJSON(),
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    try {
      await RDBHelper.saveRecord(record);
      console.info('ChartViewPage', 'Chart saved');
    } catch (err) {
      console.error('ChartViewPage', `Save failed: ${JSON.stringify(err)}`);
    }
  }

  // 编辑图表
  onEdit(): void {
    router.pushUrl({
      url: 'pages/ChartConfigPage',
      params: {
        recordId: this.recordId,
        recordName: this.chartName,
        recordType: this.chartType,
        recordData: this.chartData?.toJSON() || '',
        recordConfig: this.chartConfig.toJSON(),
        isEdit: true
      }
    });
  }

  // 导出
  onExport(): void {
    router.pushUrl({
      url: 'pages/ExportPage',
      params: {
        recordId: this.recordId,
        recordName: this.chartName,
        recordType: this.chartType,
        recordData: this.chartData?.toJSON() || '',
        recordConfig: this.chartConfig.toJSON()
      }
    });
  }

  // 切换主题
  toggleTheme(): void {
    this.chartConfig.theme = this.chartConfig.theme === 'light' ? 'dark' : 'light';
    this.theme = this.chartConfig.theme;
    ThemeManager.setTheme(this.theme);
  }

  // 渲染图表
  onCanvasDraw(canvasContext: canvas.CanvasRenderingContext2D, canvasWidth: number, canvasHeight: number): void {
    if (!this.chartData) return;

    canvasContext.save();

    switch (this.chartType) {
      case ChartType.BAR:
        BarChart.render(canvasContext, canvasWidth, canvasHeight, this.chartData, this.chartConfig, this.highlightIndex);
        break;
      case ChartType.LINE:
        LineChart.render(canvasContext, canvasWidth, canvasHeight, this.chartData, this.chartConfig);
        break;
      case ChartType.PIE:
        PieChart.render(canvasContext, canvasWidth, canvasHeight, this.chartData, this.chartConfig, false, this.highlightIndex);
        break;
      case ChartType.SCATTER:
        ScatterChart.render(canvasContext, canvasWidth, canvasHeight, this.chartData, this.chartConfig);
        break;
      case ChartType.RADAR:
        RadarChart.render(canvasContext, canvasWidth, canvasHeight, this.chartData, this.chartConfig);
        break;
      case ChartType.AREA:
        AreaChart.render(canvasContext, canvasWidth, canvasHeight, this.chartData, this.chartConfig);
        break;
    }

    canvasContext.restore();
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(28)
          .height(28)
          .onClick(() => router.back())

        Text(this.chartName)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')
          .margin({ left: 16 })

        Spacer()

        // 主题切换
        Image(this.theme === 'dark' ? $r('app.media.ic_light') : $r('app.media.ic_dark'))
          .width(24)
          .height(24)
          .onClick(() => this.toggleTheme())
          .margin({ right: 8 })

        // 编辑
        Image($r('app.media.ic_edit'))
          .width(24)
          .height(24)
          .onClick(() => this.onEdit())
          .margin({ right: 8 })

        // 导出
        Image($r('app.media.ic_share'))
          .width(24)
          .height(24)
          .onClick(() => this.onExport())
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#F5F5F5')

      // 图表区域
      if (this.chartData) {
        Canvas()
          .width('90%')
          .height(400)
          .borderRadius(12)
          .margin({ top: 16 })
          .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#FFFFFF')
          .onReady(() => {
            if (this.chartData) {
              const canvasContext = this.canvasRef?.getContext('2d') as canvas.CanvasRenderingContext2D;
              if (canvasContext) {
                this.onCanvasDraw(canvasContext, 400, 400);
              }
            }
          })
          .onTouch((event: TouchEvent) => {
            // 点击高亮
            const touch = event.touches[0];
            if (touch) {
              // 简单计算点击位置对应的数据索引
              const rect = this.canvasRef?.getBoundingClientRect();
              if (rect) {
                const x = touch.x - rect.left;
                const total = this.chartData?.getMaxSeriesLength() || 1;
                const index = Math.floor((x / rect.width) * total);
                this.highlightIndex = index >= 0 && index < total ? index : -1;
              }
            }
          })

        // 数据概览
        if (this.chartData) {
          Column() {
            Text('数据概览')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')
              .margin({ top: 16 })

            Row() {
              Column() {
                Text('数据点')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(this.chartData.getTotalDataPoints().toString())
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#5B8FF9')
              }
              .width('33%')

              Column() {
                Text('系列数')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(this.chartData.series.length.toString())
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#5AD8A6')
              }
              .width('33%')

              Column() {
                Text('类型')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(this.getChartTypeName(this.chartType))
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FF6B6B')
              }
              .width('33%')
            }
            .width('100%')
            .margin({ top: 8 })
          }
          .width('90%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .borderRadius(12)
          .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#FFFFFF')
          .margin({ top: 12 })
        }
      }

      Spacer()

      // 底部保存按钮
      Row() {
        Button('保存到历史')
          .onClick(() => this.saveChart())
          .type(ButtonType.Capsule)
          .backgroundColor('#5AD8A6')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .padding({ left: 32, right: 32 })
          .margin({ left: 16 })

        Spacer()

        Button('导出')
          .onClick(() => this.onExport())
          .type(ButtonType.Capsule)
          .backgroundColor('#5B8FF9')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .padding({ left: 32, right: 32 })
          .margin({ right: 16 })
      }
      .width('100%')
      .height(64)
      .alignItems(VerticalAlign.Center)
      .border({ top: { width: 1, color: this.theme === 'dark' ? '#333333' : '#E8E8E8' } })
      .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme === 'dark' ? '#1A1A1A' : '#F5F5F5')
  }

  getChartTypeName(type: ChartType): string {
    switch (type) {
      case ChartType.BAR: return '柱状图';
      case ChartType.LINE: return '折线图';
      case ChartType.PIE: return '饼图';
      case ChartType.SCATTER: return '散点图';
      case ChartType.RADAR: return '雷达图';
      case ChartType.AREA: return '面积图';
      default: return '未知';
    }
  }
}
