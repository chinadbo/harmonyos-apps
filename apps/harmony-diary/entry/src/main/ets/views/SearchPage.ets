import common from '@ohos.app.ability.common';
import { DiarySearchResult } from '../model/DiaryModel';
import { diaryRepository } from '../service/DiaryRepository';
import { EmptyState } from '../components/EmptyState';
import { getMoodOption } from '../utils/MoodConfig';

@Component
export struct SearchPage {
  navPathStack?: NavPathStack;
  @State keyword: string = '';
  @State results: DiarySearchResult[] = [];

  private context(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  private async runSearch(value: string): Promise<void> {
    this.keyword = value;
    this.results = await diaryRepository.search(this.context(), value);
  }

  build() {
    Column({ space: 18 }) {
      TextInput({ placeholder: '搜索标题或正文前 100 字摘要', text: this.keyword })
        .width('100%')
        .height(52)
        .backgroundColor('#F8FAFC')
        .borderRadius(18)
        .onChange((value: string) => this.runSearch(value))

      if (this.keyword.trim().length === 0) {
        EmptyState({ title: '输入关键词开始搜索', message: '搜索基于 FTS5 摘要索引，不会直接暴露完整明文内容。' })
      } else if (this.results.length === 0) {
        EmptyState({ title: '没有匹配结果', message: '试试标题、情绪相关词，或正文前半段出现过的句子。' })
      } else {
        List({ space: 12 }) {
          ForEach(this.results, (item: DiarySearchResult) => {
            ListItem() {
              Column({ space: 10 }) {
                Row() {
                  Text(item.title)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#0F172A')
                  Blank()
                  Text(getMoodOption(item.mood).label)
                    .fontSize(12)
                    .fontColor(getMoodOption(item.mood).textColor)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(getMoodOption(item.mood).color)
                    .borderRadius(14)
                }
                .width('100%')
                Text(item.date)
                  .fontSize(12)
                  .fontColor('#64748B')
                  .width('100%')
                Text(item.snippet)
                  .fontSize(14)
                  .lineHeight(22)
                  .fontColor('#334155')
                  .width('100%')
              }
              .padding(16)
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(24)
              .onClick(() => this.navPathStack?.pushPath({ name: 'DiaryDetail', param: { id: item.id } }))
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
