import { CareType } from '../model/CareRecord'

@Component
export struct CareButton {
  @Prop label: string = ''
  @Prop careType: CareType = 'water'
  @Prop accentColor: string = '#4CAF50'
  @Prop onTap: (careType: CareType) => void = () => {}

  build() {
    Button(this.label)
      .width('100%')
      .height(40)
      .backgroundColor(this.accentColor)
      .fontColor(Color.White)
      .borderRadius(20)
      .onClick(() => {
        this.onTap(this.careType)
      })
  }
}
