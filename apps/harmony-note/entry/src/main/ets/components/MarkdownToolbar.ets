@Component
export struct MarkdownToolbar {
  onInsert?: (value: string) => void;

  private actions: Array<{ label: string, value: string }> = [
    { label: 'H1', value: '# ' },
    { label: 'H2', value: '## ' },
    { label: '粗体', value: '**加粗文本**' },
    { label: '斜体', value: '*斜体文本*' },
    { label: '列表', value: '- 列表项' },
    { label: '代码', value: '```\n代码块\n```' },
    { label: '引用', value: '> 引用内容' },
    { label: '分隔线', value: '---' }
  ];

  build() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(this.actions, (item: { label: string, value: string }) => {
          Button(item.label)
            .type(ButtonType.Capsule)
            .backgroundColor('#EEF2FF')
            .fontColor('#1D4ED8')
            .fontSize(13)
            .onClick(() => {
              if (this.onInsert) {
                this.onInsert(item.value);
              }
            })
        }, (item: { label: string, value: string }) => item.label)
      }
      .padding({ left: 4, right: 4 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }
}
