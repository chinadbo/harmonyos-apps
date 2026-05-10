@Component
export struct ReaderToolbar {
  @Prop onCatalogClick: () => void;
  @Prop onBookmarkClick: () => void;
  @Prop onThemeClick: () => void;

  build() {
    Row({ space: 20 }) {
      this.buildToolButton('目录', this.onCatalogClick);
      this.buildToolButton('书签', this.onBookmarkClick);
      this.buildToolButton('设置', this.onThemeClick);
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ left: 20, right: 20, top: 14, bottom: 24 })
    .backgroundColor('#CCFFFFFF')
  }

  @Builder
  private buildToolButton(label: string, handler: () => void) {
    Button(label)
      .type(ButtonType.Capsule)
      .backgroundColor('#5B8FF9')
      .fontColor(Color.White)
      .onClick(() => handler())
  }
}
