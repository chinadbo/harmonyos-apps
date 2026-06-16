import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { Contact, ContactRecord } from '../model/Contact';
import { DatabaseHelper } from './DatabaseHelper';

export class ContactDao {
  static async getAll(context: common.Context): Promise<Contact[]> {
    let store = await DatabaseHelper.getRdbStore(context);
    let predicates = new relationalStore.RdbPredicates('contacts');
    predicates.orderByAsc('birthday');
    let resultSet = await store.query(predicates, ['id', 'name', 'relation', 'birthday', 'birthday_year', 'avatar_color', 'reminder_days', 'note', 'system_contact_id', 'created_at']);
    let result = this.mapContacts(resultSet);
    resultSet.close();
    return result;
  }

  static async getById(context: common.Context, id: number): Promise<Contact | null> {
    let store = await DatabaseHelper.getRdbStore(context);
    let predicates = new relationalStore.RdbPredicates('contacts');
    predicates.equalTo('id', id);
    let resultSet = await store.query(predicates, ['id', 'name', 'relation', 'birthday', 'birthday_year', 'avatar_color', 'reminder_days', 'note', 'system_contact_id', 'created_at']);
    let result = this.mapContacts(resultSet);
    resultSet.close();
    return result.length > 0 ? result[0] : null;
  }

  static async insert(context: common.Context, contact: Contact): Promise<number> {
    let store = await DatabaseHelper.getRdbStore(context);
    let bucket: relationalStore.ValuesBucket = {
      name: contact.name,
      relation: contact.relation,
      birthday: contact.birthday,
      birthday_year: contact.birthdayYear ?? 0,
      avatar_color: contact.avatarColor,
      reminder_days: JSON.stringify(contact.reminderDays),
      note: contact.note,
      system_contact_id: contact.systemContactId ?? '',
      created_at: contact.createdAt ?? Date.now()
    };
    return Number(await store.insert('contacts', bucket));
  }

  static async update(context: common.Context, contact: Contact): Promise<void> {
    if (!contact.id) {
      return;
    }
    let store = await DatabaseHelper.getRdbStore(context);
    let bucket: relationalStore.ValuesBucket = {
      name: contact.name,
      relation: contact.relation,
      birthday: contact.birthday,
      birthday_year: contact.birthdayYear ?? 0,
      avatar_color: contact.avatarColor,
      reminder_days: JSON.stringify(contact.reminderDays),
      note: contact.note,
      system_contact_id: contact.systemContactId ?? ''
    };
    let predicates = new relationalStore.RdbPredicates('contacts');
    predicates.equalTo('id', contact.id);
    await store.update(bucket, predicates);
  }

  static async remove(context: common.Context, id: number): Promise<void> {
    let store = await DatabaseHelper.getRdbStore(context);
    let predicates = new relationalStore.RdbPredicates('contacts');
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  private static mapContacts(resultSet: relationalStore.ResultSet): Contact[] {
    let contacts: Contact[] = [];
    if (resultSet.rowCount <= 0) {
      return contacts;
    }
    let idIndex = resultSet.getColumnIndex('id');
    let nameIndex = resultSet.getColumnIndex('name');
    let relationIndex = resultSet.getColumnIndex('relation');
    let birthdayIndex = resultSet.getColumnIndex('birthday');
    let birthdayYearIndex = resultSet.getColumnIndex('birthday_year');
    let avatarColorIndex = resultSet.getColumnIndex('avatar_color');
    let reminderDaysIndex = resultSet.getColumnIndex('reminder_days');
    let noteIndex = resultSet.getColumnIndex('note');
    let systemContactIdIndex = resultSet.getColumnIndex('system_contact_id');
    let createdAtIndex = resultSet.getColumnIndex('created_at');
    resultSet.goToFirstRow();
    for (let row = 0; row < resultSet.rowCount; row++) {
      if (row > 0) {
        resultSet.goToNextRow();
      }
      contacts.push(new ContactRecord({
        id: resultSet.getLong(idIndex),
        name: resultSet.getString(nameIndex),
        relation: resultSet.getString(relationIndex),
        birthday: resultSet.getString(birthdayIndex),
        birthdayYear: resultSet.getLong(birthdayYearIndex),
        avatarColor: resultSet.getString(avatarColorIndex),
        reminderDays: JSON.parse(resultSet.getString(reminderDaysIndex) || '[1,3,7,30]') as number[],
        note: resultSet.getString(noteIndex),
        systemContactId: resultSet.getString(systemContactIdIndex),
        createdAt: resultSet.getLong(createdAtIndex)
      }));
    }
    return contacts;
  }
}
