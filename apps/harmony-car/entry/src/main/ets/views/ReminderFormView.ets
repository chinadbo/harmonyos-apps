import { REMINDER_TYPES } from '../utils/Constants';

@Component
export struct ReminderFormView {
  @Link type: string;
  @Link title: string;
  @Link content: string;
  @Link triggerDate: string;
  @Link targetMileageText: string;
  @Link isActive: boolean;

  build() {
    Column({ space: 14 }) {
      Text('提醒类型')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
        ForEach(REMINDER_TYPES, (item: string) => {
          Text(item)
            .fontSize(13)
            .fontColor(this.type === item ? '#FFFFFF' : '#4E7BF2')
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.type === item ? '#4E7BF2' : '#EAF0FF')
            .borderRadius(14)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.type = item;
            })
        })
      }
      .width('100%')
      TextInput({ text: this.title, placeholder: '提醒标题' })
        .onChange((value: string) => { this.title = value; })
      TextInput({ text: this.content, placeholder: '提醒内容' })
        .onChange((value: string) => { this.content = value; })
      TextInput({ text: this.triggerDate, placeholder: '提醒日期 YYYY-MM-DD' })
        .onChange((value: string) => { this.triggerDate = value; })
      TextInput({ text: this.targetMileageText, placeholder: '目标里程（可选）' })
        .type(InputType.Number)
        .onChange((value: string) => { this.targetMileageText = value; })
      Row() {
        Text('启用提醒')
          .layoutWeight(1)
          .fontSize(15)
          .fontColor('#1F2D3D')
        Toggle({ type: ToggleType.Switch, isOn: this.isActive })
          .onChange((value: boolean) => { this.isActive = value; })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F6F8FB')
      .borderRadius(16)
    }
    .width('100%')
  }
}
