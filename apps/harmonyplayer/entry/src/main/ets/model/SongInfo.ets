@Observed
export class SongInfo {
  id: number = 0;
  title: string = '';
  artist: string = '';
  album: string = '';
  duration: number = 0;
  uri: string = '';
  coverUri: string = '';
  lyricPath: string = '';
  isFavorite: boolean = false;
}
