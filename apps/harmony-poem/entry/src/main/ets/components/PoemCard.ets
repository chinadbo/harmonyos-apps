import router from '@ohos.router';
import { Poem } from '../model/Poem';

@Component
export struct PoemCard {
  @Prop poem: Poem = {
    id: 0,
    title: '',
    author: '',
    dynasty: '',
    genre: '',
    content: [],
    annotation: [],
    appreciation: '',
    tags: []
  };
  @Prop keyword: string = '';
  @Prop showDelete: boolean = false;
  onDelete: (poemId: number) => void = () => {};

  private getKeyword(): string {
    return this.keyword.trim();
  }

  private isHighlighted(part: string): boolean {
    return this.getKeyword().length > 0 && part === this.getKeyword();
  }

  private splitHighlightedText(text: string): string[] {
    const keyword = this.getKeyword();
    if (!keyword) {
      return [text];
    }
    const parts: string[] = [];
    let rest = text;
    let index = rest.indexOf(keyword);
    while (index >= 0) {
      if (index > 0) {
        parts.push(rest.substring(0, index));
      }
      parts.push(keyword);
      rest = rest.substring(index + keyword.length);
      index = rest.indexOf(keyword);
    }
    if (rest.length > 0) {
      parts.push(rest);
    }
    return parts.length > 0 ? parts : [text];
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 4 }) {
          Text() {
            ForEach(this.splitHighlightedText(this.poem.title), (part: string, index: number) => {
              Span(part)
                .fontColor(this.isHighlighted(part) ? $r('app.color.theme_accent') : $r('app.color.text_primary'))
                .fontWeight(FontWeight.Bold)
            }, (part: string, index: number) => `${part}-${index}`)
          }
          .fontSize(20)
          .width('100%')

          Text() {
            ForEach(this.splitHighlightedText(`${this.poem.dynasty} · ${this.poem.author} · ${this.poem.genre}`), (part: string, index: number) => {
              Span(part)
                .fontColor(this.isHighlighted(part) ? $r('app.color.theme_accent') : $r('app.color.text_secondary'))
                .fontWeight(this.isHighlighted(part) ? FontWeight.Medium : FontWeight.Regular)
            }, (part: string, index: number) => `${part}-${index}`)
          }
          .fontSize(13)
          .width('100%')
        }
        .layoutWeight(1)

        if (this.showDelete) {
          Button('删除')
            .fontSize(12)
            .type(ButtonType.Capsule)
            .backgroundColor($r('app.color.danger'))
            .onClick(() => {
              this.onDelete(this.poem.id);
            })
        }
      }
      .width('100%')

      Text() {
        ForEach(this.splitHighlightedText(this.poem.content.slice(0, 2).join(' ')), (part: string, index: number) => {
          Span(part)
            .fontColor(this.isHighlighted(part) ? $r('app.color.theme_accent') : $r('app.color.text_primary'))
            .fontWeight(this.isHighlighted(part) ? FontWeight.Medium : FontWeight.Regular)
        }, (part: string, index: number) => `${part}-${index}`)
      }
      .fontSize(15)
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .width('100%')

      Row({ space: 8 }) {
        ForEach(this.poem.tags.slice(0, 3), (tag: string) => {
          Text(tag)
            .fontSize(11)
            .fontColor($r('app.color.theme_primary'))
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#F6E7D7')
            .borderRadius(10)
        }, (tag: string) => tag)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface'))
    .borderRadius(18)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/DetailPage',
        params: {
          poemId: this.poem.id
        }
      });
    })
  }
}
