import { TtsService } from '../service/TtsService';
import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

@Component
export struct SettingsContent {
  @StorageProp('pageStack') pageStack: NavPathStack = new NavPathStack();
  @State ttsEnabled: boolean = true;
  @State dailyGoal: number = 20;

  aboutToAppear(): void {
    this.loadSettings();
  }

  async loadSettings(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const pref = await preferences.getPreferences(context, 'flash_settings');
      this.ttsEnabled = (await pref.get('tts_enabled', true)) as boolean;
      this.dailyGoal = (await pref.get('daily_goal', 20)) as number;
      TtsService.getInstance().setEnabled(this.ttsEnabled);
    } catch (e) {}
  }

  async saveSetting(key: string, value: boolean | number): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const pref = await preferences.getPreferences(context, 'flash_settings');
      await pref.put(key, value);
      await pref.flush();
    } catch (e) {}
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('←').fontSize(20).fontColor('#374151')
        }
        .width(40).height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.pageStack.pop())

        Text('设置')
          .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A2E')
          .layoutWeight(1).textAlign(TextAlign.Center)

        Column().width(40).height(40)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Divider().color('#F3F4F6')

      Scroll() {
        Column({ space: 16 }) {
          Column() {
            Text('学习设置')
              .fontSize(14).fontWeight(FontWeight.Medium).fontColor('#9CA3AF')
              .alignSelf(ItemAlign.Start).margin({ bottom: 12 })

            Row() {
              Column() {
                Text('每日学习目标')
                  .fontSize(16).fontColor('#1A1A2E')
                Text('设置每天目标学习卡片数')
                  .fontSize(13).fontColor('#9CA3AF').margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start).layoutWeight(1)

              Row({ space: 8 }) {
                Button('-')
                  .width(36).height(36).fontSize(20)
                  .backgroundColor('#F3F4F6').fontColor('#374151').borderRadius(8)
                  .onClick(() => {
                    if (this.dailyGoal > 5) {
                      this.dailyGoal -= 5;
                      this.saveSetting('daily_goal', this.dailyGoal);
                    }
                  })
                Text(String(this.dailyGoal))
                  .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1A1A2E')
                  .width(40).textAlign(TextAlign.Center)
                Button('+')
                  .width(36).height(36).fontSize(20)
                  .backgroundColor('#F3F4F6').fontColor('#374151').borderRadius(8)
                  .onClick(() => {
                    if (this.dailyGoal < 100) {
                      this.dailyGoal += 5;
                      this.saveSetting('daily_goal', this.dailyGoal);
                    }
                  })
              }
            }
            .width('100%').padding(16)
            .backgroundColor(Color.White).borderRadius(12)
          }

          Column() {
            Text('发音设置')
              .fontSize(14).fontWeight(FontWeight.Medium).fontColor('#9CA3AF')
              .alignSelf(ItemAlign.Start).margin({ bottom: 12 })

            Row() {
              Column() {
                Text('单词发音')
                  .fontSize(16).fontColor('#1A1A2E')
                Text('学习时自动朗读单词')
                  .fontSize(13).fontColor('#9CA3AF').margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start).layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.ttsEnabled })
                .onChange(isOn => {
                  this.ttsEnabled = isOn;
                  TtsService.getInstance().setEnabled(isOn);
                  this.saveSetting('tts_enabled', isOn);
                })
            }
            .width('100%').padding(16)
            .backgroundColor(Color.White).borderRadius(12)
          }

          Column() {
            Text('关于')
              .fontSize(14).fontWeight(FontWeight.Medium).fontColor('#9CA3AF')
              .alignSelf(ItemAlign.Start).margin({ bottom: 12 })

            Column({ space: 0 }) {
              Row() {
                Text('版本').fontSize(16).fontColor('#1A1A2E').layoutWeight(1)
                Text('1.0.0').fontSize(14).fontColor('#9CA3AF')
              }.padding(16)
              Divider().color('#F3F4F6').margin({ left: 16 })
              Row() {
                Text('算法').fontSize(16).fontColor('#1A1A2E').layoutWeight(1)
                Text('SM-2 间隔重复').fontSize(14).fontColor('#9CA3AF')
              }.padding(16)
              Divider().color('#F3F4F6').margin({ left: 16 })
              Row() {
                Text('数据存储').fontSize(16).fontColor('#1A1A2E').layoutWeight(1)
                Text('本地（不上传）').fontSize(14).fontColor('#10B981')
              }.padding(16)
            }
            .backgroundColor(Color.White).borderRadius(12)
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 40 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%')
    .backgroundColor('#F8FAFC')
  }
}

@Entry
@Component
struct SettingsPage {
  build() {
    SettingsContent()
  }
}
