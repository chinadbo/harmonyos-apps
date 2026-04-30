import promptAction from '@ohos.promptAction';
import { Constants } from '../utils/Constants';
import { ArticleService } from '../service/ArticleService';

/**
 * 设置页面
 * 包含：刷新间隔、阅读器字体大小、通知开关、OPML 导出/导入、缓存清理
 */
@Component
export struct SettingsPage {
  @StorageProp(Constants.KEY_REFRESH_INTERVAL)
  @Watch('onRefreshIntervalChange')
  refreshInterval: number = Constants.DEFAULT_REFRESH_INTERVAL;

  @StorageProp(Constants.KEY_FONT_SIZE)
  fontSize: number = Constants.DEFAULT_FONT_SIZE;

  @StorageProp(Constants.KEY_NOTIFICATION_ENABLED)
  notificationEnabled: boolean = true;

  private articleService = ArticleService.getInstance();

  onRefreshIntervalChange(): void {
    PersistentStorage.persistProp(Constants.KEY_REFRESH_INTERVAL, this.refreshInterval);
  }

  getRefreshLabel(): string {
    switch (this.refreshInterval) {
      case Constants.REFRESH_15MIN: return '15 分钟';
      case Constants.REFRESH_30MIN: return '30 分钟';
      case Constants.REFRESH_1HOUR: return '1 小时';
      default: return '手动';
    }
  }

  @Builder
  SettingRow(label: string, value: string, action: () => void) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
      Text(value)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(14)
        .height(14)
        .opacity(0.4)
        .margin({ left: 4 })
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .onClick(action)

    Divider()
      .strokeWidth(0.5)
      .color($r('app.color.divider_color'))
      .margin({ left: 16 })
  }

  @Builder
  ToggleRow(label: string, isOn: boolean, onChange: (val: boolean) => void) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn })
        .onChange(onChange)
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })

    Divider()
      .strokeWidth(0.5)
      .color($r('app.color.divider_color'))
      .margin({ left: 16 })
  }

  @Builder
  SectionHeader(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor($r('app.color.text_hint'))
      .width('100%')
      .padding({ left: 16, top: 16, bottom: 8 })
  }

  build() {
    Scroll() {
      Column() {
        // 顶部标题
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .padding({ left: 16, top: 12, bottom: 8 })

        // ===== 阅读器设置 =====
        this.SectionHeader('阅读器')
        Column() {
          this.SettingRow('字体大小', `${this.fontSize}px`, () => {
            promptAction.showDialog({
              title: '字体大小',
              buttons: [
                { text: '小 (13px)', color: '#333' },
                { text: '默认 (16px)', color: '#333' },
                { text: '大 (19px)', color: '#333' },
                { text: '超大 (22px)', color: '#333' },
              ]
            }).then((result) => {
              const sizes = [13, 16, 19, 22];
              this.fontSize = sizes[result.index];
              AppStorage.set(Constants.KEY_FONT_SIZE, this.fontSize);
            });
          })
        }
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        .clip(true)

        // ===== 刷新设置 =====
        this.SectionHeader('刷新')
        Column() {
          this.SettingRow('自动刷新间隔', this.getRefreshLabel(), () => {
            promptAction.showDialog({
              title: '刷新间隔',
              buttons: [
                { text: '15 分钟', color: '#333' },
                { text: '30 分钟', color: '#333' },
                { text: '1 小时', color: '#333' },
                { text: '手动', color: '#333' },
              ]
            }).then((result) => {
              const intervals = [
                Constants.REFRESH_15MIN,
                Constants.REFRESH_30MIN,
                Constants.REFRESH_1HOUR,
                0
              ];
              this.refreshInterval = intervals[result.index];
              AppStorage.set(Constants.KEY_REFRESH_INTERVAL, this.refreshInterval);
            });
          })
        }
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        .clip(true)

        // ===== 通知 =====
        this.SectionHeader('通知')
        Column() {
          this.ToggleRow('新文章通知', this.notificationEnabled, (val) => {
            this.notificationEnabled = val;
            AppStorage.set(Constants.KEY_NOTIFICATION_ENABLED, val);
          })
        }
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        .clip(true)

        // ===== 数据管理 =====
        this.SectionHeader('数据管理')
        Column() {
          this.SettingRow('导出 OPML', '', () => {
            promptAction.showToast({ message: 'OPML 导出功能开发中...' });
          })
          this.SettingRow('导入 OPML', '', () => {
            promptAction.showToast({ message: 'OPML 导入功能开发中...' });
          })
          // 清理缓存
          Row() {
            Text('清理过期文章')
              .fontSize(15)
              .fontColor($r('app.color.error_color'))
              .layoutWeight(1)
            Text('（超 30 天且未收藏）')
              .fontSize(12)
              .fontColor($r('app.color.text_hint'))
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .onClick(async () => {
            promptAction.showDialog({
              title: '清理确认',
              message: '将删除 30 天前的未收藏文章，确定吗？',
              buttons: [
                { text: '取消', color: '#666' },
                { text: '清理', color: '#FF5252' },
              ]
            }).then(async (result) => {
              if (result.index === 1) {
                await this.articleService.cleanOldArticles();
                promptAction.showToast({ message: '清理完成' });
              }
            });
          })
        }
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        .clip(true)

        // ===== 关于 =====
        this.SectionHeader('关于')
        Column() {
          Row() {
            Text('HarmonyFeed')
              .fontSize(15)
              .fontColor($r('app.color.text_primary'))
              .layoutWeight(1)
            Text('v1.0.0')
              .fontSize(14)
              .fontColor($r('app.color.text_hint'))
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })

          Divider()
            .strokeWidth(0.5)
            .color($r('app.color.divider_color'))
            .margin({ left: 16 })

          Row() {
            Text('隐私政策')
              .fontSize(15)
              .fontColor($r('app.color.primary_color'))
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            promptAction.showToast({ message: '本应用不收集任何个人信息' });
          })
        }
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 16, right: 16, bottom: 32 })
        .clip(true)
      }
      .width('100%')
      .backgroundColor($r('app.color.surface_color'))
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }
}
