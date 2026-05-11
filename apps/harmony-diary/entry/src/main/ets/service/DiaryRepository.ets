import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import {
  DiaryDraft,
  DiaryListItem,
  DiaryMood,
  DiaryRecord,
  DiarySearchResult,
  DiaryStatsSummary,
  MoodStat
} from '../model/DiaryModel';
import { cryptoService } from './CryptoService';
import { buildExcerpt, computeStreak, monthRange, todayKey } from '../utils/DateUtils';
import { getMoodOption, getMoodOptions } from '../utils/MoodConfig';

export class DiaryRepository {
  private static instance?: DiaryRepository;
  private store?: relationalStore.RdbStore;

  static getInstance(): DiaryRepository {
    if (!DiaryRepository.instance) {
      DiaryRepository.instance = new DiaryRepository();
    }
    return DiaryRepository.instance;
  }

  private async runDbTask<T>(work: () => Promise<T>): Promise<T> {
    return await work();
  }

  async ensureReady(context: common.UIAbilityContext): Promise<void> {
    if (this.store) {
      return;
    }

    const config: relationalStore.StoreConfig = {
      name: 'harmony_diary.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await relationalStore.getRdbStore(context, config);
    await this.runDbTask(async () => {
      await this.store!.executeSql('CREATE TABLE IF NOT EXISTS diaries (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL UNIQUE, mood TEXT NOT NULL, title_iv TEXT NOT NULL, title_cipher TEXT NOT NULL, content_iv TEXT NOT NULL, content_cipher TEXT NOT NULL, image_paths TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)');
      await this.store!.executeSql('CREATE VIRTUAL TABLE IF NOT EXISTS diary_fts USING fts5(diary_id UNINDEXED, content)');
    });
  }

  private ensureStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('Repository is not initialized');
    }
    return this.store;
  }

  private getString(resultSet: relationalStore.ResultSet, column: string): string {
    return resultSet.getString(resultSet.getColumnIndex(column));
  }

  private getNumber(resultSet: relationalStore.ResultSet, column: string): number {
    return resultSet.getLong(resultSet.getColumnIndex(column));
  }

  private parseImagePaths(rawValue: string): string[] {
    try {
      const parsed = JSON.parse(rawValue) as string[];
      return Array.isArray(parsed) ? parsed : [];
    } catch (_error) {
      return [];
    }
  }

  private async buildRecord(resultSet: relationalStore.ResultSet): Promise<DiaryRecord> {
    const title = await cryptoService.decryptText({
      iv: this.getString(resultSet, 'title_iv'),
      cipherText: this.getString(resultSet, 'title_cipher')
    });
    const content = await cryptoService.decryptText({
      iv: this.getString(resultSet, 'content_iv'),
      cipherText: this.getString(resultSet, 'content_cipher')
    });

    return {
      id: this.getNumber(resultSet, 'id'),
      title,
      content,
      mood: this.getString(resultSet, 'mood') as DiaryMood,
      date: this.getString(resultSet, 'date'),
      createdAt: this.getNumber(resultSet, 'created_at'),
      updatedAt: this.getNumber(resultSet, 'updated_at'),
      imagePaths: this.parseImagePaths(this.getString(resultSet, 'image_paths'))
    };
  }

  async saveDiary(context: common.UIAbilityContext, draft: DiaryDraft): Promise<number> {
    await this.ensureReady(context);
    return this.runDbTask(async () => {
      const store = this.ensureStore();
      const titleEncrypted = await cryptoService.encryptText(draft.title.trim());
      const contentEncrypted = await cryptoService.encryptText(draft.content.trim());
      const now = Date.now();
      const values: relationalStore.ValuesBucket = {
        date: draft.date,
        mood: draft.mood,
        title_iv: titleEncrypted.iv,
        title_cipher: titleEncrypted.cipherText,
        content_iv: contentEncrypted.iv,
        content_cipher: contentEncrypted.cipherText,
        image_paths: JSON.stringify(draft.imagePaths),
        updated_at: now
      };
      const ftsContent = `${draft.title.trim()} ${buildExcerpt(draft.content.trim(), 100)}`.trim();

      let diaryId = draft.id ?? 0;
      if (draft.id) {
        const predicates = new relationalStore.RdbPredicates('diaries');
        predicates.equalTo('id', draft.id);
        await store.update(values, predicates);
        await store.executeSql('DELETE FROM diary_fts WHERE diary_id = ?', [draft.id]);
      } else {
        values.created_at = now;
        diaryId = await store.insert('diaries', values);
      }
      await store.executeSql('INSERT INTO diary_fts (diary_id, content) VALUES (?, ?)', [diaryId, ftsContent]);
      return diaryId;
    });
  }

  async getRecentDiaries(context: common.UIAbilityContext, limit: number = 20): Promise<DiaryListItem[]> {
    await this.ensureReady(context);
    return this.runDbTask(async () => {
      const resultSet = await this.ensureStore().querySql('SELECT * FROM diaries ORDER BY date DESC, updated_at DESC LIMIT ?', [limit]);
      const records: DiaryListItem[] = [];
      while (resultSet.goToNextRow()) {
        const record = await this.buildRecord(resultSet);
        records.push({
          id: record.id,
          title: record.title.length > 0 ? record.title : '无标题日记',
          excerpt: buildExcerpt(record.content),
          mood: record.mood,
          date: record.date,
          updatedAt: record.updatedAt,
          imagePaths: record.imagePaths
        });
      }
      resultSet.close();
      return records;
    });
  }

  async getDiaryById(context: common.UIAbilityContext, diaryId: number): Promise<DiaryRecord | undefined> {
    await this.ensureReady(context);
    return this.runDbTask(async () => {
      const resultSet = await this.ensureStore().querySql('SELECT * FROM diaries WHERE id = ? LIMIT 1', [diaryId]);
      const exists = resultSet.goToFirstRow();
      if (!exists) {
        resultSet.close();
        return undefined;
      }
      const record = await this.buildRecord(resultSet);
      resultSet.close();
      return record;
    });
  }

  async getDiaryByDate(context: common.UIAbilityContext, date: string): Promise<DiaryRecord | undefined> {
    await this.ensureReady(context);
    return this.runDbTask(async () => {
      const resultSet = await this.ensureStore().querySql('SELECT * FROM diaries WHERE date = ? LIMIT 1', [date]);
      const exists = resultSet.goToFirstRow();
      if (!exists) {
        resultSet.close();
        return undefined;
      }
      const record = await this.buildRecord(resultSet);
      resultSet.close();
      return record;
    });
  }

  async getEntriesByMonth(context: common.UIAbilityContext, year: number, month: number): Promise<DiaryListItem[]> {
    await this.ensureReady(context);
    const [startDate, endDate] = monthRange(year, month);
    return this.runDbTask(async () => {
      const resultSet = await this.ensureStore().querySql('SELECT * FROM diaries WHERE date >= ? AND date <= ? ORDER BY date ASC', [startDate, endDate]);
      const entries: DiaryListItem[] = [];
      while (resultSet.goToNextRow()) {
        const record = await this.buildRecord(resultSet);
        entries.push({
          id: record.id,
          title: record.title.length > 0 ? record.title : '无标题日记',
          excerpt: buildExcerpt(record.content),
          mood: record.mood,
          date: record.date,
          updatedAt: record.updatedAt,
          imagePaths: record.imagePaths
        });
      }
      resultSet.close();
      return entries;
    });
  }

  async search(context: common.UIAbilityContext, keyword: string): Promise<DiarySearchResult[]> {
    await this.ensureReady(context);
    const normalized = keyword.trim();
    if (normalized.length === 0) {
      return [];
    }
    return this.runDbTask(async () => {
      const resultSet = await this.ensureStore().querySql('SELECT d.* FROM diary_fts f INNER JOIN diaries d ON f.diary_id = d.id WHERE diary_fts MATCH ? ORDER BY d.updated_at DESC LIMIT 50', [normalized]);
      const results: DiarySearchResult[] = [];
      while (resultSet.goToNextRow()) {
        const record = await this.buildRecord(resultSet);
        results.push({
          id: record.id,
          title: record.title.length > 0 ? record.title : '无标题日记',
          snippet: buildExcerpt(record.content, 120),
          mood: record.mood,
          date: record.date
        });
      }
      resultSet.close();
      return results;
    });
  }

  async getStats(context: common.UIAbilityContext): Promise<DiaryStatsSummary> {
    await this.ensureReady(context);
    const allEntries = await this.getRecentDiaries(context, 500);
    const today = new Date();
    const [startDate, endDate] = monthRange(today.getFullYear(), today.getMonth() + 1);
    const monthlyCount = allEntries.filter((item: DiaryListItem) => item.date >= startDate && item.date <= endDate).length;
    const moodCounts = new Map<DiaryMood, number>();
    getMoodOptions().forEach((option) => moodCounts.set(option.mood, 0));
    allEntries.forEach((item: DiaryListItem) => {
      moodCounts.set(item.mood, (moodCounts.get(item.mood) ?? 0) + 1);
    });
    const moods: MoodStat[] = getMoodOptions().map((option) => {
      const count = moodCounts.get(option.mood) ?? 0;
      return {
        mood: option.mood,
        count,
        percentage: allEntries.length === 0 ? 0 : count / allEntries.length,
        label: option.label,
        color: option.color
      };
    }).filter((item: MoodStat) => item.count > 0);

    return {
      totalCount: allEntries.length,
      monthlyCount,
      streak: computeStreak(allEntries.map((item: DiaryListItem) => item.date)),
      moods
    };
  }

  async latestMood(context: common.UIAbilityContext): Promise<string> {
    const items = await this.getRecentDiaries(context, 1);
    if (items.length === 0) {
      return '今天还没有新的心情记录';
    }
    return `${todayKey()} 最近一篇是${getMoodOption(items[0].mood).label}`;
  }
}

export const diaryRepository = DiaryRepository.getInstance();
