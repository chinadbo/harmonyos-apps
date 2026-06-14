export interface BillSplit {
  id: number;
  billId: number;
  memberId: number;
  amount: number;
}

export interface BillSplitDetail extends BillSplit {
  memberName: string;
  colorIndex: number;
}
