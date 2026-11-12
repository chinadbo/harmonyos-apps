import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { CharEntry, CharRepository } from '../model/CharData';
import { DbHelper } from '../db/DbHelper';
import { AppTheme } from '../common/Theme';
import { Constants } from '../common/Constants';
import { AppSettings, SettingsUtil, ToastUtil } from '../common/AppUtil';

@Entry
@Component
struct Settings {
  @State animSpeed: number = Constants.ANIM_SPEED_DEFAULT;
  @State brushWidth: number = Constants.BRUSH_WIDTH_DEFAULT;
  @State vibrateEnabled: boolean = Constants.VIBRATE_DEFAULT;
  @State totalRecords: number = 0;
  @State charCount: number = 0;
  @State strokeCount: number = 0;
  private settings: AppSettings = SettingsUtil.defaultSettings();

  onPageShow(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    this.settings = await SettingsUtil.load(context);
    this.animSpeed = this.settings.animSpeed;
    this.brushWidth = this.settings.brushWidth;
    this.vibrateEnabled = this.settings.vibrateEnabled;

    await DbHelper.getInstance().init(context);
    this.totalRecords = await DbHelper.getInstance().getTotalCount();

    const chars: CharEntry[] = await CharRepository.getInstance().load(context);
    this.charCount = chars.length;
    let strokes: number = 0;
    for (let i = 0; i < chars.length; i++) {
      strokes += chars[i].strokes.length;
    }
    this.strokeCount = strokes;
  }

  private async persist(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const next: AppSettings = {
      animSpeed: this.animSpeed,
      brushWidth: this.brushWidth,
      vibrateEnabled: this.vibrateEnabled
    };
    this.settings = next;
    await SettingsUtil.save(context, next);
  }

  private speedLabel(): string {
    if (this.animSpeed <= 500) {
      return '快';
    }
    if (this.animSpeed >= 1200) {
      return '慢';
    }
    return '适中';
  }

  private confirmReset(): void {
    AlertDialog.show({
      title: '重置练习数据',
      message: `将删除全部 ${this.totalRecords} 条练习记录，删除后无法恢复。`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '确认删除',
        fontColor: AppTheme.ACCENT,
        action: () => {
          this.doReset();
        }
      }
    });
  }

  private async doReset(): Promise<void> {
    const ok: boolean = await DbHelper.getInstance().clearAll();
    if (ok) {
      this.totalRecords = 0;
      ToastUtil.show('练习数据已重置');
    } else {
      ToastUtil.show('重置失败，请稍后再试');
    }
  }

  @Builder
  sectionTitle(title: string) {
    Text(title)
      .fontSize(15)
      .fontWeight(FontWeight.Medium)
      .fontColor(AppTheme.INK)
      .width('100%')
      .margin({ bottom: 8 })
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Text('‹')
          .fontSize(30)
          .fontColor(AppTheme.INK)
          .width(32)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.back();
          })
        Column({ space: 2 }) {
          Text('设置')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.INK)
          Text('书写体验 · 数据管理')
            .fontSize(11)
            .fontColor(AppTheme.INK_FAINT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: 16, top: 12, bottom: 10 })

      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 12 }) {
            this.sectionTitle('书写体验')

            Column({ space: 6 }) {
              Row() {
                Text('动画演示速度')
                  .fontSize(13)
                  .fontColor(AppTheme.INK)
                Blank()
                Text(`${this.speedLabel()} · ${this.animSpeed} ms/笔`)
                  .fontSize(11)
                  .fontColor(AppTheme.INK_FAINT)
              }
              .width('100%')
              Slider({
                value: this.animSpeed,
                min: Constants.ANIM_SPEED_MIN,
                max: Constants.ANIM_SPEED_MAX,
                step: 100,
                style: SliderStyle.OutSet
              })
                .width('100%')
                .selectedColor(AppTheme.ACCENT)
                .trackColor(AppTheme.CARD_ALT)
                .blockColor(AppTheme.ACCENT)
                .onChange((value: number, mode: SliderChangeMode) => {
                  this.animSpeed = value;
                  if (mode === SliderChangeMode.End) {
                    this.persist();
                  }
                })
              Row() {
                Text('慢速易学')
                  .fontSize(10)
                  .fontColor(AppTheme.INK_FAINT)
                Blank()
                Text('快速复习')
                  .fontSize(10)
                  .fontColor(AppTheme.INK_FAINT)
              }
              .width('100%')
            }
            .width('100%')

            Divider().color(AppTheme.CARD_ALT)

            Column({ space: 6 }) {
              Row() {
                Text('笔刷粗细')
                  .fontSize(13)
                  .fontColor(AppTheme.INK)
                Blank()
                Text(`${this.brushWidth} vp`)
                  .fontSize(11)
                  .fontColor(AppTheme.INK_FAINT)
              }
              .width('100%')
              Slider({
                value: this.brushWidth,
                min: Constants.BRUSH_WIDTH_MIN,
                max: Constants.BRUSH_WIDTH_MAX,
                step: 1,
                style: SliderStyle.OutSet
              })
                .width('100%')
                .selectedColor(AppTheme.INK)
                .trackColor(AppTheme.CARD_ALT)
                .blockColor(AppTheme.INK)
                .onChange((value: number, mode: SliderChangeMode) => {
                  this.brushWidth = value;
                  if (mode === SliderChangeMode.End) {
                    this.persist();
                  }
                })
              Row({ space: 10 }) {
                Text('预览')
                  .fontSize(10)
                  .fontColor(AppTheme.INK_FAINT)
                Row()
                  .layoutWeight(1)
                  .height(this.brushWidth)
                  .backgroundColor(AppTheme.INK)
                  .borderRadius(this.brushWidth / 2)
              }
              .width('100%')
            }
            .width('100%')

            Divider().color(AppTheme.CARD_ALT)

            Row() {
              Column({ space: 3 }) {
                Text('触觉反馈')
                  .fontSize(13)
                  .fontColor(AppTheme.INK)
                Text('写对一笔时轻轻震动')
                  .fontSize(10)
                  .fontColor(AppTheme.INK_FAINT)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.vibrateEnabled })
                .selectedColor(AppTheme.ACCENT)
                .onChange((isOn: boolean) => {
                  this.vibrateEnabled = isOn;
                  this.persist();
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppTheme.CARD)
          .borderRadius(18)

          Column({ space: 12 }) {
            this.sectionTitle('数据管理')
            Row() {
              Column({ space: 3 }) {
                Text('练习记录')
                  .fontSize(13)
                  .fontColor(AppTheme.INK)
                Text(`本机共保存 ${this.totalRecords} 条记录`)
                  .fontSize(10)
                  .fontColor(AppTheme.INK_FAINT)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Text('重置')
                .fontSize(12)
                .fontColor(AppTheme.ACCENT)
                .backgroundColor(AppTheme.ACCENT_SOFT)
                .borderRadius(14)
                .padding({ left: 16, right: 16, top: 7, bottom: 7 })
                .onClick(() => {
                  this.confirmReset();
                })
            }
            .width('100%')
            Text('练习记录仅存储在本机 RDB 数据库中，不会上传到任何服务器。')
              .fontSize(10)
              .fontColor(AppTheme.INK_FAINT)
              .lineHeight(16)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppTheme.CARD)
          .borderRadius(18)

          Column({ space: 10 }) {
            this.sectionTitle('关于墨迹笔顺')
            Row({ space: 12 }) {
              Text('墨')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width(48)
                .height(48)
                .textAlign(TextAlign.Center)
                .backgroundColor(AppTheme.INK)
                .borderRadius(12)
              Column({ space: 3 }) {
                Text(`${Constants.APP_NAME} v${Constants.VERSION}`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(AppTheme.INK)
                Text('汉字笔顺练习 / 书写启蒙')
                  .fontSize(10)
                  .fontColor(AppTheme.INK_FAINT)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            Divider().color(AppTheme.CARD_ALT)
            Row() {
              Text('内置字库')
                .fontSize(12)
                .fontColor(AppTheme.INK_LIGHT)
              Blank()
              Text(`${this.charCount} 字 · ${this.strokeCount} 个笔画`)
                .fontSize(12)
                .fontColor(AppTheme.INK)
            }
            .width('100%')
            Row() {
              Text('应用权限')
                .fontSize(12)
                .fontColor(AppTheme.INK_LIGHT)
              Blank()
              Text('仅震动（VIBRATE）')
                .fontSize(12)
                .fontColor(AppTheme.INK)
            }
            .width('100%')
            Row() {
              Text('网络访问')
                .fontSize(12)
                .fontColor(AppTheme.INK_LIGHT)
              Blank()
              Text('无 · 完全离线')
                .fontSize(12)
                .fontColor(AppTheme.GREEN)
            }
            .width('100%')
            Text('隐私声明：本应用不收集、不存储、不上传任何个人信息。全部笔画数据随应用安装包内置，练习记录只保存在本机。')
              .fontSize(10)
              .fontColor(AppTheme.INK_FAINT)
              .lineHeight(16)
              .padding({ top: 4 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppTheme.CARD)
          .borderRadius(18)

          Text('用一笔一画，写端正汉字')
            .fontSize(10)
            .fontColor(AppTheme.INK_FAINT)
            .padding({ bottom: 20 })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG)
  }
}
