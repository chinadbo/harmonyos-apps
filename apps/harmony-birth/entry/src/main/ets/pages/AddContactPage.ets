import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ContactRecord } from '../model/Contact';
import { ContactDao } from '../database/ContactDao';
import { DateUtils } from '../utils/DateUtils';
import { NotificationUtils } from '../utils/NotificationUtils';

@Component
struct AddContactPage {
  @State name: string = '';
  @State relation: string = '';
  @State birthday: string = '';
  @State birthdayYear: string = '';
  @State avatarColor: string = '#FF7A59';
  @State note: string = '';
  @State reminderDays: number[] = [1, 3, 7];
  private readonly colorOptions: string[] = ['#FF7A59', '#6366F1', '#14B8A6', '#EC4899', '#F59E0B', '#10B981'];
  private readonly reminderOptions: number[] = [1, 3, 7, 30];

  private toggleReminder(day: number): void {
    if (this.reminderDays.indexOf(day) >= 0) {
      this.reminderDays = this.reminderDays.filter(item => item !== day);
      return;
    }
    this.reminderDays = [...this.reminderDays, day].sort((a, b) => a - b);
  }

  private async saveContact(): Promise<void> {
    if (!this.name.trim()) {
      promptAction.showToast({ message: '请输入姓名' });
      return;
    }
    if (!DateUtils.validateBirthday(this.birthday)) {
      promptAction.showToast({ message: '请输入正确的生日，格式为 MM-DD' });
      return;
    }
    if (this.reminderDays.length === 0) {
      promptAction.showToast({ message: '至少选择一个提醒时间' });
      return;
    }
    let contact = new ContactRecord({
      name: this.name.trim(),
      relation: this.relation.trim(),
      birthday: DateUtils.normalizeBirthday(this.birthday),
      birthdayYear: this.birthdayYear.trim() ? Number(this.birthdayYear) : 0,
      avatarColor: this.avatarColor,
      reminderDays: this.reminderDays,
      note: this.note.trim(),
      createdAt: Date.now()
    });
    let context = getContext(this);
    let id = await ContactDao.insert(context, contact);
    contact.id = id;
    await NotificationUtils.syncContactReminders(contact);
    AppStorage.setOrCreate('contactListRefreshToken', Date.now());
    promptAction.showToast({ message: '联系人已保存' });
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('新增联系人')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')

        this.buildField('姓名', '请输入姓名', this.name, (value: string) => this.name = value)
        this.buildField('关系', '如 家人、朋友、同事', this.relation, (value: string) => this.relation = value)
        this.buildField('生日', 'MM-DD，例如 08-17', this.birthday, (value: string) => this.birthday = value)
        this.buildField('出生年份', '可选，例如 1996', this.birthdayYear, (value: string) => this.birthdayYear = value)
        this.buildField('备注', '可记录喜好、禁忌等', this.note, (value: string) => this.note = value)

        Column({ space: 10 }) {
          Text('头像色')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Row({ space: 12 }) {
            ForEach(this.colorOptions, (color: string) => {
              Row() {}
                .width(34)
                .height(34)
                .borderRadius(17)
                .backgroundColor(color)
                .border({ width: this.avatarColor === color ? 3 : 0, color: '#111827' })
                .onClick(() => this.avatarColor = color)
            })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Column({ space: 10 }) {
          Text('提醒时间')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Row({ space: 10 }) {
            ForEach(this.reminderOptions, (day: number) => {
              Text(`${day}天前`)
                .fontSize(14)
                .fontColor(this.reminderDays.indexOf(day) >= 0 ? '#FFFFFF' : '#374151')
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.reminderDays.indexOf(day) >= 0 ? '#FF7A59' : '#F3F4F6')
                .borderRadius(16)
                .onClick(() => this.toggleReminder(day))
            })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)

        Button('保存联系人')
          .width('100%')
          .height(46)
          .backgroundColor('#FF7A59')
          .onClick(() => this.saveContact())
      }
      .padding(16)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }

  @Builder
  private buildField(title: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
      TextInput({ placeholder, text: value })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .onChange(onChange)
    }
    .width('100%')
  }
}
