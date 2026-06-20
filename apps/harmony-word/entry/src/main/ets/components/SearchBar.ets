@Component
export struct SearchBar {
  @Link keyword: string
  placeholder: string = '搜索汉字、词语或成语'
  onChangeAction: (value: string) => void = () => {}
  onSearchAction: (value: string) => void = () => {}

  build() {
    Search({ value: this.keyword, placeholder: this.placeholder })
      .width('100%')
      .height(44)
      .backgroundColor('#F4F6F8')
      .borderRadius(18)
      .onChange((value: string) => {
        this.keyword = value
        this.onChangeAction(value)
      })
      .onSubmit((value: string) => {
        this.onSearchAction(value)
      })
  }
}
