import { Contact } from '../model/Contact';
import { ContactDao } from '../database/ContactDao';
import { DateUtils, CalendarSection } from '../utils/DateUtils';
import { EmptyState } from '../components/EmptyState';

@Component
struct CalendarPage {
  @State sections: CalendarSection[] = [];

  async aboutToAppear(): Promise<void> {
    let context = getContext(this);
    let contacts: Contact[] = await ContactDao.getAll(context);
    this.sections = DateUtils.buildCalendarSections(contacts);
  }

  build() {
    Column({ space: 16 }) {
      Text('生日日历')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      if (this.sections.length === 0) {
        EmptyState({
          title: '还没有生日数据',
          description: '添加联系人后，这里会按月份展示最近生日。'
        })
      } else {
        List({ space: 16 }) {
          ForEach(this.sections, (section: CalendarSection) => {
            ListItem() {
              Column({ space: 12 }) {
                Text(section.month)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .width('100%')
                Column({ space: 10 }) {
                  ForEach(section.items, (item) => {
                    Row() {
                      Column({ space: 4 }) {
                        Text(item.contact.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                        Text(`${DateUtils.formatMonthDay(item.contact.birthday)} · ${item.contact.relation || '未设置关系'}`)
                          .fontSize(13)
                          .fontColor('#6B7280')
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                      Text(DateUtils.formatCountdown(item.daysUntil))
                        .fontSize(14)
                        .fontColor('#C2410C')
                        .backgroundColor('#FFF1ED')
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .borderRadius(14)
                    }
                    .width('100%')
                    .padding(14)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(18)
                  }, (item) => `${item.contact.id}`)
                }
                .width('100%')
              }
            }
          }, (section: CalendarSection) => section.month)
        }
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }
}
