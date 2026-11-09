import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import { GachaRecord, GachaPool } from '../model/GachaModels';
import { GachaDb } from '../db/GachaDb';
import { colorsOf, THEME_OPTIONS, saveThemePref, ThemeOption } from '../common/Theme';
import { NavBar } from '../components/NavBar';
import { timeStamp } from '../common/Format';

class ExportPayload {
  app: string = 'HarmonyGacha';
  version: string = '1.0.0';
  exportedAt: string = '';
  pools: GachaPool[] = [];
  records: GachaRecord[] = [];
}

@Entry
@Component
struct SettingsPage {
  @StorageLink("gachaTheme") @Watch('onThemeChange') themeNum: number = 0;
  @StorageLink("refreshFlag") refreshFlag: number = 0;
  @State exportPath: string = '';
  @State recordCount: number = 0;
  @State dbMode: string = '';
  @State loadError: string = '';

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
      const records = await db.getAllRecords();
      this.recordCount = records.length;
      this.dbMode = db.isMemoryMode() ? '当前为内存模式：RDB 初始化失败，数据不会持久化' : 'RDB 数据库正常';
      this.loadError = '';
    } catch (e) {
      this.loadError = '数据加载失败，请重试';
    }
  }

  private onThemeChange(): void {
    const ctx = getContext(this) as common.Context;
    saveThemePref(ctx, this.themeNum);
  }

  private toast(msg: string): void {
    this.getUIContext().getPromptAction().showToast({ message: msg, duration: 2500 });
  }

  private async doExport(): Promise<void> {
    const ctx = getContext(this) as common.Context;
    const db = await GachaDb.ensure(ctx);
    const payload = new ExportPayload();
    payload.exportedAt = new Date().toISOString();
    try {
      payload.pools = await db.getPools();
      payload.records = await db.getAllRecords();
    } catch (e) {
      AlertDialog.show({
        title: '导出失败',
        message: '读取数据失败，请稍后重试。',
        primaryButton: {
          value: '知道了',
          action: () => {
          }
        }
      });
      return;
    }
    const content = JSON.stringify(payload, null, 2);
    const path = `${ctx.cacheDir}/gacha_export_${timeStamp()}.json`;
    try {
      const file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      fs.writeSync(file.fd, content);
      fs.closeSync(file);
      this.exportPath = path;
      AlertDialog.show({
        title: '导出成功',
        message: `已导出 ${payload.records.length} 条记录、${payload.pools.length} 个卡池。\n文件位于应用缓存目录：\n${path}`,
        primaryButton: {
          value: '知道了',
          action: () => {
          }
        }
      });
    } catch (e) {
      AlertDialog.show({
        title: '导出失败',
        message: '写入文件失败，请检查应用存储空间后重试。',
        primaryButton: {
          value: '知道了',
          action: () => {
          }
        }
      });
    }
  }

  private confirmClear(): void {
    AlertDialog.show({
      title: '清空数据',
      message: `将删除全部 ${this.recordCount} 条抽卡记录（卡池保留）。此操作不可恢复，建议先导出。`,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '继续',
        fontColor: colorsOf(this.themeNum).danger,
        action: () => {
          this.confirmClearAgain();
        }
      }
    });
  }

  private confirmClearAgain(): void {
    AlertDialog.show({
      title: '再次确认',
      message: '确定要清空所有抽卡记录吗？删除后无法找回。',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '确认清空',
        fontColor: colorsOf(this.themeNum).danger,
        action: () => {
          this.doClear();
        }
      }
    });
  }

  private async doClear(): Promise<void> {
    try {
      const ctx = getContext(this) as common.Context;
      const db = await GachaDb.ensure(ctx);
      await db.clearRecords();
      this.refreshFlag = this.refreshFlag + 1;
      this.recordCount = 0;
      this.toast('已清空全部抽卡记录');
    } catch (e) {
      this.toast('清空失败，请重试');
    }
    this.reload();
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 14 }) {
          Text('设置')
            .fontSize(20)
            .fontWeight(800)
            .fontColor(colorsOf(this.themeNum).textMain)
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

          Column({ space: 10 }) {
            Text('主题')
              .fontSize(15)
              .fontWeight(700)
              .fontColor(colorsOf(this.themeNum).textMain)
              .width('100%')

            ForEach(THEME_OPTIONS, (opt: ThemeOption) => {
              Row({ space: 12 }) {
                Row()
                  .width(34)
                  .height(34)
                  .borderRadius(17)
                  .backgroundColor(opt.swatch)
                  .border({
                    width: 2,
                    color: this.themeNum === opt.value ? colorsOf(this.themeNum).textMain : colorsOf(this.themeNum).border
                  })

                Column({ space: 2 }) {
                  Text(opt.name)
                    .fontSize(14)
                    .fontWeight(600)
                    .fontColor(colorsOf(this.themeNum).textMain)
                  Text(opt.desc)
                    .fontSize(11)
                    .fontColor(colorsOf(this.themeNum).textSub)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                if (this.themeNum === opt.value) {
                  Text('使用中')
                    .fontSize(11)
                    .fontColor(colorsOf(this.themeNum).primary)
                }
              }
              .width('100%')
              .padding(12)
              .borderRadius(12)
              .backgroundColor(this.themeNum === opt.value ? colorsOf(this.themeNum).cardDeep : Color.Transparent)
              .border({
                width: 1,
                color: this.themeNum === opt.value ? colorsOf(this.themeNum).primary : colorsOf(this.themeNum).border
              })
              .onClick(() => {
                this.themeNum = opt.value;
              })
            }, (opt: ThemeOption) => `theme-${opt.value}`)
          }
          .padding(16)
          .borderRadius(16)
          .backgroundColor(colorsOf(this.themeNum).card)
          .border({ width: 1, color: colorsOf(this.themeNum).border })
          .margin({ left: 16, right: 16 })
          .alignItems(HorizontalAlign.Start)

          Column({ space: 10 }) {
            Text('数据')
              .fontSize(15)
              .fontWeight(700)
              .fontColor(colorsOf(this.themeNum).textMain)
              .width('100%')

            Row() {
              Column({ space: 2 }) {
                Text('导出全部记录')
                  .fontSize(14)
                  .fontWeight(600)
                  .fontColor(colorsOf(this.themeNum).textMain)
                Text(`JSON 格式，${this.recordCount} 条记录，写入应用缓存目录`)
                  .fontSize(11)
                  .fontColor(colorsOf(this.themeNum).textSub)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text('导出')
                .fontSize(13)
                .fontWeight(700)
                .fontColor(colorsOf(this.themeNum).bg)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .borderRadius(10)
                .backgroundColor(colorsOf(this.themeNum).primary)
                .onClick(() => {
                  this.doExport();
                })
            }
            .width('100%')

            if (this.exportPath.length > 0) {
              Text(`上次导出：${this.exportPath}`)
                .fontSize(10)
                .fontColor(colorsOf(this.themeNum).textSub)
                .width('100%')
            }

            Divider().color(colorsOf(this.themeNum).border).opacity(0.5)

            Row() {
              Column({ space: 2 }) {
                Text('清空抽卡记录')
                  .fontSize(14)
                  .fontWeight(600)
                  .fontColor(colorsOf(this.themeNum).danger)
                Text('删除全部记录（保留卡池配置），需二次确认')
                  .fontSize(11)
                  .fontColor(colorsOf(this.themeNum).textSub)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text('清空')
                .fontSize(13)
                .fontWeight(700)
                .fontColor(colorsOf(this.themeNum).bg)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .borderRadius(10)
                .backgroundColor(colorsOf(this.themeNum).danger)
                .onClick(() => {
                  this.confirmClear();
                })
            }
            .width('100%')
          }
          .padding(16)
          .borderRadius(16)
          .backgroundColor(colorsOf(this.themeNum).card)
          .border({ width: 1, color: colorsOf(this.themeNum).border })
          .margin({ left: 16, right: 16 })
          .alignItems(HorizontalAlign.Start)

          Column({ space: 8 }) {
            Text('关于')
              .fontSize(15)
              .fontWeight(700)
              .fontColor(colorsOf(this.themeNum).textMain)
              .width('100%')
            Text('HarmonyGacha v1.0.0')
              .fontSize(12)
              .fontColor(colorsOf(this.themeNum).textSub)
              .width('100%')
            Text(this.dbMode)
              .fontSize(11)
              .fontColor(colorsOf(this.themeNum).textSub)
              .width('100%')
            Text('隐私说明：所有抽卡数据仅保存在本机应用沙箱内（RDB 数据库与缓存文件），不采集个人信息，不联网，不上传任何数据。卸载应用后数据随之删除。')
              .fontSize(11)
              .fontColor(colorsOf(this.themeNum).textSub)
              .width('100%')
          }
          .padding(16)
          .borderRadius(16)
          .backgroundColor(colorsOf(this.themeNum).card)
          .border({ width: 1, color: colorsOf(this.themeNum).border })
          .margin({ left: 16, right: 16, bottom: 20 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .width('100%')

      NavBar({ active: 5 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colorsOf(this.themeNum).bg)
  }
}
