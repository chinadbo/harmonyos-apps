import router from '@ohos.router';
import { GroupDao } from '../database/GroupDao';
import { MemberDao } from '../database/MemberDao';
import { BillDao } from '../database/BillDao';
import { Group } from '../model/Group';
import { Member } from '../model/Member';
import { BillWithPayer } from '../model/Bill';
import { GroupCard } from '../components/GroupCard';
import { MemberChip } from '../components/MemberChip';
import { BillItem } from '../components/BillItem';
import { PieChart, PieChartDataItem } from '../components/PieChart';
import { ColorUtils } from '../utils/ColorUtils';
import { FormatUtils } from '../utils/FormatUtils';

interface GroupDetailParams {
  groupId: number;
}

@Entry
@Component
struct GroupDetailPage {
  private groupDao: GroupDao = new GroupDao();
  private memberDao: MemberDao = new MemberDao();
  private billDao: BillDao = new BillDao();

  @State private groupId: number = 0;
  @State private groupLoaded: boolean = false;
  @State private group: Group = {
    id: 0,
    name: '',
    scene: 'other',
    createdAt: 0,
    isSettled: 0
  };
  @State private members: Member[] = [];
  @State private bills: BillWithPayer[] = [];
  @State private chartData: PieChartDataItem[] = [];

  aboutToAppear(): void {
    const params = router.getParams() as GroupDetailParams;
    this.groupId = Number(params.groupId);
    this.loadData();
  }

  private async loadData(): Promise<void> {
    const group = await this.groupDao.getById(this.groupId);
    if (group !== null) {
      this.group = group;
      this.groupLoaded = true;
    } else {
      this.groupLoaded = false;
    }
    this.members = await this.memberDao.getByGroupId(this.groupId);
    this.bills = await this.billDao.getByGroupId(this.groupId);
    this.chartData = this.buildChartData();
  }

  private buildChartData(): PieChartDataItem[] {
    const paidMap: Map<number, number> = new Map();
    this.members.forEach((member) => {
      paidMap.set(member.id, 0);
    });
    this.bills.forEach((bill) => {
      paidMap.set(bill.payerId, (paidMap.get(bill.payerId) ?? 0) + bill.amount);
    });
    const data: PieChartDataItem[] = [];
    this.members.forEach((member) => {
      const amount = paidMap.get(member.id) ?? 0;
      if (amount > 0) {
        data.push({
          label: member.name,
          value: amount,
          color: ColorUtils.getColor(member.colorIndex)
        });
      }
    });
    return data;
  }

  private getTotalAmount(): number {
    let total = 0;
    this.bills.forEach((bill) => {
      total += bill.amount;
    });
    return total;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('返回')
            .onClick(() => router.back())
          Text(this.groupLoaded ? this.group.name : '群组详情')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank().width(52)
        }
        .width('100%')

        if (this.groupLoaded) {
          GroupCard({
            clickable: false,
            group: {
              id: this.group.id,
              name: this.group.name,
              scene: this.group.scene,
              createdAt: this.group.createdAt,
              isSettled: this.group.isSettled,
              memberCount: this.members.length,
              billCount: this.bills.length,
              totalAmount: this.getTotalAmount()
            }
          })
        }

        Column({ space: 12 }) {
          Text('成员')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
          if (this.members.length === 0) {
            Text('当前群组还没有成员数据。')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
          } else {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.members, (member: Member) => {
                MemberChip({ name: member.name, colorIndex: member.colorIndex })
                  .margin({ right: 10, bottom: 10 })
              }, (member: Member) => `${member.id}`)
            }
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFFFF')
        .borderRadius(20)

        Column({ space: 12 }) {
          Text('消费占比')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
          PieChart({ data: this.chartData })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFFFF')
        .borderRadius(20)

        Row({ space: 12 }) {
          Button('新增账单')
            .layoutWeight(1)
            .backgroundColor($r('app.color.brand_color'))
            .fontColor('#FFFFFFFF')
            .onClick(() => {
              router.pushUrl({ url: 'pages/AddBillPage', params: { groupId: this.groupId } });
            })
          Button('查看结算')
            .layoutWeight(1)
            .backgroundColor('#FFFFFFFF')
            .fontColor($r('app.color.brand_color'))
            .onClick(() => {
              router.pushUrl({ url: 'pages/SettlementPage', params: { groupId: this.groupId } });
            })
        }
        .width('100%')

        Column({ space: 12 }) {
          Row() {
            Text('账单记录')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Blank().layoutWeight(1)
            Text(`共 ${this.bills.length} 笔 · ${FormatUtils.formatCurrency(this.getTotalAmount())}`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')

          if (this.bills.length === 0) {
            Column({ space: 8 }) {
              Text('还没有账单')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
              Text('先添加一笔共同消费，再生成结算路径。')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('100%')
            .padding({ top: 24, bottom: 24 })
          } else {
            ForEach(this.bills, (bill: BillWithPayer) => {
              Column() {
                BillItem({ bill, clickable: true })
              }
              .onClick(() => {
                router.pushUrl({ url: 'pages/BillDetailPage', params: { billId: bill.id } });
              })
            }, (bill: BillWithPayer) => `${bill.id}`)
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFFFF')
        .borderRadius(20)
      }
      .width('100%')
      .padding(20)
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#FFF5F7FB')
  }
}
