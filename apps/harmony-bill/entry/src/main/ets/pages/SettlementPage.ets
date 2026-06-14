import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { SettlementDao } from '../database/SettlementDao';
import { MemberDao } from '../database/MemberDao';
import { BillDao } from '../database/BillDao';
import { BillSplitDao } from '../database/BillSplitDao';
import { GroupDao } from '../database/GroupDao';
import { SettlementDetail } from '../model/Settlement';
import { SettlementItem } from '../components/SettlementItem';
import { SettlementCalculator } from '../utils/SettlementCalculator';

interface SettlementPageParams {
  groupId: number;
}

@Entry
@Component
struct SettlementPage {
  private settlementDao: SettlementDao = new SettlementDao();
  private memberDao: MemberDao = new MemberDao();
  private billDao: BillDao = new BillDao();
  private billSplitDao: BillSplitDao = new BillSplitDao();
  private groupDao: GroupDao = new GroupDao();

  @State private groupId: number = 0;
  @State private settlements: SettlementDetail[] = [];

  aboutToAppear(): void {
    const params = router.getParams() as SettlementPageParams;
    this.groupId = Number(params.groupId);
    this.loadData();
  }

  private async ensureSettlements(): Promise<void> {
    const current = await this.settlementDao.getByGroupId(this.groupId);
    if (current.length > 0) {
      this.settlements = current;
      return;
    }
    const members = await this.memberDao.getByGroupId(this.groupId);
    const bills = await this.billDao.getPlainByGroupId(this.groupId);
    if (bills.length === 0) {
      this.settlements = [];
      await this.groupDao.updateSettled(this.groupId, 1);
      return;
    }
    const billIds = bills.map((item) => item.id);
    const splits = await this.billSplitDao.getPlainByGroupBills(billIds);
    const settlements = SettlementCalculator.calculateSettlements(this.groupId, members, bills, splits);
    await this.settlementDao.replaceByGroupId(this.groupId, settlements);
    await this.groupDao.updateSettled(this.groupId, settlements.length === 0 ? 1 : 0);
    this.settlements = await this.settlementDao.getByGroupId(this.groupId);
  }

  private async loadData(): Promise<void> {
    await this.ensureSettlements();
  }

  private async togglePaid(item: SettlementDetail): Promise<void> {
    await this.settlementDao.updatePaid(item.id, item.isPaid === 1 ? 0 : 1);
    const latest = await this.settlementDao.getByGroupId(this.groupId);
    this.settlements = latest;
    const allPaid = latest.length === 0 || latest.every((settlement) => settlement.isPaid === 1);
    await this.groupDao.updateSettled(this.groupId, allPaid ? 1 : 0);
    promptAction.showToast({ message: item.isPaid === 1 ? '已标记为未还' : '已标记为已还' });
  }

  private getOutstandingAmount(): number {
    let total = 0;
    this.settlements.forEach((item) => {
      if (item.isPaid === 0) {
        total += item.amount;
      }
    });
    return total;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('返回')
            .onClick(() => router.back())
          Text('结算路径')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank().width(52)
        }
        .width('100%')

        Column({ space: 8 }) {
          Text('最优还款建议')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
          Text(`待完成金额：¥${(this.getOutstandingAmount() / 100).toFixed(2)}`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .alignSelf(ItemAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFFFF')
        .borderRadius(20)

        if (this.settlements.length === 0) {
          Column({ space: 10 }) {
            Text('当前已全部结清')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
            Text('暂无需要执行的还款路径。')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .padding({ top: 36, bottom: 36 })
          .backgroundColor('#FFFFFFFF')
          .borderRadius(20)
        } else {
          ForEach(this.settlements, (item: SettlementDetail) => {
            Column({ space: 10 }) {
              SettlementItem({ settlement: item })
              Button(item.isPaid === 1 ? '标记未还' : '标记已还')
                .width('100%')
                .backgroundColor(item.isPaid === 1 ? '#FFF3F4F6' : $r('app.color.success_color'))
                .fontColor(item.isPaid === 1 ? $r('app.color.text_primary') : '#FFFFFFFF')
                .onClick(() => {
                  this.togglePaid(item);
                })
            }
          }, (item: SettlementDetail) => `${item.id}`)
        }
      }
      .width('100%')
      .padding(20)
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#FFF5F7FB')
  }
}
