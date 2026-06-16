import router from '@ohos.router';
import { Contact } from '../model/Contact';
import { ContactDao } from '../database/ContactDao';
import { DateUtils } from '../utils/DateUtils';
import { BirthdayCard } from '../components/BirthdayCard';
import { EmptyState } from '../components/EmptyState';

@Entry
@Component
struct Index {
  @State contacts: Contact[] = [];
  @State refreshing: boolean = false;

  aboutToAppear(): void {
    this.loadContacts();
  }

  private async loadContacts(): Promise<void> {
    this.refreshing = true;
    let context = getContext(this);
    let contacts = await ContactDao.getAll(context);
    this.contacts = DateUtils.sortContactsByUpcoming(contacts).map(item => item.contact);
    this.refreshing = false;
  }

  private openPage(url: string): void {
    router.pushUrl({ url });
  }

  build() {
    Column({ space: 18 }) {
      Row() {
        Column({ space: 6 }) {
          Text('HarmonyBirth')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
          Text('生日提醒、礼物清单与祝福模板都在这里')
            .fontSize(14)
            .fontColor('#6B7280')
        }
        .layoutWeight(1)
        Button('新增联系人')
          .height(42)
          .backgroundColor('#FF7A59')
          .onClick(() => this.openPage('pages/AddContactPage'))
      }
      .width('100%')

      Row({ space: 12 }) {
        this.buildStatCard('联系人', `${this.contacts.length}`)
        this.buildStatCard('最近生日', this.contacts.length > 0 ? DateUtils.formatCountdown(DateUtils.getDaysUntilBirthday(this.contacts[0].birthday)) : '--')
      }
      .width('100%')

      Row({ space: 10 }) {
        this.buildQuickAction('联系人', 'pages/ContactListPage')
        this.buildQuickAction('模板', 'pages/TemplatePage')
        this.buildQuickAction('日历', 'pages/CalendarPage')
        this.buildQuickAction('设置', 'pages/SettingsPage')
      }
      .width('100%')

      Text('即将到来的生日')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      if (this.contacts.length === 0) {
        EmptyState({
          title: '还没有生日档案',
          description: '先添加联系人，系统会自动计算倒计时并安排提醒。',
          actionText: '立即添加',
          onAction: () => this.openPage('pages/AddContactPage')
        })
      } else {
        List({ space: 12 }) {
          ForEach(this.contacts.slice(0, 6), (contact: Contact) => {
            ListItem() {
              BirthdayCard({
                contact,
                onClick: (item: Contact) => {
                  AppStorage.setOrCreate('selectedContactId', item.id ?? 0);
                  router.pushUrl({ url: 'pages/ContactDetailPage' });
                }
              })
            }
          }, (contact: Contact) => `${contact.id}`)
        }
        .layoutWeight(1)
        .width('100%')
        .divider({ strokeWidth: 0 })
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }

  @Builder
  private buildStatCard(title: string, value: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontColor('#6B7280')
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }

  @Builder
  private buildQuickAction(title: string, url: string) {
    Button(title)
      .layoutWeight(1)
      .height(42)
      .backgroundColor('#FFFFFF')
      .fontColor('#374151')
      .onClick(() => this.openPage(url))
  }
}
