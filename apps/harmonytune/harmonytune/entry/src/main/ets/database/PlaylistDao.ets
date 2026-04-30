import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { DatabaseHelper } from './DatabaseHelper';
import { PlaylistEntity } from '../model/PlaylistEntity';
import { SongEntity } from '../model/SongEntity';

export class PlaylistDao {
  private dbHelper: DatabaseHelper = DatabaseHelper.getInstance();

  async getPlaylists(context: common.UIAbilityContext): Promise<PlaylistEntity[]> {
    const store = await this.dbHelper.getStore(context);
    const resultSet = await store.querySql('SELECT * FROM playlists ORDER BY created_at DESC');
    const playlists: PlaylistEntity[] = [];
    try {
      while (resultSet.goToNextRow()) {
        const playlistId = Number(resultSet.getLong(resultSet.getColumnIndex('id')));
        const songs = await this.getSongsByPlaylist(context, playlistId);
        playlists.push(new PlaylistEntity({
          id: playlistId,
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          createdAt: Number(resultSet.getLong(resultSet.getColumnIndex('created_at'))),
          songs
        }));
      }
    } finally {
      resultSet.close();
    }
    return playlists;
  }

  async createPlaylist(context: common.UIAbilityContext, name: string): Promise<number> {
    const store = await this.dbHelper.getStore(context);
    return Number(await store.insert('playlists', {
      name,
      created_at: Date.now()
    }));
  }

  async deletePlaylist(context: common.UIAbilityContext, playlistId: number): Promise<void> {
    const store = await this.dbHelper.getStore(context);
    await store.executeSql('DELETE FROM playlist_songs WHERE playlist_id = ?', [playlistId]);
    await store.executeSql('DELETE FROM playlists WHERE id = ?', [playlistId]);
  }

  async addSongToPlaylist(context: common.UIAbilityContext, playlistId: number, songId: number, position: number): Promise<void> {
    const store = await this.dbHelper.getStore(context);
    await store.insertWithConflictResolution('playlist_songs', {
      playlist_id: playlistId,
      song_id: songId,
      position
    }, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
  }

  async removeSongFromPlaylist(context: common.UIAbilityContext, playlistId: number, songId: number): Promise<void> {
    const store = await this.dbHelper.getStore(context);
    await store.executeSql('DELETE FROM playlist_songs WHERE playlist_id = ? AND song_id = ?', [playlistId, songId]);
  }

  async getSongsByPlaylist(context: common.UIAbilityContext, playlistId: number): Promise<SongEntity[]> {
    const store = await this.dbHelper.getStore(context);
    const resultSet = await store.querySql(`SELECT s.* FROM songs s
      INNER JOIN playlist_songs ps ON ps.song_id = s.id
      WHERE ps.playlist_id = ?
      ORDER BY ps.position ASC`, [playlistId]);
    const songs: SongEntity[] = [];
    try {
      while (resultSet.goToNextRow()) {
        songs.push(SongEntity.fromRow({
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
    return songs;
  }
}
