import { Token, Tokenizer, TokenType } from './Tokenizer';

/** 不同 token 类型对应的着色 */
function tokenColor(type: TokenType): string {
  if (type === TokenType.Keyword) {
    return '#C678DD';
  }
  if (type === TokenType.String) {
    return '#98C379';
  }
  if (type === TokenType.Comment) {
    return '#7F848E';
  }
  if (type === TokenType.Number) {
    return '#D19A66';
  }
  if (type === TokenType.Function) {
    return '#61AFEF';
  }
  return '#E6E6E6';
}

/** HTML 转义，并把换行、空格转为可保留格式的实体 */
function escapeHtml(text: string): string {
  let s = text;
  s = s.split('&').join('&amp;');
  s = s.split('<').join('&lt;');
  s = s.split('>').join('&gt;');
  s = s.split('\n').join('<br/>');
  s = s.split('\t').join('&nbsp;&nbsp;&nbsp;&nbsp;');
  s = s.split(' ').join('&nbsp;');
  return s;
}

/**
 * 代码高亮组件
 * 通过 Tokenizer 切分代码并用 RichText 混排着色
 */
@Component
export struct CodeView {
  @Prop @Watch('rebuild') code: string = '';
  @Prop @Watch('rebuild') language: string = 'arkts';
  @State html: string = '';

  aboutToAppear(): void {
    this.rebuild();
  }

  rebuild(): void {
    const tokens: Token[] = Tokenizer.tokenize(this.code, this.language);
    let html = '';
    for (let i = 0; i < tokens.length; i++) {
      const t = tokens[i];
      html += '<span style="color:' + tokenColor(t.type) + ';font-size:13px;line-height:22px;">' +
        escapeHtml(t.text) + '</span>';
    }
    this.html = html;
  }

  build() {
    Scroll() {
      RichText(this.html)
        .width('100%')
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .padding(14)
    .backgroundColor('#282C34')
    .borderRadius(12)
  }
}
