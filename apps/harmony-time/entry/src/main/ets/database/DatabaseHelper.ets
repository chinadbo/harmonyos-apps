import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { Project, createProject as createProjectModel } from '../model/Project';
import { TimeEntry, createTimeEntry as createTimeEntryModel } from '../model/TimeEntry';
import { ProjectDurationStat, DailyDurationStat } from '../model/Stats';
import { ProjectDao } from './ProjectDao';
import { TimeEntryDao } from './TimeEntryDao';

const DB_CONFIG: relationalStore.StoreConfig = {
  name: 'harmony_time.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

export class DatabaseHelper {
  private static instance: DatabaseHelper;
  private store?: relationalStore.RdbStore;
  private projectDao: ProjectDao = new ProjectDao();
  private timeEntryDao: TimeEntryDao = new TimeEntryDao();

  static getInstance(): DatabaseHelper {
    if (!DatabaseHelper.instance) {
      DatabaseHelper.instance = new DatabaseHelper();
    }
    return DatabaseHelper.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store) return;
    this.store = await relationalStore.getRdbStore(context, DB_CONFIG);
    await this.store.executeSql(`CREATE TABLE IF NOT EXISTS projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      color TEXT NOT NULL DEFAULT '#4A90E2',
      icon TEXT NOT NULL DEFAULT '⏱',
      total_time INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL
    )`);
    await this.store.executeSql(`CREATE TABLE IF NOT EXISTS time_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      project_id INTEGER NOT NULL,
      start_time INTEGER NOT NULL,
      end_time INTEGER DEFAULT 0,
      duration INTEGER DEFAULT 0,
      note TEXT DEFAULT '',
      created_at INTEGER NOT NULL
    )`);
    await this.store.executeSql('CREATE INDEX IF NOT EXISTS idx_time_entries_project_id ON time_entries(project_id)');
    await this.store.executeSql('CREATE INDEX IF NOT EXISTS idx_time_entries_start_time ON time_entries(start_time)');
  }

  getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('Database is not initialized');
    }
    return this.store;
  }

  // ===== Project Facade Methods =====

  async getAllProjects(): Promise<Project[]> {
    return this.projectDao.getAllProjects();
  }

  async getProjectById(id: number): Promise<Project | null> {
    const projects = await this.projectDao.getAllProjects();
    return projects.find(p => p.id === id) ?? null;
  }

  async createProject(name: string, color: string, icon: string): Promise<number> {
    const project: Project = createProjectModel(name, color, icon);
    return this.projectDao.insertProject(project);
  }

  async updateProject(idOrProject: number | Project, name?: string, color?: string, icon?: string): Promise<void> {
    if (typeof idOrProject === 'number') {
      const existing = await this.getProjectById(idOrProject);
      if (existing) {
        existing.name = name ?? existing.name;
        existing.color = color ?? existing.color;
        existing.icon = icon ?? existing.icon;
        await this.projectDao.updateProject(existing);
      }
    } else {
      await this.projectDao.updateProject(idOrProject);
    }
  }

  async deleteProject(id: number): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('projects');
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  // ===== TimeEntry Facade Methods =====

  async getAllTimeEntries(): Promise<TimeEntry[]> {
    return this.timeEntryDao.getAllEntries();
  }

  async getTimeEntriesByDateRange(start: number, end: number): Promise<TimeEntry[]> {
    const store = this.getStore();
    const resultSet = await store.querySql(
      'SELECT id, project_id, start_time, end_time, duration, note, created_at FROM time_entries WHERE start_time >= ? AND start_time <= ? ORDER BY start_time DESC',
      [start, end]
    );
    const list: TimeEntry[] = [];
    while (resultSet.goToNextRow()) {
      list.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        projectId: resultSet.getLong(resultSet.getColumnIndex('project_id')),
        startTime: resultSet.getLong(resultSet.getColumnIndex('start_time')),
        endTime: resultSet.getLong(resultSet.getColumnIndex('end_time')),
        duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at'))
      });
    }
    resultSet.close();
    return list;
  }

  async getRunningEntry(): Promise<TimeEntry | null> {
    const store = this.getStore();
    const resultSet = await store.querySql(
      'SELECT id, project_id, start_time, end_time, duration, note, created_at FROM time_entries WHERE end_time = 0 ORDER BY start_time DESC LIMIT 1'
    );
    let entry: TimeEntry | null = null;
    if (resultSet.goToFirstRow()) {
      entry = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        projectId: resultSet.getLong(resultSet.getColumnIndex('project_id')),
        startTime: resultSet.getLong(resultSet.getColumnIndex('start_time')),
        endTime: resultSet.getLong(resultSet.getColumnIndex('end_time')),
        duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
        note: resultSet.getString(resultSet.getColumnIndex('note')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at'))
      };
    }
    resultSet.close();
    return entry;
  }

  async createTimeEntry(projectId: number, startTime?: number): Promise<number> {
    const now = startTime ?? Date.now();
    const entry: TimeEntry = createTimeEntryModel(projectId, now, 0, '');
    return this.timeEntryDao.insertEntry(entry);
  }

  async finishTimeEntry(id: number, endTimeOrElapsed: number): Promise<void> {
    const store = this.getStore();
    const now = Date.now();
    // If endTimeOrElapsed looks like elapsed seconds (small number), compute endTime
    let endTime: number;
    let duration: number;
    if (endTimeOrElapsed < 1000000000000) {
      // It's elapsed seconds
      duration = endTimeOrElapsed;
      endTime = now;
    } else {
      endTime = endTimeOrElapsed;
      // Query start_time to calc duration
      const rs = await store.querySql('SELECT start_time FROM time_entries WHERE id = ?', [id]);
      let startTime = 0;
      if (rs.goToFirstRow()) {
        startTime = rs.getLong(rs.getColumnIndex('start_time'));
      }
      rs.close();
      duration = Math.max(0, Math.floor((endTime - startTime) / 1000));
    }
    const predicates = new relationalStore.RdbPredicates('time_entries');
    predicates.equalTo('id', id);
    await store.update({ end_time: endTime, duration: duration }, predicates);
  }

  async addProjectTime(projectId: number, seconds: number): Promise<void> {
    await this.projectDao.incrementTotalTime(projectId, seconds);
  }

  async deleteTimeEntry(id: number): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('time_entries');
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  async createManualTimeEntry(projectId: number, startTime: number, endTime: number, durationOrNote: number | string, note?: string): Promise<number> {
    let actualNote: string;
    let actualDuration: number;
    if (typeof durationOrNote === 'string') {
      actualNote = durationOrNote;
      actualDuration = Math.max(0, Math.floor((endTime - startTime) / 1000));
    } else {
      actualDuration = durationOrNote;
      actualNote = note ?? '';
    }
    const entry: TimeEntry = {
      id: Date.now(),
      projectId: projectId,
      startTime: startTime,
      endTime: endTime,
      duration: actualDuration,
      note: actualNote,
      createdAt: Date.now()
    };
    return this.timeEntryDao.insertEntry(entry);
  }

  // ===== Stats Facade Methods =====

  async getProjectDurationStats(start: number, end: number): Promise<ProjectDurationStat[]> {
    return this.timeEntryDao.getProjectDurationStats(start, end);
  }

  async getDailyDurationStats(start: number, end: number): Promise<DailyDurationStat[]> {
    return this.timeEntryDao.getDailyDurationStats(start, end);
  }
}
