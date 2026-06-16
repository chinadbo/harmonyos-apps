import { Contact } from '../model/Contact';
import { DateUtils } from '../utils/DateUtils';
import { CountdownBadge } from './CountdownBadge';

@Component
export struct BirthdayCard {
  @Prop contact: Contact;
  onClick?: (contact: Contact) => void;

  build() {
    Row() {
      Row() {
        Text(this.contact.name.substring(0, 1))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width(52)
      .height(52)
      .borderRadius(26)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.contact.avatarColor)
      .margin({ right: 14 })

      Column({ space: 6 }) {
        Row() {
          Text(this.contact.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
          if (this.contact.relation.length > 0) {
            Text(this.contact.relation)
              .fontSize(12)
              .fontColor('#6B7280')
              .backgroundColor('#F3F4F6')
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(10)
              .margin({ left: 8 })
          }
        }

        Text(DateUtils.formatMonthDay(this.contact.birthday))
          .fontSize(14)
          .fontColor('#4B5563')

        Row({ space: 8 }) {
          CountdownBadge({ label: DateUtils.formatCountdown(DateUtils.getDaysUntilBirthday(this.contact.birthday)) })
          CountdownBadge({
            label: `提醒 ${DateUtils.buildReminderLabel(this.contact.reminderDays)}`,
            backgroundColor: '#EEF2FF',
            textColor: '#4338CA'
          })
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .onClick(() => {
      if (this.onClick) {
        this.onClick(this.contact);
      }
    })
  }
}
