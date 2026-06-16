import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Contact } from '../model/Contact';
import { Gift, GiftRecord } from '../model/Gift';
import { ContactDao } from '../database/ContactDao';
import { GiftDao } from '../database/GiftDao';
import { DateUtils } from '../utils/DateUtils';
import { NotificationUtils } from '../utils/NotificationUtils';
import { GiftItem } from '../components/GiftItem';
import { EmptyState } from '../components/EmptyState';

@Component
struct ContactDetailPage {
  @StorageProp('selectedContactId') selectedContactId: number = 0;
  @State contact: Contact | null = null;
  @State gifts: Gift[] = [];
  @State giftName: string = '';
  @State giftPrice: string = '';
  @State giftUrl: string = '';
  @State giftNote: string = '';

  async aboutToAppear(): Promise<void> {
    await this.loadData();
  }

  private async loadData(): Promise<void> {
    if (!this.selectedContactId) {
      return;
    }
    let context = getContext(this);
    this.contact = await ContactDao.getById(context, this.selectedContactId);
    this.gifts = await GiftDao.getByContactId(context, this.selectedContactId);
  }

  private async addGift(): Promise<void> {
    if (!this.contact?.id) {
      return;
    }
    if (!this.giftName.trim()) {
      promptAction.showToast({ message: '请输入礼物名称' });
      return;
    }
    let context = getContext(this);
    await GiftDao.insert(context, new GiftRecord({
      contactId: this.contact.id,
      name: this.giftName.trim(),
      price: this.giftPrice.trim() ? Number(this.giftPrice) : 0,
      url: this.giftUrl.trim(),
      note: this.giftNote.trim(),
      status: 'pending',
      createdAt: Date.now()
    }));
    this.giftName = '';
    this.giftPrice = '';
    this.giftUrl = '';
    this.giftNote = '';
    await this.loadData();
    promptAction.showToast({ message: '礼物已加入心愿单' });
  }

  private async toggleGift(gift: Gift): Promise<void> {
    let context = getContext(this);
    await GiftDao.updateStatus(context, gift.id ?? 0, gift.status === 'sent' ? 'pending' : 'sent');
    await this.loadData();
  }

  private async deleteGift(gift: Gift): Promise<void> {
    let context = getContext(this);
    await GiftDao.remove(context, gift.id ?? 0);
    await this.loadData();
  }

  private async deleteContact(): Promise<void> {
    if (!this.contact?.id) {
      return;
    }
    let context = getContext(this);
    await NotificationUtils.cancelContactReminders(this.contact.id);
    await GiftDao.removeByContactId(context, this.contact.id);
    await ContactDao.remove(context, this.contact.id);
    AppStorage.setOrCreate('contactListRefreshToken', Date.now());
    promptAction.showToast({ message: '联系人已删除' });
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        if (this.contact) {
          Column({ space: 14 }) {
            Row() {
              Row() {
                Text(this.contact!.name.substring(0, 1))
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
              }
              .width(64)
              .height(64)
              .borderRadius(32)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.contact!.avatarColor)
              .margin({ right: 14 })

              Column({ space: 6 }) {
                Text(this.contact!.name)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                Text(this.contact!.relation || '未设置关系')
                  .fontSize(14)
                  .fontColor('#6B7280')
                Text(`${DateUtils.formatMonthDay(this.contact!.birthday)} · ${DateUtils.formatCountdown(DateUtils.getDaysUntilBirthday(this.contact!.birthday))}`)
                  .fontSize(14)
                  .fontColor('#C2410C')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }

            Text(`提醒设置：${DateUtils.buildReminderLabel(this.contact!.reminderDays)}`)
              .fontSize(14)
              .fontColor('#4B5563')
            if (this.contact!.note.length > 0) {
              Text(this.contact!.note)
                .fontSize(14)
                .fontColor('#4B5563')
                .width('100%')
            }
          }
          .width('100%')
          .padding(18)
          .backgroundColor('#FFFFFF')
          .borderRadius(22)

          Column({ space: 12 }) {
            Row() {
              Text('礼物心愿单')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
              Button('删除联系人')
                .height(36)
                .backgroundColor('#FEE2E2')
                .fontColor('#B91C1C')
                .onClick(() => this.deleteContact())
            }
            .width('100%')

            this.buildGiftField('礼物名称', '例如 香薰礼盒', this.giftName, (value: string) => this.giftName = value)
            this.buildGiftField('预算价格', '例如 199', this.giftPrice, (value: string) => this.giftPrice = value)
            this.buildGiftField('商品链接', '可选 URL', this.giftUrl, (value: string) => this.giftUrl = value)
            this.buildGiftField('备注', '颜色、规格、购买渠道等', this.giftNote, (value: string) => this.giftNote = value)

            Button('添加礼物')
              .width('100%')
              .height(42)
              .backgroundColor('#FF7A59')
              .onClick(() => this.addGift())

            if (this.gifts.length === 0) {
              EmptyState({
                title: '暂无礼物记录',
                description: '先记下对方最近想要的礼物和预算。'
              })
            } else {
              Column({ space: 10 }) {
                ForEach(this.gifts, (gift: Gift) => {
                  GiftItem({
                    gift,
                    onToggle: async (item: Gift) => await this.toggleGift(item),
                    onDelete: async (item: Gift) => await this.deleteGift(item)
                  })
                }, (gift: Gift) => `${gift.id}`)
              }
              .width('100%')
            }
          }
          .width('100%')
        } else {
          EmptyState({
            title: '未找到联系人',
            description: '请先从联系人列表进入详情页。'
          })
        }
      }
      .padding(16)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }

  @Builder
  private buildGiftField(title: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(15)
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
