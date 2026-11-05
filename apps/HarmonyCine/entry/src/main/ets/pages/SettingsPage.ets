/**
 * SettingsPage：设置页。
 * 海报色板偏移（0-3，全局换肤）+ 清空全部数据（确认）+ 关于与隐私说明。
 */
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';
import { POSTER_PALETTE, posterColors } from '../model/Movie';
import {
  dbReady,
  putPrefNumber,
  PREF_KEY_POSTER_OFFSET
} from '../data/DbService';
import { deleteAllData } from '../data/MovieRepository';

const POSTER_OFFSET_MAX: number = 3;
const FEEDBACK_TIMEOUT_MS: number = 2000;

@Entry
@Component
struct SettingsPage {
  @StorageLink('posterOffset') posterOffset: number = 0;
  @State feedback: string = '';
  @State clearing: boolean = false;
  private feedbackTimerId: number = -1;

  private showFeedback(message: string): void {
    this.feedback = message;
    if (this.feedbackTimerId !== -1) {
      clearTimeout(this.feedbackTimerId);
    }
    this.feedbackTimerId = setTimeout(() => {
      this.feedbackTimerId = -1;
      this.feedback = '';
    }, FEEDBACK_TIMEOUT_MS);
  }

  async aboutToAppear(): Promise<void> {
    await dbReady();
  }

  aboutToDisappear(): void {
    if (this.feedbackTimerId !== -1) {
      clearTimeout(this.feedbackTimerId);
      this.feedbackTimerId = -1;
    }
  }

  private choosePosterOffset(offset: number): void {
    if (this.posterOffset === offset) {
      return;
    }
    this.posterOffset = offset;
    putPrefNumber(PREF_KEY_POSTER_OFFSET, offset);
    this.showFeedback('海报配色已更新');
  }

  private confirmClearData(): void {
    if (this.clearing) {
      return;
    }
    AlertDialog.show({
      title: '清空数据',
      message: '将删除片单、观看记录与成就的全部本地数据，且不可恢复。确定继续？',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '清空',
        fontColor: '#D93026',
        action: () => {
          this.applyClearData();
        }
      }
    });
  }

  private async applyClearData(): Promise<void> {
    this.clearing = true;
    try {
      await deleteAllData();
      promptAction.showToast({ message: '已清空全部数据', duration: 1500 });
      this.showFeedback('数据已清空，重启应用可重新灌入推荐库');
    } catch (err) {
      const e = err as BusinessError;
      this.showFeedback(`清空失败: ${e.message}`);
    }
    this.clearing = false;
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#22242E')
          .padding({ left: 4, right: 12 })
          .onClick(() => {
            router.back();
          })
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#22242E')
      }
      .width('100%')
      .padding({ left: 16, top: 14, bottom: 12 })
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 14 }) {
          if (this.feedback.length > 0) {
            Text(this.feedback)
              .fontSize(12)
              .fontColor('#3D5AFE')
              .width('100%')
          }

          // 海报配色
          Column({ space: 12 }) {
            Text('海报配色')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#444652')
              .width('100%')
            Text('更换海报墙的渐变色板，立即生效并保存到偏好')
              .fontSize(12)
              .fontColor('#8A8F9E')
              .width('100%')
            Row({ space: 12 }) {
              ForEach([0, 1, 2, 3], (offset: number) => {
                Column()
                  .width(56)
                  .height(56)
                  .borderRadius(12)
                  .linearGradient({
                    angle: 135,
                    colors: posterColors(offset, 0)
                  })
                  .border({
                    width: this.posterOffset === offset ? 3 : 0,
                    color: '#3D5AFE'
                  })
                  .onClick(() => {
                    this.choosePosterOffset(offset);
                  })
              }, (offset: number) => `${offset}_${this.posterOffset === offset ? 1 : 0}`)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .width('100%')

          // 数据管理
          Column({ space: 12 }) {
            Text('数据管理')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#444652')
              .width('100%')
            Text('所有数据仅保存在本机数据库（harmonycine.db）与偏好设置中，无云端同步。')
              .fontSize(12)
              .fontColor('#8A8F9E')
              .width('100%')
            Button('清空全部数据')
              .width('100%')
              .height(42)
              .borderRadius(21)
              .backgroundColor('#FFFFFF')
              .fontColor('#D93026')
              .fontSize(14)
              .enabled(!this.clearing)
              .onClick(() => {
                this.confirmClearData();
              })
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .width('100%')

          // 关于
          Column({ space: 8 }) {
            Text('关于 HarmonyCine')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#444652')
              .width('100%')
            Text('版本：1.0.0')
              .fontSize(12)
              .fontColor('#8A8F9E')
            Text('一款纯本地的影视追踪与片单管理应用：三态片单、评分、进度、观影统计、成就徽章。')
              .fontSize(12)
              .fontColor('#8A8F9E')
            Text('隐私：不申请任何系统权限，不联网，不收集任何个人数据。详见 resources/base/profile/privacy_statement.json。')
              .fontSize(12)
              .fontColor('#8A8F9E')
            Text(`色板：共 ${POSTER_PALETTE.length} 组渐变配色，当前偏移 ${this.posterOffset}`)
              .fontSize(11)
              .fontColor('#A0A5B4')
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ bottom: 30 })
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .padding({ left: 16, right: 16 })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F4F8')
  }
}
