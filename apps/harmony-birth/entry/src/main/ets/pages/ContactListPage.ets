import router from '@ohos.router';
import { Contact } from '../model/Contact';
import { ContactDao } from '../database/ContactDao';
import { DateUtils } from '../utils/DateUtils';
import { BirthdayCard } from '../components/BirthdayCard';
import { EmptyState } from '../components/EmptyState';

@Component
struct ContactListPage {
  @State contacts: Contact[] = [];
  @State keyword: string = '';

  aboutToAppear(): void {
    this.loadContacts();
  }

  private async loadContacts(): Promise<void> {
    let context = getContext(this);
    let contacts = await ContactDao.getAll(context);
    this.contacts = DateUtils.sortContactsByUpcoming(contacts).map(item => item.contact);
  }

  private getFilteredContacts(): Contact[] {
    if (!this.keyword.trim()) {
      return this.contacts;
    }
    return this.contacts.filter((contact: Contact) => {
      return contact.name.indexOf(this.keyword) >= 0 || contact.relation.indexOf(this.keyword) >= 0;
    });
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('联系人生日档案')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        Button('新增')
          .height(40)
          .backgroundColor('#FF7A59')
          .onClick(() => router.pushUrl({ url: 'pages/AddContactPage' }))
      }
      .width('100%')

      TextInput({ placeholder: '搜索姓名或关系', text: this.keyword })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .onChange((value: string) => this.keyword = value)

      if (this.getFilteredContacts().length === 0) {
        EmptyState({
          title: '没有匹配的联系人',
          description: '试试更短的关键词，或先新增一位联系人。'
        })
      } else {
        List({ space: 12 }) {
          ForEach(this.getFilteredContacts(), (contact: Contact) => {
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
        .divider({ strokeWidth: 0 })
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }
}
