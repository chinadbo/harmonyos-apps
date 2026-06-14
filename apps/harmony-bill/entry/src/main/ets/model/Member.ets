export interface Member {
  id: number;
  groupId: number;
  name: string;
  colorIndex: number;
}

export interface MemberBalance extends Member {
  totalPaid: number;
  shouldPay: number;
  netAmount: number;
}
