import { LANGUAGES, getLanguageName } from '../model/Language';

@Component
export struct LanguageSelector {
  @Prop selectedCode: string;
  @Prop label: string;
  onSelect: (code: string) => void = () => {};

  build() {
    Column() {
      Text(this.label)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 4 })

      Select(LANGUAGES.map(l => ({ value: `${l.flag} ${l.name}` })))
        .selected(this.getSelectedIndex())
        .value(`${this.getFlag()} ${getLanguageName(this.selectedCode)}`)
        .font({ size: 16, weight: FontWeight.Medium })
        .fontColor('#333333')
        .backgroundColor('#F5F5F5')
        .optionFont({ size: 14 })
        .optionBgColor('#FFFFFF')
        .selectedOptionBgColor('#4A90D9')
        .selectedOptionFontColor('#FFFFFF')
        .onSelect((index: number) => {
          this.onSelect(LANGUAGES[index].code);
        })
        .width('100%')
        .height(44)
    }
    .width('40%')
    .alignItems(HorizontalAlign.Start)
  }

  private getSelectedIndex(): number {
    return LANGUAGES.findIndex(l => l.code === this.selectedCode);
  }

  private getFlag(): string {
    const lang = LANGUAGES.find(l => l.code === this.selectedCode);
    return lang ? lang.flag : '🌐';
  }
}
