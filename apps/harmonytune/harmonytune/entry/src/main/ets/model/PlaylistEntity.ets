import { SongEntity } from './SongEntity';

@ObservedV2
export class PlaylistEntity {
  id: number = 0;
  name: string = '';
  createdAt: number = 0;
  songs: SongEntity[] = [];

  constructor(init?: Partial<PlaylistEntity>) {
    Object.assign(this, init);
    this.createdAt = this.createdAt || Date.now();
    this.name = this.name || '未命名歌单';
    this.songs = this.songs || [];
  }

  static fromRow(row: Record<string, Object>, songs: SongEntity[] = []): PlaylistEntity {
    return new PlaylistEntity({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
      createdAt: Number(row.created_at ?? 0),
      songs
    });
  }

  toValuesBucket(): Record<string, Object> {
    return {
      id: this.id,
      name: this.name,
      created_at: this.createdAt
    };
  }

  clone(): PlaylistEntity {
    return new PlaylistEntity({
      id: this.id,
      name: this.name,
      createdAt: this.createdAt,
      songs: this.songs.map((song: SongEntity) => song.clone())
    });
  }
}
