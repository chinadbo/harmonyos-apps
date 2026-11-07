/**
 * 设置页：涨跌色主题切换（@StorageLink 全局）+ 提醒开关 + 清空数据（二次确认）
 */

import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { QuoteDB } from '../db/QuoteDB'
import { AppInit } from '../common/AppInit'
import { Prefs } from '../common/Prefs'
import { Theme, ThemeMode } from '../common/Theme'
import { Notify } from '../common/Notify'
import { BottomNav } from '../components/BottomNav'

@Entry
@Component
struct SettingsPage {
  @StorageLink('themeMode') themeMode: string = 'red_up'
  @StorageLink('alertEnabled') alertEnabled: boolean = true
  @State dbMemoryMode: boolean = false

  aboutToAppear(): void {
    this.init()
  }

  private async init(): Promise<void> {
    await AppInit.ready()
    this.dbMemoryMode = QuoteDB.getInstance().isMemoryMode()
  }

  private selectTheme(mode: string): void {
    this.themeMode = mode
    Prefs.setThemeMode(mode)
    Notify.vibrate()
    promptAction.showToast({ message: mode === ThemeMode.RED_UP ? '已切换：红涨绿跌' : '已切换：绿涨红跌' })
  }

  private toggleAlert(on: boolean): void {
    this.alertEnabled = on
    Prefs.setAlertEnabled(on)
    if (on) {
      Notify.ensurePermission().then((ok: boolean) => {
        if (!ok) {
          promptAction.showToast({ message: '未授权通知，提醒将仅通过震动提示' })
        }
      })
    }
  }

  private clearDataStep1(): void {
    AlertDialog.show({
      title: '清空数据',
      message: '将清空自选、持仓与净值历史，确定继续吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '继续',
        fontColor: Theme.UP_RED,
        action: () => {
          this.clearDataStep2()
        }
      }
    })
  }

  private clearDataStep2(): void {
    AlertDialog.show({
      title: '最后确认',
      message: '该操作不可恢复！所有本地数据将被删除。',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '确认清空',
        fontColor: Theme.UP_RED,
        action: async () => {
          await QuoteDB.getInstance().clearAll()
          promptAction.showToast({ message: '数据已清空' })
          router.clear()
          router.pushUrl({ url: 'pages/Index' })
        }
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.TEXT)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 6 })

      Scroll() {
        Column({ space: 12 }) {
          // 涨跌配色
          Column({ space: 12 }) {
            Text('涨跌配色')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.TEXT)
              .alignSelf(ItemAlign.Start)

            Row({ space: 10 }) {
              this.themeOption(ThemeMode.RED_UP, '红涨绿跌', Theme.UP_RED, Theme.DOWN_GREEN)
              this.themeOption(ThemeMode.GREEN_UP, '绿涨红跌', Theme.DOWN_GREEN, Theme.UP_RED)
            }
            .width('100%')

            Text('切换后全应用立即生效（含图表与卡片）')
              .fontSize(11)
              .fontColor(Theme.TEXT3)
              .alignSelf(ItemAlign.Start)
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.CARD)
          .borderRadius(12)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)' })

          // 提醒
          Column({ space: 8 }) {
            Text('价格提醒')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.TEXT)
              .alignSelf(ItemAlign.Start)
            Row() {
              Column({ space: 2 }) {
                Text('提醒开关')
                  .fontSize(13)
                  .fontColor(Theme.TEXT)
                Text('在详情页设置的阈值触发时发送通知')
                  .fontSize(11)
                  .fontColor(Theme.TEXT3)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.alertEnabled })
                .selectedColor(Theme.ACCENT)
                .onChange((on: boolean) => {
                  this.toggleAlert(on)
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.CARD)
          .borderRadius(12)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)' })

          // 数据
          Column({ space: 10 }) {
            Text('数据')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.TEXT)
              .alignSelf(ItemAlign.Start)
            if (this.dbMemoryMode) {
              Text('数据库初始化失败，当前以内存模式运行（数据重启后丢失）')
                .fontSize(11)
                .fontColor(Theme.TEXT3)
                .alignSelf(ItemAlign.Start)
            }
            Button('清空全部本地数据')
              .fontSize(14)
              .height(38)
              .width('100%')
              .backgroundColor('#FDECEA')
              .fontColor(Theme.UP_RED)
              .onClick(() => {
                this.clearDataStep1()
              })
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.CARD)
          .borderRadius(12)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)' })

          // 关于
          Column({ space: 6 }) {
            Text('关于')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.TEXT)
              .alignSelf(ItemAlign.Start)
            Text('HarmonyQuotes 行情助手 v1.0.0')
              .fontSize(12)
              .fontColor(Theme.TEXT2)
              .alignSelf(ItemAlign.Start)
            Text('行情数据为本地模拟生成（几何布朗运动），无网络请求；全部数据仅存储在本机数据库，不上传任何信息。')
              .fontSize(11)
              .fontColor(Theme.TEXT3)
              .alignSelf(ItemAlign.Start)
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.CARD)
          .borderRadius(12)
          .margin({ bottom: 20 })
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)' })
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 4 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      BottomNav({ active: 4 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  themeOption(mode: string, label: string, upC: string, downC: string) {
    Column({ space: 8 }) {
      Row({ space: 6 }) {
        Text('涨')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(upC)
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        Text('跌')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(downC)
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      }
      Text(label)
        .fontSize(13)
        .fontColor(this.themeMode === mode ? Theme.ACCENT : Theme.TEXT)
        .fontWeight(this.themeMode === mode ? FontWeight.Medium : FontWeight.Normal)
    }
    .layoutWeight(1)
    .padding({ top: 10, bottom: 10 })
    .borderRadius(10)
    .backgroundColor(Theme.BG)
    .border({
      width: this.themeMode === mode ? 1.5 : 0.5,
      color: this.themeMode === mode ? Theme.ACCENT : Theme.GRID
    })
    .onClick(() => {
      this.selectTheme(mode)
    })
  }
}
