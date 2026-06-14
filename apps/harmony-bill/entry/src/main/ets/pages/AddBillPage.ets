import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Member } from '../model/Member';
import { Bill, BILL_CATEGORIES } from '../model/Bill';
import { MemberDao } from '../database/MemberDao';
import { BillDao } from '../database/BillDao';
import { BillSplitDao } from '../database/BillSplitDao';
import { SettlementDao } from '../database/SettlementDao';
import { GroupDao } from '../database/GroupDao';
import { SettlementCalculator } from '../utils/SettlementCalculator';
import { FormatUtils } from '../utils/FormatUtils';

interface AddBillParams {
  groupId: number;
}

@Entry
@Component
struct AddBillPage {
  private memberDao: MemberDao = new MemberDao();
  private billDao: BillDao = new BillDao();
  private billSplitDao: BillSplitDao = new BillSplitDao();
  private settlementDao: SettlementDao = new SettlementDao();
  private groupDao: GroupDao = new GroupDao();

  @State private groupId: number = 0;
  @State private members: Member[] = [];
  @State private title: string = '';
  @State private amountInput: string = '';
  @State private payerIndex: number = 0;
  @State private categoryIndex: number = 0;
  @State private splitTypeIndex: number = 0;
  @State private note: string = '';
  @State private customAmounts: string[] = [];
  @State private saving: boolean = false;

  private categoryOptions: SelectOption[] = BILL_CATEGORIES.map((item: string) => ({ value: item }));
  private splitOptions: SelectOption[] = [{ value: '等额分摊' }, { value: '自定义分摊' }];

  aboutToAppear(): void {
    const params = router.getParams() as AddBillParams;
    this.groupId = Number(params.groupId);
    this.loadMembers();
  }

  private async loadMembers(): Promise<void> {
    this.members = await this.memberDao.getByGroupId(this.groupId);
    const defaults: string[] = [];
    this.members.forEach(() => defaults.push('0'));
    this.customAmounts = defaults;
  }

  private updateCustomAmount(index: number, value: string): void {
    const next = this.customAmounts.slice();
    next[index] = value;
    this.customAmounts = next;
  }

  private buildEqualSplits(totalAmount: number): Array<{ memberId: number; amount: number }> {
    const result: Array<{ memberId: number; amount: number }> = [];
    if (this.members.length === 0) {
      return result;
    }
    const average = Math.floor(totalAmount / this.members.length);
    let remainder = totalAmount - average * this.members.length;
    this.members.forEach((member) => {
      const amount = average + (remainder > 0 ? 1 : 0);
      result.push({ memberId: member.id, amount });
      if (remainder > 0) {
        remainder -= 1;
      }
    });
    return result;
  }

  private buildCustomSplits(totalAmount: number): Array<{ memberId: number; amount: number }> | null {
    let sum = 0;
    const result: Array<{ memberId: number; amount: number }> = [];
    this.members.forEach((member, index) => {
      const amount = FormatUtils.parseAmountInput(this.customAmounts[index] ?? '0');
      sum += amount;
      result.push({ memberId: member.id, amount });
    });
    if (sum !== totalAmount) {
      promptAction.showToast({ message: '自定义分摊金额之和必须等于总金额' });
      return null;
    }
    return result;
  }

  private async rebuildSettlements(): Promise<void> {
    const bills = await this.billDao.getPlainByGroupId(this.groupId);
    const billIds = bills.map((item) => item.id);
    const splits = await this.billSplitDao.getPlainByGroupBills(billIds);
    const settlements = SettlementCalculator.calculateSettlements(this.groupId, this.members, bills, splits);
    await this.settlementDao.replaceByGroupId(this.groupId, settlements);
    await this.groupDao.updateSettled(this.groupId, settlements.length === 0 ? 1 : 0);
  }

  private async saveBill(): Promise<void> {
    if (this.title.trim().length === 0) {
      promptAction.showToast({ message: '请输入账单标题' });
      return;
    }
    const totalAmount = FormatUtils.parseAmountInput(this.amountInput);
    if (totalAmount <= 0) {
      promptAction.showToast({ message: '请输入正确的金额' });
      return;
    }
    if (this.members.length === 0) {
      promptAction.showToast({ message: '当前群组没有成员，无法创建账单' });
      return;
    }

    const splits = this.splitTypeIndex === 0 ? this.buildEqualSplits(totalAmount) : this.buildCustomSplits(totalAmount);
    if (splits === null) {
      return;
    }

    const payer = this.members[this.payerIndex];
    const bill: Bill = {
      id: 0,
      groupId: this.groupId,
      title: this.title.trim(),
      amount: totalAmount,
      payerId: payer.id,
      category: BILL_CATEGORIES[this.categoryIndex],
      splitType: this.splitTypeIndex === 0 ? 'equal' : 'custom',
      createdAt: Date.now(),
      note: this.note.trim()
    };

    this.saving = true;
    try {
      const billId = await this.billDao.create(bill);
      await this.billSplitDao.createMany(billId, splits);
      await this.rebuildSettlements();
      promptAction.showToast({ message: '账单已保存' });
      router.back();
    } catch (_) {
      promptAction.showToast({ message: '保存失败，请稍后重试' });
    }
    this.saving = false;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('返回')
            .onClick(() => router.back())
          Text('新增账单')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank().width(52)
        }
        .width('100%')

        Column({ space: 12 }) {
          Text('消费标题')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .alignSelf(ItemAlign.Start)
          TextInput({ placeholder: '例如：晚餐、酒店、打车', text: this.title })
            .width('100%')
            .onChange((value: string) => {
              this.title = value;
            })

          Text('总金额（元）')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .alignSelf(ItemAlign.Start)
          TextInput({ placeholder: '例如：128.50', text: this.amountInput })
            .type(InputType.Number)
            .width('100%')
            .onChange((value: string) => {
              this.amountInput = value;
            })

          Text('付款人')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .alignSelf(ItemAlign.Start)
          Select(this.members.map((item: Member) => ({ value: item.name })))
            .selected(this.payerIndex)
            .value(this.members.length > 0 ? this.members[this.payerIndex].name : '请选择')
            .onSelect((index: number) => {
              this.payerIndex = index;
            })
            .width('100%')

          Text('消费分类')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .alignSelf(ItemAlign.Start)
          Select(this.categoryOptions)
            .selected(this.categoryIndex)
            .value(this.categoryOptions[this.categoryIndex].value)
            .onSelect((index: number) => {
              this.categoryIndex = index;
            })
            .width('100%')

          Text('分摊方式')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .alignSelf(ItemAlign.Start)
          Select(this.splitOptions)
            .selected(this.splitTypeIndex)
            .value(this.splitOptions[this.splitTypeIndex].value)
            .onSelect((index: number) => {
              this.splitTypeIndex = index;
            })
            .width('100%')

          Text('备注')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .alignSelf(ItemAlign.Start)
          TextInput({ placeholder: '可选，例如桌号、订单信息', text: this.note })
            .width('100%')
            .onChange((value: string) => {
              this.note = value;
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFFFF')
        .borderRadius(20)

        if (this.splitTypeIndex === 1) {
          Column({ space: 12 }) {
            Text('自定义分摊（元）')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .alignSelf(ItemAlign.Start)
            ForEach(this.members, (member: Member, index: number) => {
              Row({ space: 10 }) {
                Text(member.name)
                  .width(84)
                  .fontSize(14)
                TextInput({ placeholder: '0.00', text: this.customAmounts[index] ?? '0' })
                  .layoutWeight(1)
                  .type(InputType.Number)
                  .onChange((value: string) => {
                    this.updateCustomAmount(index, value);
                  })
              }
              .width('100%')
            }, (member: Member) => `${member.id}`)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFFFF')
          .borderRadius(20)
        }

        if (this.members.length === 0) {
          Text('当前群组没有成员，暂时无法新增账单。')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFFFF')
            .borderRadius(20)
        }

        Button(this.saving ? '保存中...' : '保存账单')
          .width('100%')
          .height(52)
          .fontSize(18)
          .backgroundColor($r('app.color.brand_color'))
          .fontColor('#FFFFFFFF')
          .onClick(() => {
            if (!this.saving) {
              this.saveBill();
            }
          })
      }
      .width('100%')
      .padding(20)
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#FFF5F7FB')
  }
}
