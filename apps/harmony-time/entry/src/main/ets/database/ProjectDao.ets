import relationalStore from '@ohos.data.relationalStore';
import { Project } from '../model/Project';
import { DatabaseHelper } from './DatabaseHelper';

export class ProjectDao {
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();

  async getAllProjects(): Promise<Project[]> {
    const store: relationalStore.RdbStore = this.dbHelper.getStore();
    const resultSet: relationalStore.ResultSet = await store.querySql('SELECT id, name, color, icon, total_time, created_at FROM projects ORDER BY created_at DESC');
    const list: Project[] = [];
    while (resultSet.goToNextRow()) {
      list.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        color: resultSet.getString(resultSet.getColumnIndex('color')),
        icon: resultSet.getString(resultSet.getColumnIndex('icon')),
        totalTime: resultSet.getLong(resultSet.getColumnIndex('total_time')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at'))
      });
    }
    resultSet.close();
    return list;
  }

  async insertProject(project: Project): Promise<number> {
    const valueBucket: relationalStore.ValuesBucket = {
      id: project.id,
      name: project.name,
      color: project.color,
      icon: project.icon,
      total_time: project.totalTime,
      created_at: project.createdAt
    };
    return this.dbHelper.getStore().insert('projects', valueBucket);
  }

  async updateProject(project: Project): Promise<number> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('projects');
    predicates.equalTo('id', project.id);
    return this.dbHelper.getStore().update({
      name: project.name,
      color: project.color,
      icon: project.icon,
      total_time: project.totalTime
    }, predicates);
  }

  async incrementTotalTime(projectId: number, duration: number): Promise<void> {
    await this.dbHelper.getStore().executeSql('UPDATE projects SET total_time = total_time + ? WHERE id = ?', [duration, projectId]);
  }
}
