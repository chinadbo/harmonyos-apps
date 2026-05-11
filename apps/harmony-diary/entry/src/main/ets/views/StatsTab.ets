import common from '@ohos.app.ability.common';
import { DiaryStatsSummary } from '../model/DiaryModel';
import { diaryRepository } from '../service/DiaryRepository';
import { MoodPieChart } from '../components/MoodPieChart';
import { EmptyState } from '../components/EmptyState';

@Component
export struct StatsTab {
  @StorageLink('diary_refresh_token') @Watch('loadStats') refreshToken: number = 0;
  @State summary: DiaryStatsSummary = { totalCount: 0, monthlyCount: 0, streak: 0, moods: [] };

  aboutToAppear(): void {
    this.loadStats();
  }

  private context(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  async loadStats(): Promise<void> {
    this.summary = await diaryRepository.getStats(this.context());
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row({ space: 12 }) {
          this.buildStatCard('累计日记', `${this.summary.totalCount}`)
          this.buildStatCard('本月记录', `${this.summary.monthlyCount}`)
          this.buildStatCard('连续天数', `${this.summary.streak}`)
        }
        .width('100%')

        Column({ space: 18 }) {
          Text('心情分布')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#0F172A')
            .width('100%')
          if (this.summary.moods.length === 0) {
            EmptyState({ title: '暂无统计数据', message: '写下几篇日记后，这里会展示你的情绪分布。' })
          } else {
            MoodPieChart({ stats: this.summary.moods })
          }
        }
        .width('100%')
        .padding(18)
        .backgroundColor('#FFFFFF')
        .borderRadius(28)
        .shadow({ radius: 16, color: '#120F172A', offsetX: 0, offsetY: 8 })
      }
      .padding(20)
      .alignItems(HorizontalAlign.Start)
    }
    .scrollBar(BarState.Off)
  }

  @Builder
  private buildStatCard(label: string, value: string) {
    Column({ space: 8 }) {
      Text(value)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0F172A')
      Text(label)
        .fontSize(12)
        .fontColor('#64748B')
    }
    .layoutWeight(1)
    .padding({ top: 18, bottom: 18 })
    .backgroundColor('#F8FAFC')
    .borderRadius(24)
  }
}
