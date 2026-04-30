@ObservedV2
export class SongEntity {
  id: number = 0;
  title: string = '';
  artist: string = '';
  album: string = '';
  duration: number = 0;
  path: string = '';
  coverPath: string = '';
  addedAt: number = 0;
  playCount: number = 0;
  isFavorite: boolean = false;
  lyrics: string[] = [];

  constructor(init?: Partial<SongEntity>) {
    Object.assign(this, init);
    this.title = this.title || 'Unknown Song';
    this.artist = this.artist || 'Unknown Artist';
    this.album = this.album || 'Unknown Album';
    this.coverPath = this.coverPath || '';
    this.addedAt = this.addedAt || Date.now();
    this.lyrics = this.lyrics?.length ? this.lyrics : SongEntity.createPlaceholderLyrics(this.title, this.artist);
  }

  static empty(): SongEntity {
    return new SongEntity({
      title: '',
      artist: '',
      album: '',
      duration: 0,
      path: '',
      coverPath: '',
      playCount: 0,
      isFavorite: false,
      lyrics: []
    });
  }

  static fromRow(row: Record<string, Object>): SongEntity {
    return new SongEntity({
      id: Number(row.id ?? 0),
      title: String(row.title ?? ''),
      artist: String(row.artist ?? ''),
      album: String(row.album ?? ''),
      duration: Number(row.duration ?? 0),
      path: String(row.path ?? ''),
      coverPath: String(row.cover_path ?? ''),
      addedAt: Number(row.added_at ?? 0),
      playCount: Number(row.play_count ?? 0),
      isFavorite: Number(row.is_favorite ?? 0) === 1,
      lyrics: SongEntity.createPlaceholderLyrics(String(row.title ?? ''), String(row.artist ?? ''))
    });
  }

  toValuesBucket(): Record<string, Object> {
    return {
      id: this.id,
      title: this.title,
      artist: this.artist,
      album: this.album,
      duration: this.duration,
      path: this.path,
      cover_path: this.coverPath,
      added_at: this.addedAt,
      play_count: this.playCount,
      is_favorite: this.isFavorite ? 1 : 0
    };
  }

  clone(): SongEntity {
    return new SongEntity({
      id: this.id,
      title: this.title,
      artist: this.artist,
      album: this.album,
      duration: this.duration,
      path: this.path,
      coverPath: this.coverPath,
      addedAt: this.addedAt,
      playCount: this.playCount,
      isFavorite: this.isFavorite,
      lyrics: [...this.lyrics]
    });
  }

  static createPlaceholderLyrics(title: string, artist: string): string[] {
    const safeTitle: string = title || 'HarmonyTune';
    const safeArtist: string = artist || 'Unknown Artist';
    return [
      `欢迎来到 ${safeTitle} 的旋律时刻`,
      `耳机戴好，跟随 ${safeArtist} 的节奏慢慢呼吸`,
      '让低频落下，让情绪慢慢升温',
      '每一次鼓点都在提示下一段心动',
      '把纷扰放远，只留下声音与光',
      '此刻没有歌词，也能拥有完整氛围',
      'HarmonyTune 正在为你守住这一段节拍',
      '当旋律推进，回忆也会被轻轻点亮',
      '把喜欢的歌收藏成你的私人宇宙',
      '下一句歌词，也许就在下一次播放里'
    ];
  }
}
