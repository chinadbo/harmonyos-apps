import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { ExportFormat, ExportResolution, FilterType, SETTING_KEYS, TABLES } from '../common/constants';
import { parseBoolean } from '../common/utils';
import {
  AudioTrack,
  createDefaultSettings,
  ExportSettings,
  Project,
  ProjectBundle,
  ProjectStatus,
  ProjectSummary,
  VideoSegment
} from './ProjectModel';

const CREATE_PROJECTS_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL DEFAULT '',
    output_path TEXT DEFAULT '',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    status TEXT DEFAULT 'draft'
  )
`;

const CREATE_VIDEO_SEGMENTS_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS video_segments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    source_path TEXT NOT NULL,
    start_time INTEGER NOT NULL,
    end_time INTEGER NOT NULL,
    duration INTEGER NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    filter_type TEXT DEFAULT '',
    filter_intensity INTEGER DEFAULT 0,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
  )
`;

const CREATE_AUDIO_TRACKS_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS audio_tracks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL DEFAULT 0,
    source_path TEXT DEFAULT '',
    volume INTEGER DEFAULT 50,
    fade_in_ms INTEGER DEFAULT 0,
    fade_out_ms INTEGER DEFAULT 0,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
  )
`;

const CREATE_SETTINGS_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
  )
`;

export class DataStore {
  private static instance: DataStore = new DataStore();
  private context: common.UIAbilityContext | null = null;
  private store: relationalStore.RdbStore | null = null;

  static getInstance(): DataStore {
    return DataStore.instance;
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    await DataStore.instance.initialize(context);
  }

  private async initialize(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    const store = await this.getStore();
    await store.executeSql(CREATE_PROJECTS_TABLE_SQL);
    await store.executeSql(CREATE_VIDEO_SEGMENTS_TABLE_SQL);
    await store.executeSql(CREATE_AUDIO_TRACKS_TABLE_SQL);
    await store.executeSql(CREATE_SETTINGS_TABLE_SQL);
    await this.ensureDefaultSettings();
  }

  async getStore(): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store;
    }
    if (!this.context) {
      throw new Error('DataStore is not initialized');
    }
    const config: relationalStore.StoreConfig = {
      name: 'harmony_editor.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await relationalStore.getRdbStore(this.context, config);
    return this.store;
  }

  async insertProject(project: Project): Promise<Project> {
    const store = await this.getStore();
    const values: relationalStore.ValuesBucket = {
      name: project.name,
      output_path: project.outputPath,
      created_at: project.createdAt,
      updated_at: project.updatedAt,
      status: project.status
    };
    const projectId = await store.insert(TABLES.PROJECTS, values);
    return {
      ...project,
      id: Number(projectId)
    };
  }

  async updateProject(project: Project): Promise<void> {
    const store = await this.getStore();
    const predicates = new relationalStore.RdbPredicates(TABLES.PROJECTS);
    predicates.equalTo('id', project.id);
    const values: relationalStore.ValuesBucket = {
      name: project.name,
      output_path: project.outputPath,
      created_at: project.createdAt,
      updated_at: project.updatedAt,
      status: project.status
    };
    await store.update(values, predicates);
  }

  async updateProjectStatus(projectId: number, status: ProjectStatus, outputPath: string = ''): Promise<void> {
    const project = await this.getProject(projectId);
    if (!project) {
      return;
    }
    await this.updateProject({
      ...project,
      status,
      outputPath: outputPath.length > 0 ? outputPath : project.outputPath,
      updatedAt: Date.now()
    });
  }

  async touchProject(projectId: number): Promise<void> {
    const project = await this.getProject(projectId);
    if (!project) {
      return;
    }
    await this.updateProject({
      ...project,
      updatedAt: Date.now()
    });
  }

  async deleteProject(projectId: number): Promise<void> {
    const store = await this.getStore();
    let predicates = new relationalStore.RdbPredicates(TABLES.AUDIO_TRACKS);
    predicates.equalTo('project_id', projectId);
    await store.delete(predicates);

    predicates = new relationalStore.RdbPredicates(TABLES.VIDEO_SEGMENTS);
    predicates.equalTo('project_id', projectId);
    await store.delete(predicates);

    predicates = new relationalStore.RdbPredicates(TABLES.PROJECTS);
    predicates.equalTo('id', projectId);
    await store.delete(predicates);
  }

  async getProject(projectId: number): Promise<Project | null> {
    const store = await this.getStore();
    const predicates = new relationalStore.RdbPredicates(TABLES.PROJECTS);
    predicates.equalTo('id', projectId);
    const resultSet = await store.query(predicates, ['id', 'name', 'output_path', 'created_at', 'updated_at', 'status']);
    const projects = this.readProjects(resultSet);
    resultSet.close();
    return projects.length > 0 ? projects[0] : null;
  }

  async listProjectSummaries(): Promise<Array<ProjectSummary>> {
    const store = await this.getStore();
    const sql = `
      SELECT p.id, p.name, p.output_path, p.created_at, p.updated_at, p.status,
        COUNT(s.id) AS segment_count,
        COALESCE(SUM(s.duration), 0) AS total_duration
      FROM projects p
      LEFT JOIN video_segments s ON p.id = s.project_id
      GROUP BY p.id
      ORDER BY p.updated_at DESC, p.id DESC
    `;
    const resultSet = await store.querySql(sql, []);
    const summaries: Array<ProjectSummary> = [];
    if (resultSet.goToFirstRow()) {
      do {
        summaries.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          outputPath: resultSet.getString(resultSet.getColumnIndex('output_path')),
          createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
          updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at')),
          status: this.toProjectStatus(resultSet.getString(resultSet.getColumnIndex('status'))),
          segmentCount: resultSet.getLong(resultSet.getColumnIndex('segment_count')),
          totalDuration: resultSet.getLong(resultSet.getColumnIndex('total_duration'))
        });
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return summaries;
  }

  async replaceSegments(projectId: number, segments: Array<VideoSegment>): Promise<Array<VideoSegment>> {
    const store = await this.getStore();
    const deletePredicates = new relationalStore.RdbPredicates(TABLES.VIDEO_SEGMENTS);
    deletePredicates.equalTo('project_id', projectId);
    await store.delete(deletePredicates);

    const savedSegments: Array<VideoSegment> = [];
    for (const segment of segments) {
      const values: relationalStore.ValuesBucket = {
        project_id: projectId,
        source_path: segment.sourcePath,
        start_time: segment.startTime,
        end_time: segment.endTime,
        duration: segment.duration,
        sort_order: segment.order,
        filter_type: segment.filterType,
        filter_intensity: segment.filterIntensity
      };
      const segmentId = await store.insert(TABLES.VIDEO_SEGMENTS, values);
      savedSegments.push({
        ...segment,
        id: Number(segmentId),
        projectId
      });
    }

    await this.touchProject(projectId);
    return savedSegments;
  }

  async getSegments(projectId: number): Promise<Array<VideoSegment>> {
    const store = await this.getStore();
    const predicates = new relationalStore.RdbPredicates(TABLES.VIDEO_SEGMENTS);
    predicates.equalTo('project_id', projectId);
    predicates.orderByAsc('sort_order');
    const resultSet = await store.query(predicates, [
      'id',
      'project_id',
      'source_path',
      'start_time',
      'end_time',
      'duration',
      'sort_order',
      'filter_type',
      'filter_intensity'
    ]);
    const segments = this.readSegments(resultSet);
    resultSet.close();
    return segments;
  }

  async saveAudioTrack(projectId: number, audioTrack: AudioTrack | null): Promise<AudioTrack | null> {
    const store = await this.getStore();
    const deletePredicates = new relationalStore.RdbPredicates(TABLES.AUDIO_TRACKS);
    deletePredicates.equalTo('project_id', projectId);
    await store.delete(deletePredicates);
    if (!audioTrack) {
      await this.touchProject(projectId);
      return null;
    }
    const values: relationalStore.ValuesBucket = {
      project_id: projectId,
      source_path: audioTrack.sourcePath,
      volume: audioTrack.volume,
      fade_in_ms: audioTrack.fadeInMs,
      fade_out_ms: audioTrack.fadeOutMs
    };
    const audioId = await store.insert(TABLES.AUDIO_TRACKS, values);
    await this.touchProject(projectId);
    return {
      ...audioTrack,
      id: Number(audioId),
      projectId
    };
  }

  async getAudioTrack(projectId: number): Promise<AudioTrack | null> {
    const store = await this.getStore();
    const predicates = new relationalStore.RdbPredicates(TABLES.AUDIO_TRACKS);
    predicates.equalTo('project_id', projectId);
    const resultSet = await store.query(predicates, ['id', 'project_id', 'source_path', 'volume', 'fade_in_ms', 'fade_out_ms']);
    const tracks = this.readAudioTracks(resultSet);
    resultSet.close();
    return tracks.length > 0 ? tracks[0] : null;
  }

  async getProjectBundle(projectId: number): Promise<ProjectBundle | null> {
    const project = await this.getProject(projectId);
    if (!project) {
      return null;
    }
    const segments = await this.getSegments(projectId);
    const audioTrack = await this.getAudioTrack(projectId);
    return {
      project,
      segments,
      audioTrack
    };
  }

  async getSetting(key: string): Promise<string | null> {
    const store = await this.getStore();
    const predicates = new relationalStore.RdbPredicates(TABLES.SETTINGS);
    predicates.equalTo('key', key);
    const resultSet = await store.query(predicates, ['key', 'value']);
    let value: string | null = null;
    if (resultSet.goToFirstRow()) {
      value = resultSet.getString(resultSet.getColumnIndex('value'));
    }
    resultSet.close();
    return value;
  }

  async setSetting(key: string, value: string): Promise<void> {
    const store = await this.getStore();
    const existing = await this.getSetting(key);
    const values: relationalStore.ValuesBucket = {
      key,
      value
    };
    if (existing === null) {
      await store.insert(TABLES.SETTINGS, values);
      return;
    }
    const predicates = new relationalStore.RdbPredicates(TABLES.SETTINGS);
    predicates.equalTo('key', key);
    await store.update(values, predicates);
  }

  async getExportSettings(): Promise<ExportSettings> {
    const defaults = createDefaultSettings();
    const resolutionValue = await this.getSetting(SETTING_KEYS.DEFAULT_EXPORT_RESOLUTION);
    const formatValue = await this.getSetting(SETTING_KEYS.DEFAULT_EXPORT_FORMAT);
    const autoSaveValue = await this.getSetting(SETTING_KEYS.AUTO_SAVE_ENABLED);
    return {
      resolution: (resolutionValue as ExportResolution) ?? defaults.resolution,
      format: (formatValue as ExportFormat) ?? defaults.format,
      autoSaveEnabled: parseBoolean(autoSaveValue ?? undefined, defaults.autoSaveEnabled)
    };
  }

  async saveExportSettings(settings: ExportSettings): Promise<void> {
    await this.setSetting(SETTING_KEYS.DEFAULT_EXPORT_RESOLUTION, settings.resolution);
    await this.setSetting(SETTING_KEYS.DEFAULT_EXPORT_FORMAT, settings.format);
    await this.setSetting(SETTING_KEYS.AUTO_SAVE_ENABLED, settings.autoSaveEnabled ? 'true' : 'false');
  }

  private async ensureDefaultSettings(): Promise<void> {
    const defaults = createDefaultSettings();
    if ((await this.getSetting(SETTING_KEYS.DEFAULT_EXPORT_RESOLUTION)) === null) {
      await this.setSetting(SETTING_KEYS.DEFAULT_EXPORT_RESOLUTION, defaults.resolution);
    }
    if ((await this.getSetting(SETTING_KEYS.DEFAULT_EXPORT_FORMAT)) === null) {
      await this.setSetting(SETTING_KEYS.DEFAULT_EXPORT_FORMAT, defaults.format);
    }
    if ((await this.getSetting(SETTING_KEYS.AUTO_SAVE_ENABLED)) === null) {
      await this.setSetting(SETTING_KEYS.AUTO_SAVE_ENABLED, defaults.autoSaveEnabled ? 'true' : 'false');
    }
  }

  private readProjects(resultSet: relationalStore.ResultSet): Array<Project> {
    const projects: Array<Project> = [];
    if (resultSet.goToFirstRow()) {
      do {
        projects.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          outputPath: resultSet.getString(resultSet.getColumnIndex('output_path')),
          createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
          updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at')),
          status: this.toProjectStatus(resultSet.getString(resultSet.getColumnIndex('status')))
        });
      } while (resultSet.goToNextRow());
    }
    return projects;
  }

  private readSegments(resultSet: relationalStore.ResultSet): Array<VideoSegment> {
    const segments: Array<VideoSegment> = [];
    if (resultSet.goToFirstRow()) {
      do {
        segments.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          projectId: resultSet.getLong(resultSet.getColumnIndex('project_id')),
          sourcePath: resultSet.getString(resultSet.getColumnIndex('source_path')),
          startTime: resultSet.getLong(resultSet.getColumnIndex('start_time')),
          endTime: resultSet.getLong(resultSet.getColumnIndex('end_time')),
          duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
          order: resultSet.getLong(resultSet.getColumnIndex('sort_order')),
          filterType: this.toFilterType(resultSet.getString(resultSet.getColumnIndex('filter_type'))),
          filterIntensity: resultSet.getLong(resultSet.getColumnIndex('filter_intensity'))
        });
      } while (resultSet.goToNextRow());
    }
    return segments;
  }

  private readAudioTracks(resultSet: relationalStore.ResultSet): Array<AudioTrack> {
    const tracks: Array<AudioTrack> = [];
    if (resultSet.goToFirstRow()) {
      do {
        tracks.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          projectId: resultSet.getLong(resultSet.getColumnIndex('project_id')),
          sourcePath: resultSet.getString(resultSet.getColumnIndex('source_path')),
          volume: resultSet.getLong(resultSet.getColumnIndex('volume')),
          fadeInMs: resultSet.getLong(resultSet.getColumnIndex('fade_in_ms')),
          fadeOutMs: resultSet.getLong(resultSet.getColumnIndex('fade_out_ms'))
        });
      } while (resultSet.goToNextRow());
    }
    return tracks;
  }

  private toProjectStatus(value: string): ProjectStatus {
    switch (value) {
      case ProjectStatus.EXPORTING:
        return ProjectStatus.EXPORTING;
      case ProjectStatus.EXPORTED:
        return ProjectStatus.EXPORTED;
      case ProjectStatus.FAILED:
        return ProjectStatus.FAILED;
      case ProjectStatus.DRAFT:
      default:
        return ProjectStatus.DRAFT;
    }
  }

  private toFilterType(value: string): FilterType {
    const candidates: Array<FilterType> = Object.values(FilterType) as Array<FilterType>;
    return candidates.includes(value as FilterType) ? (value as FilterType) : FilterType.NONE;
  }
}

export default DataStore.getInstance();
