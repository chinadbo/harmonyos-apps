import common from '@ohos.app.ability.common';
import { DiaryListItem } from '../model/DiaryModel';
import { diaryRepository } from '../service/DiaryRepository';
import { DiaryCard } from '../components/DiaryCard';
import { EmptyState } from '../components/EmptyState';
import { todayKey } from '../utils/DateUtils';

@Component
export struct HomeTab {
  @StorageLink('diary_refresh_token') @Watch('loadData') refreshToken: number = 0;
  navPathStack?: NavPathStack;
  @State entries: DiaryListItem[] = [];
  @State latestMoodText: string = '今天还没有新的心情记录';

  aboutToAppear(): void {
    this.loadData();
  }

  private context(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  async loadData(): Promise<void> {
    this.entries = await diaryRepository.getRecentDiaries(this.context());
    this.latestMoodText = await diaryRepository.latestMood(this.context());
  }

  private openEditor(date: string = todayKey()): void {
    this.navPathStack?.pushPath({ name: 'DiaryEditor', param: { date } });
  }

  private openSearch(): void {
    this.navPathStack?.pushPath({ name: 'SearchPage', param: {} });
  }

  private openDetail(id: number): void {
    this.navPathStack?.pushPath({ name: 'DiaryDetail', param: { id } });
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Column({ space: 16 }) {
          Row() {
            Column({ space: 6 }) {
              Text('HarmonyDiary')
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor('#0F172A')
              Text(this.latestMoodText)
                .fontSize(14)
                .fontColor('#475569')
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Button('搜索')
              .height(40)
              .backgroundColor('#E2E8F0')
              .fontColor('#0F172A')
              .onClick(() => this.openSearch())
          }
          .width('100%')

          Row({ space: 12 }) {
            Column({ space: 8 }) {
              Text('今天想记下什么？')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#0F172A')
              Text('用加密日记记录情绪、照片与当下。')
                .fontSize(13)
                .fontColor('#64748B')
            }
            .layoutWeight(1)
            Button('新建日记')
              .height(44)
              .backgroundColor('#0F172A')
              .fontColor('#FFFFFF')
              .onClick(() => this.openEditor())
          }
          .width('100%')
          .padding(18)
          .backgroundColor('#F8FAFC')
          .borderRadius(28)
        }
        .width('100%')

        Column({ space: 12 }) {
          Row() {
            Text('最近记录')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#0F172A')
            Blank()
            Text(`${this.entries.length} 篇`)
              .fontSize(13)
              .fontColor('#64748B')
          }
          .width('100%')

          if (this.entries.length === 0) {
            EmptyState({ title: '还没有日记', message: '从今天开始写下第一篇心情记录。' })
          } else {
            ForEach(this.entries, (item: DiaryListItem) => {
              DiaryCard({ item, onClick: (id: number) => this.openDetail(id) })
            })
          }
        }
        .width('100%')
      }
      .padding(20)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#FFFFFF')
  }
}
