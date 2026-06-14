import relationalStore from '@ohos.data.relationalStore';
import { DatabaseHelper } from './DatabaseHelper';
import { Member } from '../model/Member';

export class MemberDao {
  private helper: DatabaseHelper = DatabaseHelper.getInstance();

  async create(groupId: number, name: string, colorIndex: number): Promise<number> {
    const store = await this.helper.getStore();
    const values: relationalStore.ValuesBucket = {
      group_id: groupId,
      name,
      color_index: colorIndex
    };
    return await store.insert('members', values);
  }

  async batchCreate(groupId: number, names: string[]): Promise<void> {
    for (let index = 0; index < names.length; index++) {
      const name = names[index].trim();
      if (name.length > 0) {
        await this.create(groupId, name, index % 8);
      }
    }
  }

  async getByGroupId(groupId: number): Promise<Member[]> {
    const store = await this.helper.getStore();
    const predicates = new relationalStore.RdbPredicates('members');
    predicates.equalTo('group_id', groupId);
    predicates.orderByAsc('id');
    const resultSet = await store.query(predicates, ['id', 'group_id', 'name', 'color_index']);
    const members = this.readMembers(resultSet);
    resultSet.close();
    return members;
  }

  async getById(memberId: number): Promise<Member | null> {
    const store = await this.helper.getStore();
    const predicates = new relationalStore.RdbPredicates('members');
    predicates.equalTo('id', memberId);
    const resultSet = await store.query(predicates, ['id', 'group_id', 'name', 'color_index']);
    const members = this.readMembers(resultSet);
    resultSet.close();
    return members.length > 0 ? members[0] : null;
  }

  private readMembers(resultSet: relationalStore.ResultSet): Member[] {
    const members: Member[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        members.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          groupId: resultSet.getLong(resultSet.getColumnIndex('group_id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          colorIndex: resultSet.getLong(resultSet.getColumnIndex('color_index'))
        });
      } while (resultSet.goToNextRow());
    }
    return members;
  }
}
