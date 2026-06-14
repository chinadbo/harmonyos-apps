import { Bill } from '../model/Bill';
import { BillSplit } from '../model/BillSplit';
import { Member, MemberBalance } from '../model/Member';
import { Settlement } from '../model/Settlement';

interface WorkingBalance {
  memberId: number;
  amount: number;
}

export class SettlementCalculator {
  static buildMemberBalances(members: Member[], bills: Bill[], billSplits: BillSplit[]): MemberBalance[] {
    const paidMap: Map<number, number> = new Map();
    const shouldPayMap: Map<number, number> = new Map();

    members.forEach((member) => {
      paidMap.set(member.id, 0);
      shouldPayMap.set(member.id, 0);
    });

    bills.forEach((bill) => {
      paidMap.set(bill.payerId, (paidMap.get(bill.payerId) ?? 0) + bill.amount);
    });

    billSplits.forEach((split) => {
      shouldPayMap.set(split.memberId, (shouldPayMap.get(split.memberId) ?? 0) + split.amount);
    });

    return members.map((member) => {
      const totalPaid = paidMap.get(member.id) ?? 0;
      const shouldPay = shouldPayMap.get(member.id) ?? 0;
      return {
        ...member,
        totalPaid,
        shouldPay,
        netAmount: totalPaid - shouldPay
      };
    });
  }

  static calculateSettlements(groupId: number, members: Member[], bills: Bill[], billSplits: BillSplit[]): Settlement[] {
    const balances = SettlementCalculator.buildMemberBalances(members, bills, billSplits);
    const creditors: WorkingBalance[] = [];
    const debtors: WorkingBalance[] = [];

    balances.forEach((item) => {
      if (item.netAmount > 0) {
        creditors.push({ memberId: item.id, amount: item.netAmount });
      } else if (item.netAmount < 0) {
        debtors.push({ memberId: item.id, amount: Math.abs(item.netAmount) });
      }
    });

    creditors.sort((a, b) => b.amount - a.amount);
    debtors.sort((a, b) => b.amount - a.amount);

    const settlements: Settlement[] = [];
    let creditorIndex = 0;
    let debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      const creditor = creditors[creditorIndex];
      const debtor = debtors[debtorIndex];
      const transferAmount = Math.min(creditor.amount, debtor.amount);

      if (transferAmount > 0) {
        settlements.push({
          id: 0,
          groupId,
          fromMemberId: debtor.memberId,
          toMemberId: creditor.memberId,
          amount: transferAmount,
          isPaid: 0,
          paidAt: 0
        });
      }

      creditor.amount -= transferAmount;
      debtor.amount -= transferAmount;

      if (creditor.amount === 0) {
        creditorIndex += 1;
      }
      if (debtor.amount === 0) {
        debtorIndex += 1;
      }
    }

    return settlements;
  }
}
