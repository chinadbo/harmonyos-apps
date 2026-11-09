import common from '@ohos.app.ability.common';
import { GachaRecord, GachaPool, DayGroup, STAR_GOLD, STAR_PURPLE, STAR_BLUE } from '../model/GachaModels';
import { GachaDb } from '../db/GachaDb';
import { colorsOf } from '../common/Theme';
import { RecordCard } from '../components/RecordCard';
import { NavBar } from '../components/NavBar';
import { formatThousands } from '../common/Format';

@Entry
@Component
struct RecordPage {
  @StorageLink("gachaTheme") themeNum: number = 0;
  @StorageLink("refreshFlag") @Watch('onRefresh') refreshFlag: number = 0;
  @State records: GachaRecord[] = [];
  @State pools: GachaPool[] = [];
  @State selPoolId: number = -1;
  @State selStar: number = 0;
  @State loaded: boolean = false;
  @State loadError: string = '';

  aboutToAppear(): void {
    this.reload();
  }

  onPageShow(): void {
    this.reload();
  }

  private onRefresh(): void {
    this.reload();
  }

  private async reload(): Promise<void> {
    try {
      const ctx = getContext(this) as common.Context;
      const db = await GachaDb.ensure(ctx);
      this.records = await db.getAllRecords();
      this.pools = await db.getPools();
      this.loadError = '';
    } catch (e) {
      this.loadError = '数据加载失败，请重试';
    }
    this.loaded = true;
  }

  private toast(msg: string): void {
    this.getUIContext().getPromptAction().showToast({ message: msg, duration: 2000 });
  }

  private poolNameOf(poolId: number): string {
    for (const p of this.pools) {
      if (p.id === poolId) {
        return p.name;
      }
    }
    return '未知卡池';
  }

  private filtered(): GachaRecord[] {
    let list = this.records;
    if (this.selPoolId !== -1) {
      list = list.filter((r: GachaRecord) => r.poolId === this.selPoolId);
    }
    if (this.selStar !== 0) {
      list = list.filter((r: GachaRecord) => r.star === this.selStar);
    }
    return list.slice().sort((a: GachaRecord, b: GachaRecord) => {
      if (a.recordDate !== b.recordDate) {
        return a.recordDate < b.recordDate ? 1 : -1;
      }
      return b.createdAt - a.createdAt;
    });
  }

  private grouped(): DayGroup[] {
    const list = this.filtered();
    const groups: DayGroup[] = [];
    for (const r of list) {
      let found: DayGroup | null = null;
      for (const g of groups) {
        if (g.date === r.recordDate) {
          found = g;
          break;
        }
      }
      if (found === null) {
        const g = new DayGroup();
        g.date = r.recordDate;
        g.items.push(r);
        groups.push(g);
      } else {
        found.items.push(r);
      }
    }
    return groups;
  }

  private confirmDelete(rec: GachaRecord): void {
    AlertDialog.show({
      title: '删除记录',
      message: `确认删除「${rec.itemName}」（${rec.recordDate}）？删除后不可恢复。`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: colorsOf(this.themeNum).danger,
        action: () => {
          this.doDelete(rec.id);
        }
      }
    });
  }

  private async doDelete(recordId: number): Promise<void> {
    try {
      const ctx = getContext(this) as common.Context;
      const db = await GachaDb.ensure(ctx);
      await db.deleteRecord(recordId);
      this.refreshFlag = this.refreshFlag + 1;
    } catch (e) {
      this.toast('删除失败，请重试');
    }
    this.reload();
  }

  build() {
    Column() {
      Column({ space: 8 }) {
        Row() {
          Text('抽卡记录')
            .fontSize(20)
            .fontWeight(800)
            .fontColor(colorsOf(this.themeNum).textMain)
          Blank()
          Text(`共 ${formatThousands(this.filtered().length)} 条`)
            .fontSize(11)
            .fontColor(colorsOf(this.themeNum).textSub)
        }
        .width('100%')

        Scroll() {
          Row({ space: 8 }) {
            Text('全部池')
              .fontSize(12)
              .fontColor(this.selPoolId === -1 ? colorsOf(this.themeNum).bg : colorsOf(this.themeNum).textSub)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(14)
              .backgroundColor(this.selPoolId === -1 ? colorsOf(this.themeNum).primary : colorsOf(this.themeNum).cardDeep)
              .onClick(() => {
                this.selPoolId = -1;
              })
            ForEach(this.pools, (p: GachaPool) => {
              Text(p.name)
                .fontSize(12)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontColor(this.selPoolId === p.id ? colorsOf(this.themeNum).bg : colorsOf(this.themeNum).textSub)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(14)
                .constraintSize({ maxWidth: 160 })
                .backgroundColor(this.selPoolId === p.id ? colorsOf(this.themeNum).primary : colorsOf(this.themeNum).cardDeep)
                .onClick(() => {
                  this.selPoolId = p.id;
                })
            }, (p: GachaPool) => `chip-${p.id}-${p.name}`)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        Row({ space: 8 }) {
          Text('全部')
            .fontSize(12)
            .fontColor(this.selStar === 0 ? colorsOf(this.themeNum).bg : colorsOf(this.themeNum).textSub)
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .borderRadius(12)
            .backgroundColor(this.selStar === 0 ? colorsOf(this.themeNum).primary : colorsOf(this.themeNum).cardDeep)
            .onClick(() => {
              this.selStar = 0;
            })
          Text('金 5')
            .fontSize(12)
            .fontColor(this.selStar === STAR_GOLD ? colorsOf(this.themeNum).bg : colorsOf(this.themeNum).gold)
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .borderRadius(12)
            .backgroundColor(this.selStar === STAR_GOLD ? colorsOf(this.themeNum).gold : colorsOf(this.themeNum).cardDeep)
            .onClick(() => {
              this.selStar = STAR_GOLD;
            })
          Text('紫 4')
            .fontSize(12)
            .fontColor(this.selStar === STAR_PURPLE ? colorsOf(this.themeNum).bg : colorsOf(this.themeNum).purple)
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .borderRadius(12)
            .backgroundColor(this.selStar === STAR_PURPLE ? colorsOf(this.themeNum).purple : colorsOf(this.themeNum).cardDeep)
            .onClick(() => {
              this.selStar = STAR_PURPLE;
            })
          Text('蓝 3')
            .fontSize(12)
            .fontColor(this.selStar === STAR_BLUE ? colorsOf(this.themeNum).bg : colorsOf(this.themeNum).blue)
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .borderRadius(12)
            .backgroundColor(this.selStar === STAR_BLUE ? colorsOf(this.themeNum).blue : colorsOf(this.themeNum).cardDeep)
            .onClick(() => {
              this.selStar = STAR_BLUE;
            })
        }
        .width('100%')
      }
      .padding({ left: 16, right: 16, top: 14, bottom: 10 })
      .width('100%')

      Scroll() {
        Column({ space: 14 }) {
          if (this.loadError.length > 0) {
            Row({ space: 10 }) {
              Text(this.loadError)
                .fontSize(12)
                .fontColor(colorsOf(this.themeNum).danger)
                .layoutWeight(1)
              Text('重试')
                .fontSize(12)
                .fontWeight(700)
                .fontColor(colorsOf(this.themeNum).bg)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .borderRadius(10)
                .backgroundColor(colorsOf(this.themeNum).primary)
                .onClick(() => {
                  this.reload();
                })
            }
            .width('100%')
            .padding(12)
            .borderRadius(12)
            .backgroundColor(colorsOf(this.themeNum).card)
            .border({ width: 1, color: colorsOf(this.themeNum).danger })
          }

          if (this.filtered().length === 0) {
            Column({ space: 10 }) {
              Text('◌')
                .fontSize(48)
                .fontColor(colorsOf(this.themeNum).textSub)
              if (this.records.length === 0) {
                Text('暂无抽卡记录')
                  .fontSize(15)
                  .fontWeight(600)
                  .fontColor(colorsOf(this.themeNum).textSub)
                Text('点击底部「录入」添加第一条记录，或使用批量粘贴导入')
                  .fontSize(11)
                  .fontColor(colorsOf(this.themeNum).textSub)
              } else {
                Text('当前筛选条件下没有记录')
                  .fontSize(15)
                  .fontWeight(600)
                  .fontColor(colorsOf(this.themeNum).textSub)
                Text('试试切换卡池或星级筛选')
                  .fontSize(11)
                  .fontColor(colorsOf(this.themeNum).textSub)
              }
            }
            .width('100%')
            .padding({ top: 80, bottom: 80 })
            .justifyContent(FlexAlign.Center)
          } else {
            ForEach(this.grouped(), (group: DayGroup) => {
              Column({ space: 8 }) {
                Row({ space: 8 }) {
                  Circle()
                    .width(8)
                    .height(8)
                    .fill(colorsOf(this.themeNum).primary)
                  Text(group.date)
                    .fontSize(13)
                    .fontWeight(700)
                    .fontColor(colorsOf(this.themeNum).textSub)
                  Blank()
                  Text(`${group.items.length} 抽`)
                    .fontSize(11)
                    .fontColor(colorsOf(this.themeNum).textSub)
                }
                .width('100%')

                Column({ space: 6 }) {
                  ForEach(group.items, (rec: GachaRecord) => {
                    RecordCard({
                      itemName: rec.itemName,
                      star: rec.star,
                      poolName: this.poolNameOf(rec.poolId),
                      dateStr: rec.recordDate,
                      pullNo: rec.pullNo,
                      goldColor: colorsOf(this.themeNum).gold,
                      purpleColor: colorsOf(this.themeNum).purple,
                      blueColor: colorsOf(this.themeNum).blue,
                      cardColor: colorsOf(this.themeNum).card,
                      border: colorsOf(this.themeNum).border,
                      textMain: colorsOf(this.themeNum).textMain,
                      textSub: colorsOf(this.themeNum).textSub
                    })
                    .onLongPress(() => {
                      this.confirmDelete(rec);
                    })
                  }, (rec: GachaRecord) => `rec-${rec.id}`)
                }
                .width('100%')

                Divider().color(colorsOf(this.themeNum).border).opacity(0.5)
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
              .alignItems(HorizontalAlign.Start)
            }, (group: DayGroup) => `day-${group.date}`)
          }
        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .width('100%')

      if (!this.loaded) {
        Text('加载中...')
          .fontSize(12)
          .fontColor(colorsOf(this.themeNum).textSub)
          .padding(8)
      }

      NavBar({ active: 1 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colorsOf(this.themeNum).bg)
  }
}
