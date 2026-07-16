import { Constants } from '../utils/Constants';

@Component
export struct AddressBar {
  @State urlInput: string = '';
  @Prop currentUrl: string = '';
  onGo: (url: string) => void = () => {};

  aboutToAppear() {
    this.urlInput = this.currentUrl;
  }

  build() {
    Row() {
      TextInput({ placeholder: '请输入网址或搜索关键词', text: $$this.urlInput })
        .width('80%')
        .height(40)
        .fontSize(14)
        .backgroundColor('#f0f0f0')
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .onSubmit(() => {
          let url = this.urlInput.trim();
          if (url.length === 0) return;
          if (!url.startsWith('http://') && !url.startsWith('https://')) {
            if (url.includes('.') && !url.includes(' ')) {
              url = 'https://' + url;
            } else {
              url = Constants.DEFAULT_SEARCH_ENGINE + encodeURIComponent(url);
            }
          }
          this.onGo(url);
        })

      Button('GO')
        .width(48)
        .height(36)
        .fontSize(12)
        .backgroundColor('#2196F3')
        .onClick(() => {
          let url = this.urlInput.trim();
          if (url.length === 0) return;
          if (!url.startsWith('http://') && !url.startsWith('https://')) {
            if (url.includes('.') && !url.includes(' ')) {
              url = 'https://' + url;
            } else {
              url = Constants.DEFAULT_SEARCH_ENGINE + encodeURIComponent(url);
            }
          }
          this.onGo(url);
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 8 })
    .backgroundColor('#ffffff')
  }
}
