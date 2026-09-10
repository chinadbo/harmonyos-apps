import router from '@ohos.router';
import { ChartDataModel, ChartType, ChartConfig, SeriesData } from '../data/ChartDataModel';
import { ThemeManager } from '../utils/ThemeManager';

@Component
export struct ChartConfigPage {
  @State chartType: ChartType = ChartType.BAR;
  @State chartName: string = '新图表';
  @State showLegend: boolean = true;
  @State showLabels: boolean = true;
  @State showGrid: boolean = true;
  @State showDataPoints: boolean = false;
  @State animation: boolean = true;
  @State theme: 'light' | 'dark' = ThemeManager.current;
  @State isDonut: boolean = false;
  @State recordData: string = '';
  @State dataModel: ChartDataModel | null = null;

  aboutToAppear(): void {
    const params = router.getParams();
    if (params?.recordData) {
      this.recordData = params.recordData as string;
      this.dataModel = ChartDataModel.fromJSON(this.recordData);
    }
    if (params?.recordName) {
      this.chartName = params.recordName as string;
    }
    if (params?.recordType) {
      this.chartType = params.recordType as ChartType;
    }
    if (params?.recordConfig) {
      const config = ChartConfig.fromJSON(params.recordConfig as string);
      this.showLegend = config.showLegend;
      this.showLabels = config.showLabels;
      this.showGrid = config.showGrid;
      this.showDataPoints = config.showDataPoints;
      this.animation = config.animation;
    }
  }

  onNext(): void {
    if (!this.dataModel) return;

    this.dataModel.title = this.chartName;
    this.dataModel.chartType = this.chartType;

    const config = new ChartConfig();
    config.showLegend = this.showLegend;
    config.showLabels = this.showLabels;
    config.showGrid = this.showGrid;
    config.showDataPoints = this.showDataPoints;
    config.animation = this.animation;
    config.theme = this.theme;

    const params = router.getParams();
    const recordId = params?.recordId || Date.now().toString();

    router.pushUrl({
      url: 'pages/ChartViewPage',
      params: {
        recordId: recordId,
        recordName: this.chartName,
        recordType: this.chartType,
        recordData: this.dataModel.toJSON(),
        recordConfig: config.toJSON(),
        isEdit: params?.isEdit || false
      }
    });
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(28)
          .height(28)
          .onClick(() => router.back())

        Text('图表配置')
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

      Scroll() {
        Column() {
          // 图表名称
          Column() {
            Text('图表名称')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')
              .margin({ left: 16, top: 16 })

            TextInput({ placeholder: '请输入图表名称', text: this.chartName })
              .width('90%')
              .height(44)
              .fontSize(16)
              .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#FFFFFF')
              .border({ width: 1, color: this.theme === 'dark' ? '#333333' : '#E8E8E8' })
              .borderRadius(8)
              .padding({ left: 12 })
              .margin({ left: 16, top: 8 })
              .onChange((value: string) => this.chartName = value)
          }

          // 图表类型
          Column() {
            Text('图表类型')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')
              .margin({ left: 16, top: 16 })

            Row() {
              ForEach([
                { type: ChartType.BAR, icon: '📊', name: '柱状图' },
                { type: ChartType.LINE, icon: '📈', name: '折线图' },
                { type: ChartType.PIE, icon: '🍩', name: '饼图' },
                { type: ChartType.SCATTER, icon: '💎', name: '散点图' },
                { type: ChartType.RADAR, icon: '🎯', name: '雷达图' },
                { type: ChartType.AREA, icon: '📐', name: '面积图' }
              ], (item) => {
                Column() {
                  Text(item.icon)
                    .fontSize(32)
                    .margin({ top: 8 })

                  Text(item.name)
                    .fontSize(12)
                    .fontColor(this.chartType === item.type ? '#5B8FF9' : '#999999')
                    .margin({ top: 4 })
                }
                .width(90)
                .height(80)
                .borderRadius(8)
                .border({ width: 1, color: this.chartType === item.type ? '#5B8FF9' : 'transparent' })
                .backgroundColor(this.chartType === item.type ? 'rgba(91,143,249,0.1)' : 'transparent')
                .onClick(() => this.chartType = item.type)
              }, (item) => item.type)
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
          }

          // 饼图子选项
          if (this.chartType === ChartType.PIE) {
            Row() {
              Text('环形图')
                .fontSize(14)
                .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')

              Spacer()

              Toggle({ type: ToggleType.Switch, isOn: this.isDonut })
                .onChange((isOn: boolean) => this.isDonut = isOn)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8 })
          }

          // 显示选项
          Column() {
            Text('显示选项')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')
              .margin({ left: 16, top: 16 })

            Row() {
              Text('显示图例')
                .fontSize(14)
                .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')

              Spacer()

              Toggle({ type: ToggleType.Switch, isOn: this.showLegend })
                .onChange((isOn: boolean) => this.showLegend = isOn)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8 })

            Row() {
              Text('显示数据标签')
                .fontSize(14)
                .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')

              Spacer()

              Toggle({ type: ToggleType.Switch, isOn: this.showLabels })
                .onChange((isOn: boolean) => this.showLabels = isOn)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8 })

            Row() {
              Text('显示网格线')
                .fontSize(14)
                .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')

              Spacer()

              Toggle({ type: ToggleType.Switch, isOn: this.showGrid })
                .onChange((isOn: boolean) => this.showGrid = isOn)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8 })

            Row() {
              Text('显示数据点')
                .fontSize(14)
                .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')

              Spacer()

              Toggle({ type: ToggleType.Switch, isOn: this.showDataPoints })
                .onChange((isOn: boolean) => this.showDataPoints = isOn)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8 })

            Row() {
              Text('动画效果')
                .fontSize(14)
                .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')

              Spacer()

              Toggle({ type: ToggleType.Switch, isOn: this.animation })
                .onChange((isOn: boolean) => this.animation = isOn)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8 })
          }

          // 颜色方案预览
          Column() {
            Text('颜色方案')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.theme === 'dark' ? '#FFFFFF' : '#1A1A1A')
              .margin({ left: 16, top: 16 })

            Row() {
              ForEach(['#5B8FF9', '#5AD8A6', '#FF6B6B', '#FFD93D', '#6BCB77', '#4ECDC4'], (color) => {
                Stack() {
                  Circle()
                    .width(30)
                    .height(30)
                    .backgroundColor(color)
                    .borderRadius(15)
                }
                .margin({ left: 8 })
              }, (color) => color)
            }
            .padding({ left: 16, top: 8 })
          }
        }
      }
      .width('100%')
      .flex(1)

      // 底部
      Row() {
        Spacer()

        Button('预览图表')
          .onClick(() => this.onNext())
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
}
