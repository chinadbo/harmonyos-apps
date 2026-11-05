/**
 * AchievementsPage：成就徽章页。
 * 里程碑徽章（看完 10/30/50/100 部），展示解锁状态、解锁时间与当前进度。
 */
import router from '@ohos.router';
import { BusinessError } from '@ohos.base';
import {
  ACHIEVEMENT_DEFS,
  AchievementDef,
  formatDate
} from '../model/Movie';
import { dbReady } from '../data/DbService';
import {
  getCounts,
  getUnlockedAchievements,
  checkAchievements
} from '../data/MovieRepository';

@Entry
@Component
struct AchievementsPage {
  @State unlockedMap: Map<string, number> = new Map<string, number>();
  @State watchedCount: number = 0;
  @State loaded: boolean = false;

  private async load(): Promise<void> {
    try {
      await checkAchievements();
      this.unlockedMap = await getUnlockedAchievements();
      const counts = await getCounts();
      this.watchedCount = counts.watched;
      this.loaded = true;
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyCine] achievements load failed, code=${e.code} message=${e.message}`);
    }
  }

  async aboutToAppear(): Promise<void> {
    await dbReady();
    await this.load();
  }

  onPageShow(): void {
    if (this.loaded) {
      this.load();
    }
  }

  private unlockedTime(def: AchievementDef): number | null {
    if (this.unlockedMap.has(def.id)) {
      const value = this.unlockedMap.get(def.id);
      if (value !== undefined) {
        return value;
      }
    }
    return null;
  }

  private progressPercent(def: AchievementDef): number {
    const percent = this.watchedCount / def.threshold;
    if (percent > 1) {
      return 1;
    }
    if (percent < 0) {
      return 0;
    }
    return percent;
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
        Text('观影成就')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#22242E')
          .layoutWeight(1)
        Text(`已看 ${this.watchedCount} 部`)
          .fontSize(13)
          .fontColor('#666A78')
          .margin({ right: 16 })
      }
      .width('100%')
      .padding({ left: 16, top: 14, bottom: 12 })
      .alignItems(VerticalAlign.Center)

      if (!this.loaded) {
        Column() {
          Text('加载中...')
            .fontSize(14)
            .fontColor('#8A8F9E')
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(ACHIEVEMENT_DEFS, (def: AchievementDef) => {
              Row({ space: 14 }) {
                Text(`${def.threshold}`)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.unlockedTime(def) !== null ? '#FFFFFF' : '#A0A5B4')
                  .width(64)
                  .height(64)
                  .textAlign(TextAlign.Center)
                  .borderRadius(32)
                  .backgroundColor(this.unlockedTime(def) !== null ? '#F5A623' : '#EDEFF5')

                Column({ space: 6 }) {
                  Text(def.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.unlockedTime(def) !== null ? '#22242E' : '#A0A5B4')
                  Text(def.description)
                    .fontSize(12)
                    .fontColor('#8A8F9E')

                  Column() {
                    Column()
                      .width(`${this.progressPercent(def) * 100}%`)
                      .height('100%')
                      .backgroundColor(this.unlockedTime(def) !== null ? '#F5A623' : '#74B9FF')
                  }
                  .width('100%')
                  .height(6)
                  .borderRadius(3)
                  .backgroundColor('#EDEFF5')
                  .margin({ top: 2 })

                  if (this.unlockedTime(def) !== null) {
                    Text(`已于 ${formatDate(this.unlockedTime(def) as number)} 解锁`)
                      .fontSize(11)
                      .fontColor('#F5A623')
                  } else {
                    Text(`还差 ${Math.max(def.threshold - this.watchedCount, 0)} 部解锁`)
                      .fontSize(11)
                      .fontColor('#A0A5B4')
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .alignItems(VerticalAlign.Center)
            }, (def: AchievementDef) => `${def.id}_${this.unlockedTime(def) !== null ? 1 : 0}`)

            Text('继续标记「看完」，解锁更多成就徽章')
              .fontSize(11)
              .fontColor('#A0A5B4')
              .margin({ top: 4, bottom: 30 })
          }
          .padding({ left: 16, right: 16 })
          .width('100%')
        }
        .layoutWeight(1)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F4F8')
  }
}
