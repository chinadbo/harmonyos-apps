import common from '@ohos.app.ability.common';
import { GachaPool, POOL_CHAR, POOL_WEAPON, POOL_STANDARD, POOL_CUSTOM, poolTypeLabel } from '../model/GachaModels';
import { GachaDb } from '../db/GachaDb';
import { colorsOf } from '../common/Theme';
import { NavBar } from '../components/NavBar';
import { pityConfigOf } from '../engine/PityEngine';

@Entry
@Component
struct PoolPage {
  @StorageLink("gachaTheme") themeNum: number = 0;
  @StorageLink("refreshFlag") refreshFlag: number = 0;
  @State pools: GachaPool[] = [];
  @State recordCounts: Map<number, number> = new Map();
  @State showEdit: boolean = false;
  @State editId: number = 0;
  @State editName: string = '';
  @State editTypeIdx: number = 0;
  @State editUp: string = '';
  @State editStart: string = '';
  @State editEnd: string = '';
  @State editCurrent: boolean = false;
  @State loadError: string = '';

  private typeValues: number[] = [POOL_CHAR, POOL_WEAPON, POOL_STANDARD, POOL_CUSTOM];
  private typeNames: string[] = ['角色UP', '武器池', '标准池', '自定义'];

  aboutToAppear(): void {
    this.reload();
  }

  onPageShow(): void {
    this.reload();
  }

  private async reload(): Promise<void> {
    try {
      const ctx = getContext(this) as common.Context;
      const db = await GachaDb.ensure(ctx);
      this.pools = await db.getPools();
      const records = await db.getAllRecords();
      const counts = new Map<number, number>();
      for (const r of records) {
        const prev = counts.get(r.poolId);
        counts.set(r.poolId, (prev === undefined ? 0 : prev) + 1);
      }
      this.recordCounts = counts;
      this.loadError = '';
    } catch (e) {
      this.loadError = '数据加载失败，请重试';
    }
  }

  private toast(msg: string): void {
    this.getUIContext().getPromptAction().showToast({ message: msg, duration: 2000 });
  }

  private countOf(poolId: number): number {
    const v = this.recordCounts.get(poolId);
    return v === undefined ? 0 : v;
  }

  private openAdd(): void {
    this.editId = 0;
    this.editName = '';
    this.editTypeIdx = 0;
    this.editUp = '';
    this.editStart = '';
    this.editEnd = '';
    this.editCurrent = false;
    this.showEdit = true;
  }

  private openEdit(pool: GachaPool): void {
    this.editId = pool.id;
    this.editName = pool.name;
    this.editTypeIdx = this.typeValues.indexOf(pool.poolType);
    if (this.editTypeIdx < 0) {
      this.editTypeIdx = 3;
    }
    this.editUp = pool.upName;
    this.editStart = pool.startDate;
    this.editEnd = pool.endDate;
    this.editCurrent = pool.isCurrent;
    this.showEdit = true;
  }

  private async saveEdit(): Promise<void> {
    const name = this.editName.trim();
    if (name.length === 0) {
      this.toast('请填写卡池名称');
      return;
    }
    const ctx = getContext(this) as common.Context;
    const db = await GachaDb.ensure(ctx);
    const poolType = this.typeValues[this.editTypeIdx];
    try {
      if (this.editId === 0) {
        await db.addPool(name, poolType, this.editUp.trim(), this.editStart.trim(), this.editEnd.trim(), this.editCurrent);
        this.toast('已添加卡池');
      } else {
        const pool = new GachaPool();
        pool.id = this.editId;
        pool.name = name;
        pool.poolType = poolType;
        pool.upName = this.editUp.trim();
        pool.startDate = this.editStart.trim();
        pool.endDate = this.editEnd.trim();
        await db.updatePool(pool);
        if (this.editCurrent) {
          await db.setCurrentPool(this.editId);
        }
        this.toast('已保存修改');
      }
      this.showEdit = false;
      this.refreshFlag = this.refreshFlag + 1;
    } catch (e) {
      this.toast('保存失败，请重试');
    }
    this.reload();
  }

  private async switchCurrent(pool: GachaPool): Promise<void> {
    if (pool.isCurrent) {
      return;
    }
    const ctx = getContext(this) as common.Context;
    const db = await GachaDb.ensure(ctx);
    try {
      await db.setCurrentPool(pool.id);
      this.toast(`当前池切换为「${pool.name}」`);
      this.refreshFlag = this.refreshFlag + 1;
    } catch (e) {
      this.toast('切换失败，请重试');
    }
    this.reload();
  }

  private confirmDeletePool(pool: GachaPool): void {
    AlertDialog.show({
      title: '删除卡池',
      message: `将删除「${pool.name}」及其 ${this.countOf(pool.id)} 条抽卡记录，删除后不可恢复。`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: colorsOf(this.themeNum).danger,
        action: () => {
          this.doDeletePool(pool.id);
        }
      }
    });
  }

  private async doDeletePool(poolId: number): Promise<void> {
    try {
      const ctx = getContext(this) as common.Context;
      const db = await GachaDb.ensure(ctx);
      await db.deletePool(poolId);
      this.refreshFlag = this.refreshFlag + 1;
    } catch (e) {
      this.toast('删除失败，请重试');
    }
    this.reload();
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Scroll() {
          Column({ space: 14 }) {
            Row() {
              Column({ space: 2 }) {
                Text('卡池管理')
                  .fontSize(20)
                  .fontWeight(800)
                  .fontColor(colorsOf(this.themeNum).textMain)
                Text('点击卡池切换当前池；内置池不可删除')
                  .fontSize(11)
                  .fontColor(colorsOf(this.themeNum).textSub)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text('+ 新建')
                .fontSize(13)
                .fontWeight(700)
                .fontColor(colorsOf(this.themeNum).bg)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .borderRadius(10)
                .backgroundColor(colorsOf(this.themeNum).primary)
                .onClick(() => {
                  this.openAdd();
                })
            }
            .width('100%')
            .padding({ top: 14, left: 16, right: 16 })

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

            ForEach(this.pools, (pool: GachaPool) => {
              this.poolCard(pool)
            }, (pool: GachaPool) => `pool-${pool.id}-${pool.name}`)
          }
          .width('100%')
          .padding({ bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .width('100%')

        NavBar({ active: 4 })
      }
      .width('100%')
      .height('100%')

      if (this.showEdit) {
        Column() {
          this.editOverlay()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showEdit = false;
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colorsOf(this.themeNum).bg)
  }

  @Builder
  private poolCard(pool: GachaPool) {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        Column({ space: 4 }) {
          Row({ space: 6 }) {
            Text(pool.name)
              .fontSize(15)
              .fontWeight(700)
              .fontColor(colorsOf(this.themeNum).textMain)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(poolTypeLabel(pool.poolType))
              .fontSize(10)
              .fontColor(colorsOf(this.themeNum).primary)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
              .border({ width: 1, color: colorsOf(this.themeNum).primary })
            if (pool.builtin) {
              Text('内置')
                .fontSize(10)
                .fontColor(colorsOf(this.themeNum).textSub)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .border({ width: 1, color: colorsOf(this.themeNum).textSub })
            }
          }

          Row({ space: 10 }) {
            if (pool.upName.length > 0) {
              Text(`UP: ${pool.upName}`)
                .fontSize(11)
                .fontColor(colorsOf(this.themeNum).textSub)
            }
            Text(`${this.countOf(pool.id)} 抽记录`)
              .fontSize(11)
              .fontColor(colorsOf(this.themeNum).textSub)
            Text(`保底 ${pityConfigOf(pool.poolType).hardPity}`)
              .fontSize(11)
              .fontColor(colorsOf(this.themeNum).textSub)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(pool.isCurrent ? '当前池' : '设为当前')
          .fontSize(11)
          .fontWeight(600)
          .fontColor(pool.isCurrent ? colorsOf(this.themeNum).gold : colorsOf(this.themeNum).primary)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .borderRadius(10)
          .border({ width: 1, color: pool.isCurrent ? colorsOf(this.themeNum).gold : colorsOf(this.themeNum).primary })
          .onClick(() => {
            this.switchCurrent(pool);
          })
      }
      .width('100%')

      if (!pool.builtin) {
        Row({ space: 12 }) {
          Blank()
          Text('编辑')
            .fontSize(12)
            .fontColor(colorsOf(this.themeNum).textSub)
            .onClick(() => {
              this.openEdit(pool);
            })
          Text('删除')
            .fontSize(12)
            .fontColor(colorsOf(this.themeNum).danger)
            .onClick(() => {
              this.confirmDeletePool(pool);
            })
        }
        .width('100%')
      }
    }
    .padding(14)
    .borderRadius(14)
    .backgroundColor(colorsOf(this.themeNum).card)
    .border({
      width: 1,
      color: pool.isCurrent ? colorsOf(this.themeNum).primary : colorsOf(this.themeNum).border
    })
    .margin({ left: 16, right: 16 })
    .onClick(() => {
      this.switchCurrent(pool);
    })
  }

  @Builder
  private editOverlay() {
    Column() {
      Scroll() {
        Column({ space: 12 }) {
          Text(this.editId === 0 ? '新建卡池' : '编辑卡池')
            .fontSize(17)
            .fontWeight(800)
            .fontColor(colorsOf(this.themeNum).textMain)
            .width('100%')

          Column({ space: 6 }) {
            Text('名称')
              .fontSize(12)
              .fontColor(colorsOf(this.themeNum).textSub)
            TextInput({ placeholder: '例如：落霞孤鹜·角色UP', text: this.editName })
              .placeholderColor(colorsOf(this.themeNum).textSub)
              .fontColor(colorsOf(this.themeNum).textMain)
              .backgroundColor(colorsOf(this.themeNum).cardDeep)
              .borderRadius(10)
              .onChange((v: string) => {
                this.editName = v;
              })
              .width('100%')
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('类型')
              .fontSize(12)
              .fontColor(colorsOf(this.themeNum).textSub)
            Row({ space: 8 }) {
              ForEach(this.typeNames, (name: string, idx: number) => {
                Text(name)
                  .fontSize(12)
                  .fontColor(this.editTypeIdx === idx ? colorsOf(this.themeNum).bg : colorsOf(this.themeNum).textSub)
                  .padding({ left: 12, right: 12, top: 7, bottom: 7 })
                  .borderRadius(8)
                  .backgroundColor(this.editTypeIdx === idx ? colorsOf(this.themeNum).primary : colorsOf(this.themeNum).cardDeep)
                  .onClick(() => {
                    this.editTypeIdx = idx;
                  })
              }, (name: string) => `type-${name}`)
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('UP 角色/武器名（选填）')
              .fontSize(12)
              .fontColor(colorsOf(this.themeNum).textSub)
            TextInput({ placeholder: '例如：神里绫华', text: this.editUp })
              .placeholderColor(colorsOf(this.themeNum).textSub)
              .fontColor(colorsOf(this.themeNum).textMain)
              .backgroundColor(colorsOf(this.themeNum).cardDeep)
              .borderRadius(10)
              .onChange((v: string) => {
                this.editUp = v;
              })
              .width('100%')
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('开放日期（选填，YYYY-MM-DD）')
              .fontSize(12)
              .fontColor(colorsOf(this.themeNum).textSub)
            Row({ space: 8 }) {
              TextInput({ placeholder: '开始日期', text: this.editStart })
                .placeholderColor(colorsOf(this.themeNum).textSub)
                .fontColor(colorsOf(this.themeNum).textMain)
                .backgroundColor(colorsOf(this.themeNum).cardDeep)
                .borderRadius(10)
                .layoutWeight(1)
                .onChange((v: string) => {
                  this.editStart = v;
                })
              TextInput({ placeholder: '结束日期', text: this.editEnd })
                .placeholderColor(colorsOf(this.themeNum).textSub)
                .fontColor(colorsOf(this.themeNum).textMain)
                .backgroundColor(colorsOf(this.themeNum).cardDeep)
                .borderRadius(10)
                .layoutWeight(1)
                .onChange((v: string) => {
                  this.editEnd = v;
                })
            }
            .width('100%')
          }
          .width('100%')

          Row() {
            Text('保存后设为当前池')
              .fontSize(13)
              .fontColor(colorsOf(this.themeNum).textMain)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.editCurrent })
              .selectedColor(colorsOf(this.themeNum).primary)
              .onChange((on: boolean) => {
                this.editCurrent = on;
              })
          }
          .width('100%')

          Row({ space: 12 }) {
            Button('取消')
              .fontSize(14)
              .fontColor(colorsOf(this.themeNum).textSub)
              .backgroundColor(Color.Transparent)
              .borderRadius(10)
              .height(40)
              .layoutWeight(1)
              .onClick(() => {
                this.showEdit = false;
              })
            Button('保存')
              .fontSize(14)
              .fontWeight(700)
              .fontColor(colorsOf(this.themeNum).bg)
              .backgroundColor(colorsOf(this.themeNum).primary)
              .borderRadius(10)
              .height(40)
              .layoutWeight(1)
              .onClick(() => {
                this.saveEdit();
              })
          }
          .width('100%')
        }
        .width('100%')
      }
      .constrainSize({ maxHeight: 520 })
      .scrollBar(BarState.Auto)
      .width('100%')
    }
    .padding(16)
    .borderRadius(16)
    .backgroundColor(colorsOf(this.themeNum).card)
    .border({ width: 1, color: colorsOf(this.themeNum).border })
    .width('90%')
    .onClick(() => {
    })
  }
}
