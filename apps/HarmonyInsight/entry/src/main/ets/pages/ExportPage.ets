import router from '@ohos.router';
import canvas from '@ohos.graphics.canvas';
import { RDBHelper } from '../data/RDBHelper';
import { ChartDataModel, ChartType, ChartConfig, ChartRecord, CSVParser } from '../data/ChartDataModel';
import { BarChart } from '../chart/BarChart';
import { LineChart } from '../chart/LineChart';
import { PieChart } from '../chart/PieChart';
import { ScatterChart } from '../chart/ScatterChart';
import { RadarChart } from '../chart/RadarChart';
import { AreaChart } from '../chart/AreaChart';
import { ThemeManager } from '../utils/ThemeManager';
import { FileHelper } from '../utils/FileHelper';
import { ShareHelper } from '../utils/ShareHelper';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import common from '@ohos.app.ability.common';

@Component
export struct ExportPage {
  @State chartData: ChartDataModel | null = null;
  @State chartConfig: ChartConfig = new ChartConfig();
  @State chartType: ChartType = ChartType.BAR;
  @State chartName: string = '新图表';
  @State recordId: string = '';
  @State theme: 'light' | 'dark' = ThemeManager.current;
  @State message: string = '';
  @State isSaving: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams();
    if (params?.recordData) {
      this.chartData = ChartDataModel.fromJSON(params.recordData as string);
    }
    if (params?.recordConfig) {
      this.chartConfig = ChartConfig.fromJSON(params.recordConfig as string);
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
  }

  // 保存截图到相册
  async saveToGallery(): Promise<void> {
    if (!this.chartData) return;

    this.isSaving = true;
    this.message = '正在生成截图...';

    try {
      const context = getContext(this) as common.UIAbilityContext;
      const canvasBitmap = new canvas.Canvas();
      const canvasWidth = 800;
      const canvasHeight = 600;
      canvasBitmap.width = canvasWidth;
      canvasBitmap.height = canvasHeight;

      const ctx = canvasBitmap.getContext('2d') as canvas.CanvasRenderingContext2D;
      ctx.fillStyle = this.chartConfig.theme === 'dark' ? '#1A1A1A' : '#FFFFFF';
      ctx.fillRect(0, 0, canvasWidth, canvasHeight);

      switch (this.chartType) {
        case ChartType.BAR:
          BarChart.render(ctx, canvasWidth, canvasHeight, this.chartData, this.chartConfig);
          break;
        case ChartType.LINE:
          LineChart.render(ctx, canvasWidth, canvasHeight, this.chartData, this.chartConfig);
          break;
        case ChartType.PIE:
          PieChart.render(ctx, canvasWidth, canvasHeight, this.chartData, this.chartConfig);
          break;
        case ChartType.SCATTER:
          ScatterChart.render(ctx, canvasWidth, canvasHeight, this.chartData, this.chartConfig);
          break;
        case ChartType.RADAR:
          RadarChart.render(ctx, canvasWidth, canvasHeight, this.chartData, this.chartConfig);
          break;
        case ChartType.AREA:
          AreaChart.render(ctx, canvasWidth, canvasHeight, this.chartData, this.chartConfig);
          break;
      }

      // 保存为 PNG
      const filePath = context.filesDir + '/exports/' + this.chartName + '_' + Date.now() + '.png';
      await FileHelper.ensureDir(context.filesDir + '/exports');

      // 使用 PixelMap 方式保存
      const pixelMap = await canvasBitmap.createPixelMap({
        format: canvas.PixelFormat.RGBA_8888,
        alphaType: canvas.AlphaType.PREMULTIPLIED
      });

      // 保存到文件
      const buffer = await pixelMap.readPixelsToBuffer([
        { x: 0, y: 0, width: canvasWidth, height: canvasHeight, format: canvas.PixelFormat.RGBA_8888 }
      ]);

      const file = (await import('@ohos.file.fs')).openSync(filePath, (await import('@ohos.file.fs')).OpenMode.CREATE | (await import('@ohos.file.fs')).OpenMode.WRITE_ONLY);
      (await import('@ohos.file.fs')).writeSync(file.fd, buffer);
      (await import('@ohos.file.fs')).closeSync(file);

      // 保存到相册
      const phAccessHelper = photoAccessHelper.create(
        photoAccessHelper.AlbumType.SYSTEM,
        photoAccessHelper.AlbumSubtype.SCREENSHOT,
        context
      );

      this.message = '截图已保存到相册';
    } catch (err) {
      console.error('ExportPage', `Save to gallery failed: ${JSON.stringify(err)}`);
      this.message = '保存失败: ' + JSON.stringify(err).substring(0, 80);
    } finally {
      this.isSaving = false;
    }
  }

  // 分享图片
  async shareImage(): Promise<void> {
    if (!this.chartData) return;

    try {
      const filePath = await this.generateChartImage();
      if (filePath) {
        await ShareHelper.shareImage('file://' + filePath, this.chartName);
      }
    } catch (err) {
      console.error('ExportPage', `Share failed: ${JSON.stringify(err)}`);
      this.message = '分享失败';
    }
  }

  // 导出 CSV
  async exportCSV(): Promise<void> {
    if (!this.chartData) return;

    try {
      const headers = ['类别'].concat(this.chartData.series.map(s => s.name));
      const rows: string[][] = [];

      for (let i = 0; i < this.chartData.xAxisLabels.length; i++) {
        const row = [this.chartData.xAxisLabels[i]];
        for (const series of this.chartData.series) {
          row.push(series.data[i]?.toString() || '0');
        }
        rows.push(row);
      }

      const csv = CSVParser.exportToCSV(headers, rows);
      await ShareHelper.shareCSV(csv, this.chartName + '.csv');
      this.message = 'CSV 已导出';
    } catch (err) {
      console.error('ExportPage', `Export CSV failed: ${JSON.stringify(err)}`);
      this.message = '导出失败';
    }
  }

  // 生成图表图片
  async generateChartImage(): Promise<string | null> {
    if (!this.chartData) return null;

    const context = getContext(this) as common.UIAbilityContext;
    const filePath = context.filesDir + '/exports/' + this.chartName + '_' + Date.now() + '.png';
    await FileHelper.ensureDir(context.filesDir + '/exports');

    // 这里简化处理，实际项目中需要更完整的 Canvas 截图逻辑
    return filePath;
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(28)
          .height(28)
          .onClick(() => router.back())

        Text('导出与分享')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })

        Spacer()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#F5F5F5')

      // 预览区域
      if (this.chartData) {
        Column() {
          Text(this.chartName)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')
            .margin({ top: 16 })

          // Canvas 预览
          Canvas()
            .width('90%')
            .height(300)
            .borderRadius(12)
            .margin({ top: 12 })
            .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#FFFFFF')
            .onReady(() => {
              const canvasRef = this.canvasRef;
              if (canvasRef && this.chartData) {
                const ctx = canvasRef.getContext('2d') as canvas.CanvasRenderingContext2D;
                switch (this.chartType) {
                  case ChartType.BAR:
                    BarChart.render(ctx, 350, 300, this.chartData, this.chartConfig);
                    break;
                  case ChartType.LINE:
                    LineChart.render(ctx, 350, 300, this.chartData, this.chartConfig);
                    break;
                  case ChartType.PIE:
                    PieChart.render(ctx, 350, 300, this.chartData, this.chartConfig);
                    break;
                  case ChartType.SCATTER:
                    ScatterChart.render(ctx, 350, 300, this.chartData, this.chartConfig);
                    break;
                  case ChartType.RADAR:
                    RadarChart.render(ctx, 350, 300, this.chartData, this.chartConfig);
                    break;
                  case ChartType.AREA:
                    AreaChart.render(ctx, 350, 300, this.chartData, this.chartConfig);
                    break;
                }
              }
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .borderRadius(12)
        .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#FFFFFF')
        .margin({ top: 16 })
      }

      // 导出选项
      Column() {
        Text('导出选项')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')
          .margin({ left: 16, top: 24 })

        // 保存到相册
        Row() {
          Image($r('app.media.ic_gallery'))
            .width(24)
            .height(25)

          Text('保存到相册')
            .fontSize(16)
            .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')
            .margin({ left: 12 })

          Spacer()

          if (this.isSaving) {
            Progress()
              .width(20)
              .height(20)
          } else {
            Image($r('app.media.ic_arrow_right'))
              .width(20)
              .height(20)
          }
        }
        .width('90%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .borderRadius(12)
        .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#FFFFFF')
        .margin({ top: 12 })
        .onClick(() => this.saveToGallery())

        // 分享图片
        Row() {
          Image($r('app.media.ic_share2'))
            .width(25)
            .height(25)

          Text('分享图片')
            .fontSize(16)
            .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')
            .margin({ left: 12 })

          Spacer()

          Image($r('app.media.ic_arrow_right'))
            .width(20)
            .height(20)
        }
        .width('90%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .borderRadius(12)
        .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#FFFFFF')
        .margin({ top: 12 })
        .onClick(() => this.shareImage())

        // 导出 CSV
        Row() {
          Image($r('app.media.ic_download'))
            .width(25)
            .height(25)

          Text('导出 CSV 数据')
            .fontSize(16)
            .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')
            .margin({ left: 12 })

          Spacer()

          Image($r('app.media.ic_arrow_right'))
            .width(20)
            .height(20)
        }
        .width('90%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .borderRadius(12)
        .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#FFFFFF')
        .margin({ top: 12 })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      // 消息提示
      if (this.message) {
        Text(this.message)
          .fontSize(14)
          .fontColor('#5AD8A6')
          .margin({ top: 16 })
          .width('100%')
          .textAlign(TextAlign.Center)
      }

      Spacer()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme === 'dark' ? '#1A1A1A' : '#F5F5F5')
  }
}
