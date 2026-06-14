export interface Settlement {
  id: number;
  groupId: number;
  fromMemberId: number;
  toMemberId: number;
  amount: number;
  isPaid: number;
  paidAt: number;
}

export interface SettlementDetail extends Settlement {
  fromMemberName: string;
  fromColorIndex: number;
  toMemberName: string;
  toColorIndex: number;
}
