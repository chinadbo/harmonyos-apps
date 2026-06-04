import { MAINTENANCE_TYPES } from '../utils/Constants';

@Component
export struct RecordFormView {
  @Link type: string;
  @Link date: string;
  @Link mileageText: string;
  @Link costText: string;
  @Link shop: string;
  @Link note: string;
  @Link nextDate: string;
  @Link nextMileageText: string;

  build() {
    Column({ space: 14 }) {
      Text('保养类型')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
        ForEach(MAINTENANCE_TYPES, (item: string) => {
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

      TextInput({ text: this.date, placeholder: '保养日期 YYYY-MM-DD' })
        .onChange((value: string) => { this.date = value; })
      TextInput({ text: this.mileageText, placeholder: '当时里程' })
        .type(InputType.Number)
        .onChange((value: string) => { this.mileageText = value; })
      TextInput({ text: this.costText, placeholder: '费用（元）' })
        .type(InputType.Number)
        .onChange((value: string) => { this.costText = value; })
      TextInput({ text: this.shop, placeholder: '服务门店' })
        .onChange((value: string) => { this.shop = value; })
      TextInput({ text: this.note, placeholder: '备注' })
        .onChange((value: string) => { this.note = value; })
      TextInput({ text: this.nextDate, placeholder: '下次日期 YYYY-MM-DD' })
        .onChange((value: string) => { this.nextDate = value; })
      TextInput({ text: this.nextMileageText, placeholder: '下次里程' })
        .type(InputType.Number)
        .onChange((value: string) => { this.nextMileageText = value; })
    }
    .width('100%')
  }
}
