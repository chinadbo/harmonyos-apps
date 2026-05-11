import { DiaryMood } from '../model/DiaryModel';
import { getMoodOptions } from '../utils/MoodConfig';

@Component
export struct MoodPicker {
  @Prop value: DiaryMood = DiaryMood.Calm;
  onChange: (value: DiaryMood) => void = () => {};

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
      ForEach(getMoodOptions(), (item) => {
        Column({ space: 6 }) {
          Text(item.icon)
            .fontSize(20)
          Text(item.label)
            .fontSize(12)
            .fontColor(this.value === item.mood ? item.textColor : '#475569')
        }
        .width('28%')
        .padding({ top: 14, bottom: 14 })
        .margin({ right: '4%', bottom: 12 })
        .backgroundColor(this.value === item.mood ? item.color : '#F8FAFC')
        .borderRadius(18)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => this.onChange(item.mood))
      })
    }
    .width('100%')
  }
}
