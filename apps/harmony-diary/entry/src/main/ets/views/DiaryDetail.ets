import common from '@ohos.app.ability.common';
import { DiaryRecord } from '../model/DiaryModel';
import { diaryRepository } from '../service/DiaryRepository';
import { EmptyState } from '../components/EmptyState';
import { getMoodOption } from '../utils/MoodConfig';

@Component
export struct DiaryDetail {
  navPathStack?: NavPathStack;
  id: number = 0;
  @State diary?: DiaryRecord;

  aboutToAppear(): void {
    this.loadDiary();
  }

  private context(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  private async loadDiary(): Promise<void> {
    this.diary = await diaryRepository.getDiaryById(this.context(), this.id);
  }

  build() {
    Column() {
      if (!this.diary) {
        EmptyState({ title: '未找到日记', message: '这篇日记可能已经被删除。' })
      } else {
        Scroll() {
          Column({ space: 18 }) {
            Row() {
              Column({ space: 8 }) {
                Text(this.diary.title.length > 0 ? this.diary.title : '无标题日记')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#0F172A')
                Text(this.diary.date)
                  .fontSize(13)
                  .fontColor('#64748B')
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Button('编辑')
                .height(38)
                .backgroundColor('#E2E8F0')
                .fontColor('#0F172A')
                .onClick(() => this.navPathStack?.pushPath({ name: 'DiaryEditor', param: { id: this.diary!.id, date: this.diary!.date } }))
            }
            .width('100%')

            Text(`${getMoodOption(this.diary.mood).icon} ${getMoodOption(this.diary.mood).label}`)
              .fontSize(14)
              .fontColor(getMoodOption(this.diary.mood).textColor)
              .padding({ left: 14, right: 14, top: 10, bottom: 10 })
              .backgroundColor(getMoodOption(this.diary.mood).color)
              .borderRadius(18)

            Text(this.diary.content)
              .fontSize(16)
              .lineHeight(28)
              .fontColor('#1E293B')
              .width('100%')
              .textAlign(TextAlign.Start)

            if (this.diary.imagePaths.length > 0) {
              Column({ space: 12 }) {
                Text('配图')
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                ForEach(this.diary.imagePaths, (path: string) => {
                  Image(path)
                    .width('100%')
                    .height(220)
                    .borderRadius(24)
                    .objectFit(ImageFit.Cover)
                })
              }
              .width('100%')
            }
          }
          .padding(20)
          .alignItems(HorizontalAlign.Start)
        }
        .scrollBar(BarState.Off)
      }
    }
    .padding(20)
    .width('100%')
    .height('100%')
  }
}
