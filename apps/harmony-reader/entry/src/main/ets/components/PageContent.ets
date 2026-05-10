import { ChapterInfo, ThemeKey } from '../model/BookInfo';

@Component
export struct PageContent {
  @Prop chapter: ChapterInfo;
  @StorageProp('readerTheme') theme: ThemeKey = 'light';
  @StorageProp('readerFontSize') fontSize: number = 18;
  @Prop onToggleBars: () => void;

  private getBackgroundColor(): string {
    if (this.theme === 'dark') {
      return '#1E1F22';
    }
    if (this.theme === 'eye') {
      return '#EAF4E1';
    }
    return '#F7F4ED';
  }

  private getTextColor(): string {
    return this.theme === 'dark' ? '#F4F4F4' : '#2B2B2B';
  }

  build() {
    List() {
      ListItem() {
        Text(this.chapter.title)
          .fontSize(this.fontSize + 4)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTextColor())
          .margin({ top: 8, bottom: 16 })
      }
      ForEach(this.chapter.getParagraphs(), (paragraph: string, idx: number) => {
        ListItem() {
          Text(paragraph)
            .fontSize(this.fontSize)
            .lineHeight(this.fontSize * 2)
            .fontColor(this.getTextColor())
            .textIndent(2 * this.fontSize)
        }
        .margin({ bottom: 18 })
      }, (paragraph: string, idx: number) => `${idx}`)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 12, bottom: 12 })
    .backgroundColor(this.getBackgroundColor())
    .onClick(() => this.onToggleBars())
  }
}
