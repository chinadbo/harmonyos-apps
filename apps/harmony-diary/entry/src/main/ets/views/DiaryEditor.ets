import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { DiaryMood } from '../model/DiaryModel';
import { diaryRepository } from '../service/DiaryRepository';
import { imageService } from '../service/ImageService';
import { MoodPicker } from '../components/MoodPicker';
import { createEmptyDraft } from '../model/DiaryModel';
import { todayKey } from '../utils/DateUtils';

@Component
export struct DiaryEditor {
  navPathStack?: NavPathStack;
  diaryId?: number;
  initialDate: string = todayKey();
  @State title: string = '';
  @State content: string = '';
  @State mood: DiaryMood = DiaryMood.Calm;
  @State date: string = todayKey();
  @State imagePaths: string[] = [];
  @State loading: boolean = false;

  aboutToAppear(): void {
    this.date = this.initialDate;
    this.loadExistingDiary();
  }

  private context(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  private async loadExistingDiary(): Promise<void> {
    if (this.diaryId) {
      const record = await diaryRepository.getDiaryById(this.context(), this.diaryId);
      if (record) {
        this.title = record.title;
        this.content = record.content;
        this.mood = record.mood;
        this.date = record.date;
        this.imagePaths = record.imagePaths;
      }
      return;
    }

    const existing = await diaryRepository.getDiaryByDate(this.context(), this.date);
    if (!existing) {
      const draft = createEmptyDraft(this.date);
      this.title = draft.title;
      this.content = draft.content;
      this.mood = draft.mood;
      this.imagePaths = draft.imagePaths;
      return;
    }
    this.diaryId = existing.id;
    this.title = existing.title;
    this.content = existing.content;
    this.mood = existing.mood;
    this.imagePaths = existing.imagePaths;
  }

  private async addImages(): Promise<void> {
    const copied = await imageService.pickAndCopyImages(this.context());
    this.imagePaths = [...this.imagePaths, ...copied];
  }

  private async saveDiary(): Promise<void> {
    if (this.loading) {
      return;
    }
    this.loading = true;
    try {
      const id = await diaryRepository.saveDiary(this.context(), {
        id: this.diaryId,
        title: this.title,
        content: this.content,
        mood: this.mood,
        date: this.date,
        imagePaths: this.imagePaths
      });
      this.diaryId = id;
      AppStorage.setOrCreate('diary_refresh_token', Date.now());
      promptAction.showToast({ message: '已加密保存' });
      this.navPathStack?.pop();
    } finally {
      this.loading = false;
    }
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Text('编辑日记')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
          Blank()
          Text(this.date)
            .fontSize(13)
            .fontColor('#64748B')
        }
        .width('100%')

        Column({ space: 12 }) {
          TextInput({ placeholder: '标题', text: this.title })
            .height(52)
            .backgroundColor('#F8FAFC')
            .borderRadius(18)
            .fontSize(18)
            .onChange((value: string) => this.title = value)
          TextArea({ placeholder: '今天发生了什么？写下你的感受吧。', text: this.content })
            .height(220)
            .backgroundColor('#F8FAFC')
            .borderRadius(24)
            .fontSize(16)
            .onChange((value: string) => this.content = value)
        }
        .width('100%')

        Column({ space: 12 }) {
          Text('现在的心情')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .width('100%')
          MoodPicker({ value: this.mood, onChange: (value: DiaryMood) => this.mood = value })
        }
        .width('100%')

        Column({ space: 12 }) {
          Row() {
            Text('日记配图')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Blank()
            Button('添加图片')
              .height(38)
              .backgroundColor('#E2E8F0')
              .fontColor('#0F172A')
              .onClick(() => this.addImages())
          }
          .width('100%')

          if (this.imagePaths.length === 0) {
            Text('尚未添加图片，选图后会立即复制到应用沙箱。')
              .fontSize(13)
              .fontColor('#64748B')
          } else {
            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.imagePaths, (path: string) => {
                  Image(path)
                    .width(108)
                    .height(108)
                    .borderRadius(20)
                    .objectFit(ImageFit.Cover)
                })
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
          }
        }
        .width('100%')

        Button(this.loading ? '保存中...' : '保存加密日记')
          .width('100%')
          .height(52)
          .backgroundColor('#0F172A')
          .fontColor('#FFFFFF')
          .enabled(!this.loading)
          .onClick(() => this.saveDiary())
      }
      .padding(20)
      .alignItems(HorizontalAlign.Start)
    }
    .scrollBar(BarState.Off)
  }
}
