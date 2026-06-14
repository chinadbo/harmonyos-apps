import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Bill } from '../model/Bill';
import { BillSplitDetail } from '../model/BillSplit';
import { BillDao } from '../database/BillDao';
import { BillSplitDao } from '../database/BillSplitDao';
import { MemberDao } from '../database/MemberDao';
import { SettlementDao } from '../database/SettlementDao';
import { GroupDao } from '../database/GroupDao';
import { SettlementCalculator } from '../utils/SettlementCalculator';
import { FormatUtils } from '../utils/FormatUtils';
import { MemberChip } from '../components/MemberChip';

interface BillDetailParams {
  billId: number;
}

@Entry
@Component
struct BillDetailPage {
  private billDao: BillDao = new BillDao();
  private billSplitDao: BillSplitDao = new BillSplitDao();
  private memberDao: MemberDao = new MemberDao();
  private settlementDao: SettlementDao = new SettlementDao();
  private groupDao: GroupDao = new GroupDao();

  @State private billId: number = 0;
  @State private billLoaded: boolean = false;
  @State private bill: Bill = {
    id: 0,
    groupId: 0,
    title: '',
    amount: 0,
    payerId: 0,
    category: '其他',
    splitType: 'equal',
    createdAt: 0,
    note: ''
  };
  @State private payerName: string = '';
  @State private splits: BillSplitDetail[] = [];
  @State private deleting: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as BillDetailParams;
    this.billId = Number(params.billId);
    this.loadData();
  }

  private async loadData(): Promise<void> {
    const bill = await this.billDao.getById(this.billId);
    if (bill === null) {
      this.billLoaded = false;
      return;
    }
    this.bill = bill;
    this.billLoaded = true;
    const payer = await this.memberDao.getById(this.bill.payerId);
    this.payerName = payer ? payer.name : '未知';
    this.splits = await this.billSplitDao.getByBillId(this.billId);
  }

  private async rebuildSettlements(groupId: number): Promise<void> {
    const members = await this.memberDao.getByGroupId(groupId);
    const bills = await this.billDao.getPlainByGroupId(groupId);
    const billIds = bills.map((item) => item.id);
    const splits = await this.billSplitDao.getPlainByGroupBills(billIds);
    const settlements = SettlementCalculator.calculateSettlements(groupId, members, bills, splits);
    await this.settlementDao.replaceByGroupId(groupId, settlements);
    await this.groupDao.updateSettled(groupId, settlements.length === 0 ? 1 : 0);
  }

  private async deleteBill(): Promise<void> {
    if (!this.billLoaded) {
      return;
    }
    this.deleting = true;
    try {
      const groupId = this.bill.groupId;
      await this.billSplitDao.deleteByBillId(this.billId);
      await this.billDao.deleteById(this.billId);
      await this.rebuildSettlements(groupId);
      promptAction.showToast({ message: '账单已删除' });
      router.back();
    } catch (_) {
      promptAction.showToast({ message: '删除失败，请稍后重试' });
    }
    this.deleting = false;
  }

  private showDeleteDialog(): void {
    AlertDialog.show({
      title: '删除账单',
      message: '删除后将同步清除该账单的分摊明细，并重新计算结算路径，确定继续吗？',
      autoCancel: true,
      primaryButton: {
        value: '取消'
      },
      secondaryButton: {
        value: '删除',
        action: () => {
          this.deleteBill();
        }
      }
    });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('返回')
            .onClick(() => router.back())
          Text('账单详情')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank().width(52)
        }
        .width('100%')

        if (this.billLoaded) {
          Column({ space: 12 }) {
            Text(this.bill.title)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            Text(FormatUtils.formatCurrency(this.bill.amount))
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.brand_color'))
              .alignSelf(ItemAlign.Start)
            Text(`付款人：${this.payerName}`)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .alignSelf(ItemAlign.Start)
            Text(`分类：${this.bill.category} · 分摊：${this.bill.splitType === 'equal' ? '等额分摊' : '自定义分摊'}`)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .alignSelf(ItemAlign.Start)
            Text(`时间：${FormatUtils.formatDateTime(this.bill.createdAt)}`)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .alignSelf(ItemAlign.Start)
            Text(`备注：${this.bill.note.length > 0 ? this.bill.note : '无'}`)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .alignSelf(ItemAlign.Start)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFFFF')
          .borderRadius(20)

          Column({ space: 12 }) {
            Text('分摊明细')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .alignSelf(ItemAlign.Start)
            if (this.splits.length === 0) {
              Text('暂无分摊明细。')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
            } else {
              ForEach(this.splits, (item: BillSplitDetail) => {
                Row() {
                  MemberChip({ name: item.memberName, colorIndex: item.colorIndex })
                  Blank().layoutWeight(1)
                  Text(FormatUtils.formatCurrency(item.amount))
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
              }, (item: BillSplitDetail) => `${item.id}`)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFFFF')
          .borderRadius(20)

          Button(this.deleting ? '删除中...' : '删除账单')
            .width('100%')
            .height(52)
            .backgroundColor($r('app.color.danger_color'))
            .fontColor('#FFFFFFFF')
            .onClick(() => {
              if (!this.deleting) {
                this.showDeleteDialog();
              }
            })
        } else {
          Column({ space: 8 }) {
            Text('账单不存在')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
            Text('这条账单可能已被删除。')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .padding(32)
          .backgroundColor('#FFFFFFFF')
          .borderRadius(20)
        }
      }
      .width('100%')
      .padding(20)
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#FFF5F7FB')
  }
}
