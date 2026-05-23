import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import { ClipService } from '../service/ClipService';

const RETENTION_OPTIONS: number[] = [7, 30, 90];

@Entry
@Component
struct Settings {
  @StorageProp('retentionDays') @Watch('onRetentionChanged') retentionDays: number = 30;
  @StorageLink('distributedEnabled') distributedEnabled: boolean = false;
  @State private showClearDialog: boolean = false;
  private service: ClipService = ClipService.getInstance();

  onRetentionChanged(): void {
    // Triggered when retentionDays StorageProp changes
  }

  private async requestDistributedPermission(): Promise<boolean> {
    const context = getContext(this) as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();
    try {
      const result = await atManager.requestPermissionsFromUser(
        context,
        ['ohos.permission.DISTRIBUTED_DATASYNC']
      );
      return result.authResults[0] === 0;
    } catch {
      return false;
    }
  }

  private async onDistributedToggle(value: boolean): Promise<void> {
    if (value) {
      const granted = await this.requestDistributedPermission();
      if (!granted) {
        promptAction.showToast({ message: '需要分布式数据同步权限', duration: 2000 });
        return;
      }
    }
    AppStorage.set('distributedEnabled', value);
  }

  private async clearHistory(): Promise<void> {
    try {
      await this.service.clearHistory();
      promptAction.showToast({ message: '历史记录已清空', duration: 1500 });
    } catch {
      promptAction.showToast({ message: '清空失败', duration: 1500 });
    }
    this.showClearDialog = false;
  }

  @Builder
  private SectionHeader(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor('#99182431')
      .fontWeight(FontWeight.Medium)
      .padding({ left: 16, right: 16, top: 20, bottom: 8 })
  }

  @Builder
  private CardContainer(content: () => void) {
    Column() {
      content()
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
    .padding({ top: 4, bottom: 4 })
  }

  @Builder
  private RetentionRow(days: number) {
    Row() {
      Text(`${days} 天`)
        .fontSize(16)
        .fontColor('#182431')
        .layoutWeight(1)

      if (this.retentionDays === days) {
        Image($r('sys.media.ohos_ic_public_ok'))
          .width(20)
          .height(20)
          .fillColor('#007DFF')
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .onClick(() => {
      AppStorage.set('retentionDays', days);
    })
  }

  build() {
    Navigation() {
      Scroll() {
        Column() {
          // Retention days section
          this.SectionHeader('保留天数')
          this.CardContainer(() => {
            ForEach(RETENTION_OPTIONS, (days: number, index: number) => {
              Column() {
                this.RetentionRow(days)
                if (index < RETENTION_OPTIONS.length - 1) {
                  Divider()
                    .height(0.5)
                    .color('#1A182431')
                    .margin({ left: 16 })
                }
              }
            }, (days: number) => `retention_${days}`)
          })

          // Distributed sync section
          this.SectionHeader('分布式功能')
          this.CardContainer(() => {
            Row() {
              Column({ space: 4 }) {
                Text('分布式同步')
                  .fontSize(16)
                  .fontColor('#182431')
                Text('在账号下多台设备间同步历史记录')
                  .fontSize(12)
                  .fontColor('#99182431')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.distributedEnabled })
                .selectedColor('#007DFF')
                .onChange((isOn: boolean) => {
                  this.onDistributedToggle(isOn);
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .alignItems(VerticalAlign.Center)
          })

          // Danger zone
          this.SectionHeader('危险操作')
          Column() {
            Row() {
              Text('清空历史记录')
                .fontSize(16)
                .fontColor('#FA2A2D')
              Blank()
              Image($r('sys.media.ohos_ic_public_arrow_right'))
                .width(16)
                .height(16)
                .fillColor('#99182431')
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .onClick(() => {
              this.showClearDialog = true;
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          Text('收藏内容不受清空操作影响')
            .fontSize(12)
            .fontColor('#99182431')
            .padding({ left: 32, right: 32, top: 8, bottom: 8 })

          Blank().height(32)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .height('100%')
      .backgroundColor('#F1F3F5')
    }
    .title('设置')
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor('#F1F3F5')
    .bindDialog(this.showClearDialog, {
      title: '确认清空',
      message: '将删除全部剪贴板历史（收藏内容不受影响），此操作不可恢复。',
      primaryButton: {
        value: '取消',
        action: () => {
          this.showClearDialog = false;
        }
      },
      secondaryButton: {
        value: '清空',
        fontColor: '#FA2A2D',
        action: () => {
          this.clearHistory();
        }
      }
    })
  }
}
