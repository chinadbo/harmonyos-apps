import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { DatabaseHelper } from './DatabaseHelper';
import { SongEntity } from '../model/SongEntity';

export class SongDao {
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();

  async batchUpsert(context: common.UIAbilityContext, songs: SongEntity[]): Promise<void> {
    const store = await this.dbHelper.getStore(context);
    for (const song of songs) {
      await store.insertWithConflictResolution('songs', song.toValuesBucket(), relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
    }
  }

  async getAllSongs(context: common.UIAbilityContext): Promise<SongEntity[]> {
    const store = await this.dbHelper.getStore(context);
    const resultSet = await store.querySql('SELECT * FROM songs ORDER BY added_at DESC');
    return this.mapSongs(resultSet);
  }

  async searchSongs(context: common.UIAbilityContext, keyword: string): Promise<SongEntity[]> {
    const store = await this.dbHelper.getStore(context);
    const like = `%${keyword}%`;
    const resultSet = await store.querySql(
      'SELECT * FROM songs WHERE title LIKE ? OR artist LIKE ? OR album LIKE ? ORDER BY added_at DESC',
      [like, like, like]
    );
    return this.mapSongs(resultSet);
  }

  async getRecentSongs(context: common.UIAbilityContext, limit: number = 10): Promise<SongEntity[]> {
    const store = await this.dbHelper.getStore(context);
    const resultSet = await store.querySql('SELECT * FROM songs ORDER BY play_count DESC, added_at DESC LIMIT ?', [limit]);
    return this.mapSongs(resultSet);
  }

  async getFavoriteSongs(context: common.UIAbilityContext): Promise<SongEntity[]> {
    const store = await this.dbHelper.getStore(context);
    const resultSet = await store.querySql('SELECT * FROM songs WHERE is_favorite = 1 ORDER BY added_at DESC');
    return this.mapSongs(resultSet);
  }

  async getAlbumGroups(context: common.UIAbilityContext): Promise<Array<Record<string, Object>>> {
    const store = await this.dbHelper.getStore(context);
    const resultSet = await store.querySql(
      'SELECT album, COUNT(*) AS song_count, MAX(artist) AS artist, MAX(cover_path) AS cover_path FROM songs GROUP BY album ORDER BY album ASC'
    );
    return this.mapObjects(resultSet);
  }

  async getArtistGroups(context: common.UIAbilityContext): Promise<Array<Record<string, Object>>> {
    const store = await this.dbHelper.getStore(context);
    const resultSet = await store.querySql(
      'SELECT artist, COUNT(*) AS song_count, MAX(album) AS album FROM songs GROUP BY artist ORDER BY artist ASC'
    );
    return this.mapObjects(resultSet);
  }

  async incrementPlayCount(context: common.UIAbilityContext, songId: number): Promise<void> {
    const store = await this.dbHelper.getStore(context);
    await store.executeSql('UPDATE songs SET play_count = play_count + 1 WHERE id = ?', [songId]);
  }

  async toggleFavorite(context: common.UIAbilityContext, songId: number, isFavorite: boolean): Promise<void> {
    const store = await this.dbHelper.getStore(context);
    await store.executeSql('UPDATE songs SET is_favorite = ? WHERE id = ?', [isFavorite ? 1 : 0, songId]);
  }

  async clearRecent(context: common.UIAbilityContext): Promise<void> {
    const store = await this.dbHelper.getStore(context);
    await store.executeSql('UPDATE songs SET play_count = 0');
  }

  private mapSongs(resultSet: relationalStore.ResultSet): SongEntity[] {
    const items: SongEntity[] = [];
    try {
      while (resultSet.goToNextRow()) {
        items.push(SongEntity.fromRow({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          title: resultSet.getString(resultSet.getColumnIndex('title')),
          artist: resultSet.getString(resultSet.getColumnIndex('artist')),
          album: resultSet.getString(resultSet.getColumnIndex('album')),
          duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
          path: resultSet.getString(resultSet.getColumnIndex('path')),
          cover_path: resultSet.getString(resultSet.getColumnIndex('cover_path')),
          added_at: resultSet.getLong(resultSet.getColumnIndex('added_at')),
          play_count: resultSet.getLong(resultSet.getColumnIndex('play_count')),
          is_favorite: resultSet.getLong(resultSet.getColumnIndex('is_favorite'))
        }));
      }
    } finally {
      resultSet.close();
    }
    return items;
  }

  private mapObjects(resultSet: relationalStore.ResultSet): Array<Record<string, Object>> {
    const rows: Array<Record<string, Object>> = [];
    try {
      while (resultSet.goToNextRow()) {
        const row: Record<string, Object> = {};
        for (let index = 0; index < resultSet.columnCount; index++) {
          const name = resultSet.getColumnName(index);
          row[name] = resultSet.getString(index);
        }
        rows.push(row);
      }
    } finally {
      resultSet.close();
    }
    return rows;
  }
}
