import relationalStore from '@ohos.data.relationalStore';
import { TimeEntry } from '../model/TimeEntry';
import { DailyDurationStat, ProjectDurationStat } from '../model/Stats';
import { DatabaseHelper } from './DatabaseHelper';
import { DateUtils } from '../utils/DateUtils';

export class TimeEntryDao {
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();

  async getAllEntries(): Promise<TimeEntry[]> {
    const resultSet: relationalStore.ResultSet = await this.dbHelper.getStore().querySql('SELECT id, project_id, start_time, end_time, duration, note, created_at FROM time_entries ORDER BY start_time DESC');
    const list: TimeEntry[] = [];
    while (resultSet.goToNextRow()) {
      list.push(this.mapResult(resultSet));
    }
    resultSet.close();
    return list;
  }

  async insertEntry(entry: TimeEntry): Promise<number> {
    return this.dbHelper.getStore().insert('time_entries', {
      id: entry.id,
      project_id: entry.projectId,
      start_time: entry.startTime,
      end_time: entry.endTime,
      duration: entry.duration,
      note: entry.note,
      created_at: entry.createdAt
    });
  }

  async updateEntry(entry: TimeEntry): Promise<number> {
    const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('time_entries');
    predicates.equalTo('id', entry.id);
    return this.dbHelper.getStore().update({
      project_id: entry.projectId,
      start_time: entry.startTime,
      end_time: entry.endTime,
      duration: entry.duration,
      note: entry.note
    }, predicates);
  }

  async getTodayDuration(): Promise<number> {
    const start: number = DateUtils.getStartOfDay(Date.now());
    const end: number = DateUtils.getEndOfDay(Date.now());
    return this.getTotalDurationByRange(start, end);
  }

  async getWeekDuration(): Promise<number> {
    const start: number = DateUtils.getStartOfWeek(Date.now());
    const end: number = DateUtils.getEndOfDay(Date.now());
    return this.getTotalDurationByRange(start, end);
  }

  async getTotalDurationByRange(startTime: number, endTime: number): Promise<number> {
    const resultSet: relationalStore.ResultSet = await this.dbHelper.getStore().querySql(
      'SELECT COALESCE(SUM(duration), 0) AS total_duration FROM time_entries WHERE start_time >= ? AND start_time <= ? AND end_time > 0',
      [startTime, endTime]
    );
    let value: number = 0;
    if (resultSet.goToFirstRow()) {
      value = resultSet.getLong(resultSet.getColumnIndex('total_duration'));
    }
    resultSet.close();
    return value;
  }

  async getProjectDurationStats(startTime: number, endTime: number): Promise<ProjectDurationStat[]> {
    const sql: string = 'SELECT p.id AS project_id, p.name AS project_name, p.color AS color, COALESCE(SUM(t.duration), 0) AS total_duration ' +
      'FROM projects p LEFT JOIN time_entries t ON p.id = t.project_id AND t.start_time >= ? AND t.start_time <= ? AND t.end_time > 0 ' +
      'GROUP BY p.id, p.name, p.color ORDER BY total_duration DESC';
    const resultSet: relationalStore.ResultSet = await this.dbHelper.getStore().querySql(sql, [startTime, endTime]);
    const list: ProjectDurationStat[] = [];
    while (resultSet.goToNextRow()) {
      list.push({
        projectId: resultSet.getLong(resultSet.getColumnIndex('project_id')),
        projectName: resultSet.getString(resultSet.getColumnIndex('project_name')),
        color: resultSet.getString(resultSet.getColumnIndex('color')),
        duration: resultSet.getLong(resultSet.getColumnIndex('total_duration'))
      });
    }
    resultSet.close();
    return list;
  }

  async getDailyDurationStats(startTime: number, endTime: number): Promise<DailyDurationStat[]> {
    const sql: string = 'SELECT strftime(\'%Y-%m-%d\', start_time / 1000, \"unixepoch\", \"localtime\") AS day_key, COALESCE(SUM(duration), 0) AS total_duration ' +
      'FROM time_entries WHERE start_time >= ? AND start_time <= ? AND end_time > 0 GROUP BY day_key ORDER BY day_key ASC';
    const resultSet: relationalStore.ResultSet = await this.dbHelper.getStore().querySql(sql, [startTime, endTime]);
    const list: DailyDurationStat[] = [];
    while (resultSet.goToNextRow()) {
      const dayKey: string = resultSet.getString(resultSet.getColumnIndex('day_key'));
      list.push({
        dayLabel: dayKey.slice(5),
        duration: resultSet.getLong(resultSet.getColumnIndex('total_duration'))
      });
    }
    resultSet.close();
    return list;
  }

  private mapResult(resultSet: relationalStore.ResultSet): TimeEntry {
    return {
      id: resultSet.getLong(resultSet.getColumnIndex('id')),
      projectId: resultSet.getLong(resultSet.getColumnIndex('project_id')),
      startTime: resultSet.getLong(resultSet.getColumnIndex('start_time')),
      endTime: resultSet.getLong(resultSet.getColumnIndex('end_time')),
      duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
      note: resultSet.getString(resultSet.getColumnIndex('note')),
      createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at'))
    };
  }
}
