export interface Contact {
  id?: number;
  name: string;
  relation: string;
  birthday: string;
  birthdayYear?: number;
  avatarColor: string;
  reminderDays: number[];
  note: string;
  systemContactId?: string;
  createdAt?: number;
}

export class ContactRecord implements Contact {
  id?: number = 0;
  name: string = '';
  relation: string = '';
  birthday: string = '';
  birthdayYear?: number = 0;
  avatarColor: string = '#FF7A59';
  reminderDays: number[] = [1, 3, 7];
  note: string = '';
  systemContactId?: string = '';
  createdAt?: number = 0;

  constructor(data?: Partial<Contact>) {
    if (data) {
      this.id = data.id;
      this.name = data.name ?? '';
      this.relation = data.relation ?? '';
      this.birthday = data.birthday ?? '';
      this.birthdayYear = data.birthdayYear ?? 0;
      this.avatarColor = data.avatarColor ?? '#FF7A59';
      this.reminderDays = data.reminderDays ?? [1, 3, 7];
      this.note = data.note ?? '';
      this.systemContactId = data.systemContactId ?? '';
      this.createdAt = data.createdAt ?? Date.now();
    }
  }
}
