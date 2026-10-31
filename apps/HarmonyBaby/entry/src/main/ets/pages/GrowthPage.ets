import { DatabaseHelper } from '../database/DatabaseHelper';
import { GrowthRecord } from '../model/Models';
import { Theme } from '../utils/Theme';
import { TimeUtils } from '../utils/TimeUtils';
import { StatChart } from '../components/StatChart';

/**
 * 成长页：体重/身高/头围录入 + Canvas 成长曲线 + 记录列表
 */
@Component
export struct GrowthPage {
  @StorageLink('dataVersion') @Watch('onReload') dataVersion: number = 0;
  @State weightText: string = '';
  @State heightText: string = '';
  @State headCircText: string = '';
  @State records: GrowthRecord[] = [];
  @State weightValues: number[] = [];
  @State heightValues: number[] = [];
  @State chartLabels: string[] = [];
  @State latestWeight: number = 0;
  @State latestHeight: number = 0;
  @State latestHeadCirc: number = 0;

  aboutToAppear(): void {
    this.loadAll();
  }

  onReload(): void {
    this.loadAll();
  }

  private async loadAll(): Promise<void> {
    try {
      const list = await DatabaseHelper.getInstance().queryAllGrowth();
      this.records = list;
      this.rebuildChart();
    } catch (e) {
      console.error('GrowthPage loadAll failed: ' + e);
    }
  }

  private rebuildChart(): void {
    const weights: number[] = [];
    const heights: number[] = [];
    const labels: string[] = [];
    const list = this.records;
    let labelSkip = 1;
    if (list.length > 8) {
      labelSkip = Math.ceil(list.length / 8);
    }
    for (let i = 0; i < list.length; i++) {
      const r = list[i];
      weights.push(r.weight);
      heights.push(r.height);
      if (i % labelSkip === 0 || i === list.length - 1) {
        labels.push(TimeUtils.formatMonthDay(r.measureTime));
      } else {
        labels.push('');
      }
    }
    this.weightValues = weights;
    this.heightValues = heights;
    this.chartLabels = labels;
    if (list.length > 0) {
      const last = list[list.length - 1];
      this.latestWeight = last.weight;
      this.latestHeight = last.height;
      this.latestHeadCirc = last.headCirc;
    }
  }

  private weightTrendText(): string {
    if (this.records.length < 2) {
      return ' ';
    }
    const diff = this.records[this.records.length - 1].weight - this.records[this.records.length - 2].weight;
    if (diff > 0) {
      return '较上次 +' + diff.toFixed(2) + ' kg';
    }
    if (diff < 0) {
      return '较上次 ' + diff.toFixed(2) + ' kg';
    }
    return '与上次持平';
  }

  private parsePositive(text: string): number {
    const v = parseFloat(text.trim());
    if (isNaN(v) || v <= 0) {
      return -1;
    }
    return v;
  }

  private async save(): Promise<void> {
    const weight = this.parsePositive(this.weightText);
    const height = this.parsePositive(this.heightText);
    const headCirc = this.parsePositive(this.headCircText);
    if (weight < 0 && height < 0 && headCirc < 0) {
      return;
    }
    const r = new GrowthRecord();
    r.measureTime = Date.now();
    r.weight = weight > 0 ? weight : 0;
    r.height = height > 0 ? height : 0;
    r.headCirc = headCirc > 0 ? headCirc : 0;
    r.note = '';
    await DatabaseHelper.getInstance().insertGrowth(r);
    this.weightText = '';
    this.heightText = '';
    this.headCircText = '';
    this.dataVersion++;
  }

  private async deleteRecord(id: number): Promise<void> {
    await DatabaseHelper.getInstance().deleteGrowth(id);
    this.dataVersion++;
  }

  private growthSubtitle(r: GrowthRecord): string {
    let sub = '';
    if (r.weight > 0) {
      sub = r.weight + ' kg';
    }
    if (r.height > 0) {
      sub = sub.length > 0 ? sub + ' · ' + r.height + ' cm' : r.height + ' cm';
    }
    if (r.headCirc > 0) {
      sub = sub.length > 0 ? sub + ' · 头围' + r.headCirc + ' cm' : '头围' + r.headCirc + ' cm';
    }
    if (sub.length === 0) {
      sub = '已记录';
    }
    return sub;
  }

  build() {
    Scroll() {
      Column() {
        // 录入卡片
        Column() {
          Row() {
            Text('📏')
              .fontSize(24)
            Text('成长记录')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.TEXT)
              .margin({ left: 8 })
            Blank()
            Text('体重 kg · 身高 cm · 头围 cm')
              .fontSize(11)
              .fontColor(Theme.TEXT_LIGHT)
          }
          .width('100%')

          Row() {
            TextInput({ placeholder: '体重(kg)' })
              .type(InputType.Number)
              .height(42)
              .fontSize(14)
              .backgroundColor(Theme.GRAY_BG)
              .layoutWeight(1)
              .onChange((value: string) => {
                this.weightText = value;
              })
            TextInput({ placeholder: '身高(cm)' })
              .type(InputType.Number)
              .height(42)
              .fontSize(14)
              .backgroundColor(Theme.GRAY_BG)
              .layoutWeight(1)
              .margin({ left: 8 })
              .onChange((value: string) => {
                this.heightText = value;
              })
            TextInput({ placeholder: '头围(cm)' })
              .type(InputType.Number)
              .height(42)
              .fontSize(14)
              .backgroundColor(Theme.GRAY_BG)
              .layoutWeight(1)
              .margin({ left: 8 })
              .onChange((value: string) => {
                this.headCircText = value;
              })
          }
          .width('100%')
          .margin({ top: 12 })

          Button('记录一次测量')
            .width('100%')
            .height(42)
            .fontSize(15)
            .backgroundColor(Theme.GREEN)
            .margin({ top: 12 })
            .onClick(() => {
              this.save();
            })
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.CARD)
        .borderRadius(16)

        // 体重曲线
        Row() {
          Text('体重曲线')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
          Blank()
          Text(this.weightTrendText())
            .fontSize(12)
            .fontColor(Theme.TEXT_SUB)
        }
        .width('100%')
        .margin({ top: 20, bottom: 10 })

        Column() {
          Row() {
            Text(this.latestWeight > 0 ? this.latestWeight + ' kg' : '暂无')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.GREEN)
            Blank()
            Text(this.records.length + ' 次测量')
              .fontSize(12)
              .fontColor(Theme.TEXT_LIGHT)
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 12 })

          StatChart({
            values: this.weightValues,
            labels: this.chartLabels,
            mode: 'line',
            chartColor: Theme.GREEN,
            unit: '',
            decimals: 1
          })
        }
        .width('100%')
        .backgroundColor(Theme.CARD)
        .borderRadius(16)

        // 身高曲线
        Row() {
          Text('身高曲线')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
          Blank()
          Text(this.latestHeight > 0 ? this.latestHeight + ' cm' : '暂无')
            .fontSize(12)
            .fontColor(Theme.TEXT_SUB)
        }
        .width('100%')
        .margin({ top: 20, bottom: 10 })

        Column() {
          StatChart({
            values: this.heightValues,
            labels: this.chartLabels,
            mode: 'line',
            chartColor: Theme.BLUE,
            unit: '',
            decimals: 1
          })
        }
        .width('100%')
        .backgroundColor(Theme.CARD)
        .borderRadius(16)

        // 记录列表
        Row() {
          Text('测量记录')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
          Blank()
          if (this.latestHeadCirc > 0) {
            Text('头围 ' + this.latestHeadCirc + 'cm')
              .fontSize(12)
              .fontColor(Theme.TEXT_SUB)
          }
        }
        .width('100%')
        .margin({ top: 20, bottom: 10 })

        if (this.records.length === 0) {
          Text('还没有测量记录，输入体重或身高开始第一条曲线')
            .fontSize(13)
            .fontColor(Theme.TEXT_LIGHT)
            .margin({ top: 24, bottom: 24 })
        } else {
          List() {
            ForEach(this.records.slice().reverse(), (r: GrowthRecord) => {
              ListItem() {
                Row() {
                  Text('📏')
                    .fontSize(22)
                    .width(40)
                    .height(40)
                    .textAlign(TextAlign.Center)
                    .borderRadius(12)
                    .backgroundColor(Theme.GRAY_BG)
                  Column() {
                    Text(TimeUtils.formatDate(r.measureTime))
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.TEXT)
                    Text(this.growthSubtitle(r))
                      .fontSize(12)
                      .fontColor(Theme.TEXT_SUB)
                      .margin({ top: 2 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 12 })

                  Text('✕')
                    .fontSize(14)
                    .fontColor(Theme.TEXT_LIGHT)
                    .width(32)
                    .height(32)
                    .textAlign(TextAlign.Center)
                    .onClick(() => {
                      this.deleteRecord(r.id);
                    })
                }
                .width('100%')
                .padding(10)
                .backgroundColor(Theme.CARD)
                .borderRadius(14)
              }
              .margin({ bottom: 8 })
            }, (r: GrowthRecord) => r.id.toString() + r.measureTime.toString())
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }
}
