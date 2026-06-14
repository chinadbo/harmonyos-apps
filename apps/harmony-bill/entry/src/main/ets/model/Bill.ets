export const BILL_CATEGORIES: string[] = ['餐饮', '交通', '住宿', '娱乐', '其他'];

export interface Bill {
  id: number;
  groupId: number;
  title: string;
  amount: number;
  payerId: number;
  category: string;
  splitType: string;
  createdAt: number;
  note: string;
}

export interface BillWithPayer extends Bill {
  payerName: string;
}
