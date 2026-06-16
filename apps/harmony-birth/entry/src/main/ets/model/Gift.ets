export type GiftStatus = 'pending' | 'sent';

export interface Gift {
  id?: number;
  contactId: number;
  name: string;
  price: number;
  url: string;
  note: string;
  status: GiftStatus;
  createdAt?: number;
}

export class GiftRecord implements Gift {
  id?: number = 0;
  contactId: number = 0;
  name: string = '';
  price: number = 0;
  url: string = '';
  note: string = '';
  status: GiftStatus = 'pending';
  createdAt?: number = 0;

  constructor(data?: Partial<Gift>) {
    if (data) {
      this.id = data.id;
      this.contactId = data.contactId ?? 0;
      this.name = data.name ?? '';
      this.price = data.price ?? 0;
      this.url = data.url ?? '';
      this.note = data.note ?? '';
      this.status = data.status ?? 'pending';
      this.createdAt = data.createdAt ?? Date.now();
    }
  }
}
