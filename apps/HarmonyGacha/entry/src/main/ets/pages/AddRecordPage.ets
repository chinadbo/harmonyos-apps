import common from '@ohos.app.ability.common';
import { GachaPool, STAR_GOLD, STAR_PURPLE, STAR_BLUE } from '../model/GachaModels';
import { GachaDb } from '../db/GachaDb';
import { colorsOf } from '../common/Theme';
import { NavBar } from '../components/NavBar';
import { ParsedRow, parseText, parseSummary } from '../parser/LogParser';
import { todayStr, dateToString } from '../common/Format';

@Entry
@Component
struct AddRecordPage {
  @StorageLink("gachaTheme") themeNum: number = 0;
  @StorageLink("refreshFlag") refreshFlag: number = 0;
  @State pools: GachaPool[] = [];
  @State mode: number = 0;
  @State poolIdx: number = 0;
  @State star: number = STAR_GOLD;
  @State itemName: string = '';
  @State pullNo: string = '';
  @State dateStr: string = todayStr();
  @State showDatePicker: boolean = false;
  @State tempDate: Date = new Date();
  @State batchText: string = '';
  @State previewRows: ParsedRow[] = [];
  @State previewDone: boolean = false;
  @State previewMsg: string = '';
  @State busy: boolean = false;
  @State loadError: string = '';

  aboutToAppear(): void {
    this.reload();
  }

  private async reload(): Promise<void> {
    try {
      const ctx = getContext(this) as common.Context;
      const db = await GachaDb.ensure(ctx);
      this.pools = await db.getPools();
      if (this.poolIdx >= this.pools.length) {
        for (let i = 0; i < this.pools.length; i++) {
          if (this.pools[i].isCurrent) {
            this.poolIdx = i;
            break;
          }
        }
        if (this.poolIdx >= this.pools.length && this.pools.length > 0) {
          this.poolIdx = 0;
        }
      }
      this.loadError = '';
    } catch (e) {
      this.loadError = '卡池加载失败，请重试';
    }
  }

  private currentPool(): GachaPool | null {
    if (this.poolIdx >= 0 && this.poolIdx < this.pools.length) {
      return this.pools[this.poolIdx];
    }
    return null;
  }

  private toast(msg: string): void {
    this.getUIContext().getPromptAction().showToast({ message: msg, duration: 2000 });
  }

  private poolOptions(): SelectOption[] {
    const opts: SelectOption[] = [];
    for (const p of this.pools) {
      const label = p.upName.length > 0 ? `${p.name}（UP:${p.upName}）` : p.name;
      const opt: SelectOption = { value: label };
      opts.push(opt);
    }
    return opts;
  }

  private async submitSingle(): Promise<void> {
    const name = this.itemName.trim();
    if (name.length === 0) {
      AlertDialog.show({
        title: '提示',
        message: '请填写物品名称',
        primaryButton: {
          value: '知道了',
          action: () => {
          }
        }
      });
      return;
    }
    const pool = this.currentPool();
    if (pool === null) {
      this.toast('暂无可用卡池，请先在「卡池」页添加');
      return;
    }
    let pull = 0;
    if (this.pullNo.trim().length > 0) {
      pull = parseInt(this.pullNo.trim());
      if (isNaN(pull) || pull < 0) {
        pull = 0;
      }
    }
    const date = this.dateStr.length > 0 ? this.dateStr : todayStr();
    const ctx = getContext(this) as common.Context;
    const db = await GachaDb.ensure(ctx);
    try {
      await db.insertRecord(pool.id, this.star, name, pull, date);
      this.refreshFlag = this.refreshFlag + 1;
      this.toast(`已记录「${name}」`);
      this.itemName = '';
      this.pullNo = '';
    } catch (e) {
      this.toast('保存失败，请重试');
    }
  }

  private doParse(): void {
    const text = this.batchText.trim();
    if (text.length === 0) {
      this.toast('请先粘贴抽卡记录文本');
      return;
    }
    this.previewRows = parseText(text);
    this.previewMsg = parseSummary(this.previewRows);
    this.previewDone = true;
  }

  private matchPool(row: ParsedRow): GachaPool | null {
    const poolName = row.poolName;
    if (poolName.length > 0) {
      for (const p of this.pools) {
        if (p.name === poolName || p.name.indexOf(poolName) >= 0 || poolName.indexOf(p.name) >= 0) {
          return p;
        }
        if (p.upName.length > 0 && (p.upName === row.itemName || poolName === p.upName)) {
          return p;
        }
      }
      if (row.poolType >= 0) {
        for (const p of this.pools) {
          if (p.poolType === row.poolType) {
            return p;
          }
        }
      }
    }
    const cur = this.currentPool();
    if (cur !== null) {
      return cur;
    }
    if (this.pools.length > 0) {
      return this.pools[0];
    }
    return null;
  }

  private async importBatch(): Promise<void> {
    const rows = this.previewRows.filter((r: ParsedRow) => r.valid);
    if (rows.length === 0) {
      this.toast('没有可导入的有效记录');
      return;
    }
    if (this.busy) {
      return;
    }
    this.busy = true;
    const ctx = getContext(this) as common.Context;
    const db = await GachaDb.ensure(ctx);
    const today = todayStr();
    let count = 0;
    try {
      for (const row of rows) {
        const pool = this.matchPool(row);
        if (pool === null) {
          continue;
        }
        const date = row.dateStr.length > 0 ? row.dateStr : today;
        await db.insertRecord(pool.id, row.star, row.itemName, row.pullNo, date);
        count++;
      }
      this.refreshFlag = this.refreshFlag + 1;
      this.previewRows = [];
      this.previewDone = false;
      this.batchText = '';
      this.previewMsg = '';
      this.toast(`已导入 ${count} 条记录`);
    } catch (e) {
      this.toast('导入失败，请重试');
    }
    this.busy = false;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Scroll() {
          Column({ space: 14 }) {
            Column({ space: 12 }) {
              Text('录入记录')
                .fontSize(20)
                .fontWeight(800)
                .fontColor(colorsOf(this.themeNum).textMain)
                .width('100%')

              Row({ space: 0 }) {
                Text('单条录入')
                  .fontSize(13)
                  .fontWeight(this.mode === 0 ? 700 : 400)
                  .fontColor(this.mode === 0 ? colorsOf(this.themeNum).bg : colorsOf(this.themeNum).textSub)
                  .padding({ left: 20, right: 20, top: 8, bottom: 8 })
                  .borderRadius({ topLeft: 10, bottomLeft: 10 })
                  .backgroundColor(this.mode === 0 ? colorsOf(this.themeNum).primary : colorsOf(this.themeNum).cardDeep)
                  .onClick(() => {
                    this.mode = 0;
                  })
                Text('批量粘贴')
                  .fontSize(13)
                  .fontWeight(this.mode === 1 ? 700 : 400)
                  .fontColor(this.mode === 1 ? colorsOf(this.themeNum).bg : colorsOf(this.themeNum).textSub)
                  .padding({ left: 20, right: 20, top: 8, bottom: 8 })
                  .borderRadius({ topRight: 10, bottomRight: 10 })
                  .backgroundColor(this.mode === 1 ? colorsOf(this.themeNum).primary : colorsOf(this.themeNum).cardDeep)
                  .onClick(() => {
                    this.mode = 1;
                  })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
            .padding({ left: 16, right: 16, top: 14 })
            .width('100%')

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
              .margin({ left: 16, right: 16 })
            }

            if (this.mode === 0) {
              this.singleForm()
            } else {
              this.batchForm()
            }
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .width('100%')

        NavBar({ active: 2 })
      }
      .width('100%')
      .height('100%')

      if (this.showDatePicker) {
        this.datePickerOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colorsOf(this.themeNum).bg)
  }

  @Builder
  private singleForm() {
    Column({ space: 12 }) {
      Column({ space: 8 }) {
        Text('卡池')
          .fontSize(12)
          .fontColor(colorsOf(this.themeNum).textSub)
          .width('100%')
        Select(this.poolOptions())
          .selected(this.poolIdx)
          .value(this.poolIdx < this.pools.length ? this.pools[this.poolIdx].name : '选择卡池')
          .fontColor(colorsOf(this.themeNum).textMain)
          .font({ size: 14 })
          .selectedOptionFont({ size: 14 })
          .optionFont({ size: 14 })
          .onSelect((idx: number) => {
            this.poolIdx = idx;
          })
          .width('100%')
      }
      .width('100%')

      Column({ space: 8 }) {
        Text('星级')
          .fontSize(12)
          .fontColor(colorsOf(this.themeNum).textSub)
          .width('100%')
        Row({ space: 8 }) {
          Text('5 金')
            .fontSize(14)
            .fontWeight(700)
            .fontColor(this.star === STAR_GOLD ? colorsOf(this.themeNum).bg : colorsOf(this.themeNum).gold)
            .padding({ left: 22, right: 22, top: 8, bottom: 8 })
            .borderRadius(10)
            .backgroundColor(this.star === STAR_GOLD ? colorsOf(this.themeNum).gold : colorsOf(this.themeNum).cardDeep)
            .onClick(() => {
              this.star = STAR_GOLD;
            })
          Text('4 紫')
            .fontSize(14)
            .fontWeight(700)
            .fontColor(this.star === STAR_PURPLE ? colorsOf(this.themeNum).bg : colorsOf(this.themeNum).purple)
            .padding({ left: 22, right: 22, top: 8, bottom: 8 })
            .borderRadius(10)
            .backgroundColor(this.star === STAR_PURPLE ? colorsOf(this.themeNum).purple : colorsOf(this.themeNum).cardDeep)
            .onClick(() => {
              this.star = STAR_PURPLE;
            })
          Text('3 蓝')
            .fontSize(14)
            .fontWeight(700)
            .fontColor(this.star === STAR_BLUE ? colorsOf(this.themeNum).bg : colorsOf(this.themeNum).blue)
            .padding({ left: 22, right: 22, top: 8, bottom: 8 })
            .borderRadius(10)
            .backgroundColor(this.star === STAR_BLUE ? colorsOf(this.themeNum).blue : colorsOf(this.themeNum).cardDeep)
            .onClick(() => {
              this.star = STAR_BLUE;
            })
        }
        .width('100%')
      }
      .width('100%')

      Column({ space: 8 }) {
        Text('物品名称')
          .fontSize(12)
          .fontColor(colorsOf(this.themeNum).textSub)
          .width('100%')
        TextInput({ placeholder: '例如：神里绫华', text: this.itemName })
          .placeholderColor(colorsOf(this.themeNum).textSub)
          .fontColor(colorsOf(this.themeNum).textMain)
          .backgroundColor(colorsOf(this.themeNum).cardDeep)
          .borderRadius(10)
          .onChange((v: string) => {
            this.itemName = v;
          })
          .width('100%')
      }
      .width('100%')

      Column({ space: 8 }) {
        Text('第几抽出金（选填，用于保底统计）')
          .fontSize(12)
          .fontColor(colorsOf(this.themeNum).textSub)
          .width('100%')
        TextInput({ placeholder: '例如：78', text: this.pullNo })
          .placeholderColor(colorsOf(this.themeNum).textSub)
          .fontColor(colorsOf(this.themeNum).textMain)
          .backgroundColor(colorsOf(this.themeNum).cardDeep)
          .borderRadius(10)
          .type(InputType.Number)
          .onChange((v: string) => {
            this.pullNo = v;
          })
          .width('100%')
      }
      .width('100%')

      Column({ space: 8 }) {
        Text('日期')
          .fontSize(12)
          .fontColor(colorsOf(this.themeNum).textSub)
          .width('100%')
        Row() {
          Text(this.dateStr)
            .fontSize(14)
            .fontColor(colorsOf(this.themeNum).textMain)
            .layoutWeight(1)
          Text('选择日期')
            .fontSize(13)
            .fontColor(colorsOf(this.themeNum).primary)
            .onClick(() => {
              const parts = this.dateStr.split('-');
              this.tempDate = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]));
              this.showDatePicker = true;
            })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .borderRadius(10)
        .backgroundColor(colorsOf(this.themeNum).cardDeep)
      }
      .width('100%')

      Button('保存记录')
        .fontSize(15)
        .fontWeight(700)
        .fontColor(colorsOf(this.themeNum).bg)
        .backgroundColor(colorsOf(this.themeNum).primary)
        .borderRadius(12)
        .height(44)
        .width('100%')
        .onClick(() => {
          this.submitSingle();
        })
    }
    .padding(16)
    .borderRadius(16)
    .backgroundColor(colorsOf(this.themeNum).card)
    .border({ width: 1, color: colorsOf(this.themeNum).border })
    .margin({ left: 16, right: 16, bottom: 20 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private batchForm() {
    Column({ space: 12 }) {
      Column({ space: 8 }) {
        Text('粘贴抽卡记录文本（每行一条）')
          .fontSize(12)
          .fontColor(colorsOf(this.themeNum).textSub)
          .width('100%')
        TextArea({ placeholder: '支持多种格式，例如：\n5星 神里绫华 第78抽 2026-01-05 角色池\n4星|祭礼残章|10|2026-01-06\n武器池 获得5星 若水 第2抽\n温迪,5,1,2023-04-06', text: this.batchText })
          .placeholderColor(colorsOf(this.themeNum).textSub)
          .fontColor(colorsOf(this.themeNum).textMain)
          .backgroundColor(colorsOf(this.themeNum).cardDeep)
          .borderRadius(10)
          .height(160)
          .onChange((v: string) => {
            this.batchText = v;
            this.previewDone = false;
            this.previewMsg = '';
          })
          .width('100%')
        Text('星级可写作 5星/五星/★5/金卡/SSR；日期可省略（默认今天）；卡池可省略（默认当前池）')
          .fontSize(10)
          .fontColor(colorsOf(this.themeNum).textSub)
          .width('100%')
      }
      .width('100%')

      Button('解析预览')
        .fontSize(15)
        .fontWeight(700)
        .fontColor(colorsOf(this.themeNum).bg)
        .backgroundColor(colorsOf(this.themeNum).primary)
        .borderRadius(12)
        .height(40)
        .width('100%')
        .onClick(() => {
          this.doParse();
        })

      if (this.previewDone) {
        Column({ space: 8 }) {
          Text('解析预览')
            .fontSize(13)
            .fontWeight(700)
            .fontColor(colorsOf(this.themeNum).textMain)
            .width('100%')
          Text(this.previewMsg)
            .fontSize(11)
            .fontColor(colorsOf(this.themeNum).textSub)
            .width('100%')

          if (this.previewRows.length === 0) {
            Text('没有解析到任何记录')
              .fontSize(12)
              .fontColor(colorsOf(this.themeNum).textSub)
              .width('100%')
          } else {
            Scroll() {
              Column({ space: 6 }) {
                ForEach(this.previewRows, (row: ParsedRow, idx: number) => {
                  this.previewRowCard(row, idx)
                }, (row: ParsedRow, idx: number) => `pv-${idx}-${row.itemName}`)
              }
              .width('100%')
            }
            .constrainSize({ maxHeight: 260 })
            .scrollBar(BarState.Auto)
            .width('100%')
          }

          if (this.previewRows.filter((r: ParsedRow) => r.valid).length > 0) {
            Button('确认入库')
              .fontSize(15)
              .fontWeight(700)
              .fontColor(colorsOf(this.themeNum).bg)
              .backgroundColor(colorsOf(this.themeNum).gold)
              .borderRadius(12)
              .height(40)
              .width('100%')
              .onClick(() => {
                this.importBatch();
              })
          }
        }
        .padding(12)
        .borderRadius(12)
        .backgroundColor(colorsOf(this.themeNum).cardDeep)
        .border({ width: 1, color: colorsOf(this.themeNum).border })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .padding(16)
    .borderRadius(16)
    .backgroundColor(colorsOf(this.themeNum).card)
    .border({ width: 1, color: colorsOf(this.themeNum).border })
    .margin({ left: 16, right: 16, bottom: 20 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private previewRowCard(row: ParsedRow, idx: number) {
    Row({ space: 10 }) {
      Text(row.valid ? `${row.star}` : '!')
        .fontSize(13)
        .fontWeight(800)
        .fontColor(row.valid ? (row.star === STAR_GOLD ? colorsOf(this.themeNum).gold :
          (row.star === STAR_PURPLE ? colorsOf(this.themeNum).purple : colorsOf(this.themeNum).blue)) : colorsOf(this.themeNum).danger)
        .width(24)

      Column({ space: 2 }) {
        Text(row.valid ? row.itemName : (row.itemName.length > 0 ? row.itemName : row.reason))
          .fontSize(13)
          .fontWeight(600)
          .fontColor(row.valid ? colorsOf(this.themeNum).textMain : colorsOf(this.themeNum).danger)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: 8 }) {
          if (row.poolName.length > 0) {
            Text(row.poolName)
              .fontSize(10)
              .fontColor(colorsOf(this.themeNum).textSub)
          }
          Text(row.dateStr)
            .fontSize(10)
            .fontColor(colorsOf(this.themeNum).textSub)
          if (row.pullNo > 0) {
            Text(`第${row.pullNo}抽`)
              .fontSize(10)
              .fontColor(colorsOf(this.themeNum).textSub)
          }
          if (!row.valid && row.itemName.length > 0) {
            Text(row.reason)
              .fontSize(10)
              .fontColor(colorsOf(this.themeNum).danger)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .borderRadius(8)
    .backgroundColor(colorsOf(this.themeNum).card)
    .border({ width: 1, color: row.valid ? colorsOf(this.themeNum).border : colorsOf(this.themeNum).danger })
  }

  @Builder
  private datePickerOverlay() {
    Column() {
      Column({ space: 12 }) {
        Text('选择日期')
          .fontSize(16)
          .fontWeight(700)
          .fontColor(colorsOf(this.themeNum).textMain)
        DatePicker({
          start: new Date(2020, 0, 1),
          end: new Date(),
          selected: this.tempDate
        })
          .onDateChange((value: Date) => {
            this.tempDate = value;
          })
          .backgroundColor(colorsOf(this.themeNum).card)
        Row({ space: 12 }) {
          Button('取消')
            .fontSize(14)
            .fontColor(colorsOf(this.themeNum).textSub)
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .onClick(() => {
              this.showDatePicker = false;
            })
          Button('确定')
            .fontSize(14)
            .fontWeight(700)
            .fontColor(colorsOf(this.themeNum).bg)
            .backgroundColor(colorsOf(this.themeNum).primary)
            .layoutWeight(1)
            .onClick(() => {
              this.dateStr = dateToString(this.tempDate);
              this.showDatePicker = false;
            })
        }
        .width('100%')
      }
      .padding(16)
      .borderRadius(16)
      .backgroundColor(colorsOf(this.themeNum).card)
      .border({ width: 1, color: colorsOf(this.themeNum).border })
      .width('88%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0,0,0,0.5)')
    .onClick(() => {
      this.showDatePicker = false;
    })
  }
}
