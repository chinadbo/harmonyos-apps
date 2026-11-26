/**
 * TagEditor.ets — 标签编辑（逗号分隔字符串 ↔ 芯片列表）
 */
import { Format } from '../common/Format';
import { C_BRAND, C_SUB, C_LINE, C_CARD, C_TEXT } from '../common/Constants';

@Component
export struct TagEditor {
  @Prop @Watch('syncFromProp') tags: string = '';
  @State list: string[] = [];
  @State input: string = '';
  onChange: (tags: string) => void = (tags: string) => {};

  aboutToAppear(): void {
    this.syncFromProp();
  }

  syncFromProp(): void {
    const parsed: string[] = Format.parseTags(this.tags);
    if (parsed.join(',') !== this.list.join(',')) {
      this.list = parsed;
    }
  }

  private commit(next: string[]): void {
    this.list = next;
    this.onChange(Format.joinTags(next));
  }

  private addTag(): void {
    const value: string = this.input.trim();
    if (value.length === 0) {
      return;
    }
    if (this.list.indexOf(value) >= 0) {
      this.input = '';
      return;
    }
    const next: string[] = this.list.slice();
    next.push(value);
    this.commit(next);
    this.input = '';
  }

  private removeTag(index: number): void {
    const next: string[] = this.list.slice();
    next.splice(index, 1);
    this.commit(next);
  }

  build() {
    Column() {
      if (this.list.length > 0) {
        Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
          ForEach(this.list, (tag: string, index: number) => {
            Row() {
              Text(tag)
                .fontSize(12)
                .fontColor(C_TEXT)
              Text('×')
                .fontSize(14)
                .fontColor(C_SUB)
                .margin({ left: 6 })
                .onClick(() => this.removeTag(index))
            }
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .margin({ right: 8, bottom: 8 })
            .borderRadius(14)
            .backgroundColor(C_CARD)
            .border({ width: 1, color: C_LINE })
          }, (tag: string, index: number) => tag + index.toString())
        }
        .width('100%')
      }

      Row() {
        TextInput({ text: this.input, placeholder: '输入标签后添加' })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .backgroundColor(C_CARD)
          .borderRadius(10)
          .border({ width: 1, color: C_LINE })
          .onChange((value: string) => {
            this.input = value;
          })
          .onSubmit(() => this.addTag())
        Button('添加')
          .fontSize(14)
          .fontColor(0xFFFFFF)
          .backgroundColor(C_BRAND)
          .height(40)
          .margin({ left: 8 })
          .borderRadius(10)
          .padding({ left: 16, right: 16 })
          .onClick(() => this.addTag())
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
