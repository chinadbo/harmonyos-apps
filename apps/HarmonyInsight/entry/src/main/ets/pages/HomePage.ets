import router from '@ohos.router';
import { RDBHelper } from '../data/RDBHelper';
import { ChartRecord, ChartType, ChartDataModel, ChartConfig, SeriesData } from '../data/ChartDataModel';
import { ThemeManager } from '../utils/ThemeManager';

@Component
export struct HomePage {
  @State chartRecords: ChartRecord[] = [];
  @State isLoading: boolean = false;
  @State theme: 'light' | 'dark' = ThemeManager.current;

  aboutToAppear(): void {
    this.loadHistory();
  }

  async loadHistory(): Promise<void> {
    this.isLoading = true;
    try {
      this.chartRecords = await RDBHelper.getAllRecords(30);
    } catch (err) {
      console.error('HomePage', `Load history failed: ${JSON.stringify(err)}`);
    }
    this.isLoading = false;
  }

  // 新建图表
  onNewChart(): void {
    router.pushUrl({ url: 'pages/DataInputPage' });
  }

  // 查看图表
  onViewChart(record: ChartRecord): void {
    router.pushUrl({
      url: 'pages/ChartViewPage',
      params: {
        recordId: record.id,
        recordName: record.name,
        recordType: record.type
      }
    });
  }

  // 编辑图表
  onEditChart(record: ChartRecord): void {
    router.pushUrl({
      url: 'pages/ChartConfigPage',
      params: {
        recordId: record.id,
        recordName: record.name,
        recordType: record.type,
        recordData: record.data,
        recordConfig: record.config,
        isEdit: true
      }
    });
  }

  // 删除图表
  async onDeleteChart(record: ChartRecord): Promise<void> {
    try {
      await RDBHelper.deleteRecord(record.id);
      this.chartRecords = this.chartRecords.filter(r => r.id !== record.id);
    } catch (err) {
      console.error('HomePage', `Delete failed: ${JSON.stringify(err)}`);
    }
  }

  // 创建示例数据
  onCreateSample(): void {
    const model = new ChartDataModel('月度销售数据');
    model.chartType = ChartType.BAR;
    model.xAxisLabels = ['1月', '2月', '3月', '4月', '5月', '6月'];
    model.series = [
      { name: '产品A', data: [120, 150, 180, 140, 200, 230], color: '#5B8FF9' },
      { name: '产品B', data: [80, 100, 120, 90, 130, 160], color: '#5AD8A6' }
    ];

    const config = new ChartDataModel.ChartConfig();
    config.showLegend = true;
    config.showLabels = true;
    config.showGrid = true;

    const record: ChartRecord = {
      id: Date.now().toString(),
      name: '示例图表',
      type: ChartType.BAR,
      data: model.toJSON(),
      config: config.toJSON(),
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    router.pushUrl({
      url: 'pages/ChartConfigPage',
      params: {
        recordId: record.id,
        recordName: record.name,
        recordType: record.type,
        recordData: record.data,
        recordConfig: record.config,
        isEdit: false,
        isSample: true
      }
    });
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Text('HarmonyInsight')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 20 })

        Spacer()

        // 主题切换
        Image(this.theme === 'dark' ? $r('app.media.ic_light') : $r('app.media.ic_dark'))
          .width(28)
          .height(28)
          .margin({ right: 20 })
          .onClick(() => {
            ThemeManager.toggle();
            this.theme = ThemeManager.current;
          })
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#F5F5F5')

      // 工具栏
      Row() {
        Button('+ 新建图表')
          .onClick(this.onNewChart)
          .type(ButtonType.Capsule)
          .backgroundColor('#5B8FF9')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .margin({ left: 20, top: 16 })

        Button('示例数据')
          .onClick(this.onCreateSample)
          .type(ButtonType.Capsule)
          .backgroundColor('#5AD8A6')
          .fontColor('#FFFFFF')
          .fontSize(14)
          .margin({ left: 12, top: 16 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      // 历史列表
      if (this.isLoading) {
        Column() {
          Progress()
            .margin({ top: 40 })
          Text('加载中...')
            .margin({ top: 12 })
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height('80%')
        .justifyContent(FlexAlign.Center)
      } else if (this.chartRecords.length === 0) {
        Column() {
          Image($r('app.media.ic_empty'))
            .width(80)
            .height(80)
            .margin({ top: 80 })
          Text('暂无图表')
            .margin({ top: 16 })
            .fontSize(16)
            .fontColor('#999999')
          Text('点击上方按钮创建第一个图表')
            .margin({ top: 8 })
            .fontSize(12)
            .fontColor('#CCCCCC')
        }
        .width('100%')
      } else {
        List({ space: 12 }) {
          ForEach(this.chartRecords, (record: ChartRecord) => {
            ListItem() {
              Column() {
                Row() {
                  // 图表类型图标
                  Text(this.getChartTypeIcon(record.type))
                    .fontSize(24)
                    .margin({ right: 12 })

                  Column() {
                    Text(record.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')

                    Row() {
                      Text(this.getChartTypeName(record.type))
                        .fontSize(12)
                        .fontColor('#5B8FF9')
                        .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#F0F4FF')
                        .borderRadius(4)
                        .padding({ left: 8, right: 8, top: 2, bottom: 2 })

                      Spacer()
                      Text(this.formatDate(record.updatedAt))
                        .fontSize(12)
                        .fontColor('#999999')
                    }
                    .margin({ top: 4 })
                  }

                  Spacer()

                  // 操作按钮
                  Button('查看')
                    .onClick(() => this.onViewChart(record))
                    .type(ButtonType.Capsule)
                    .backgroundColor('#5B8FF9')
                    .fontColor('#FFFFFF')
                    .fontSize(12)
                    .minWidth(56)
                    .height(28)

                  Button('编辑')
                    .onClick(() => this.onEditChart(record))
                    .type(ButtonType.Capsule)
                    .backgroundColor('#5AD8A6')
                    .fontColor('#FFFFFF')
                    .fontSize(12)
                    .minWidth(56)
                    .height(28)
                    .margin({ left: 8 })

                  Button('删除')
                    .onClick(() => this.onDeleteChart(record))
                    .type(ButtonType.Capsule)
                    .backgroundColor('#FF6B6B')
                    .fontColor('#FFFFFF')
                    .fontSize(12)
                    .minWidth(56)
                    .height(28)
                    .margin({ left: 8 })
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .borderRadius(8)
                .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#FFFFFF')
              }
            }
          }, (record: ChartRecord) => record.id)
        }
        .width('100%')
        .margin({ top: 8, bottom: 20 })
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme === 'dark' ? '#1A1A1A' : '#F5F5F5')
  }

  getChartTypeIcon(type: ChartType): string {
    switch (type) {
      case ChartType.BAR: return '📊';
      case ChartType.LINE: return '📈';
      case ChartType.PIE: return '🍩';
      case ChartType.SCATTER: return '💎';
      case ChartType.RADAR: return '🎯';
      case ChartType.AREA: return '📐';
      default: return '📊';
    }
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

  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
  }
}
