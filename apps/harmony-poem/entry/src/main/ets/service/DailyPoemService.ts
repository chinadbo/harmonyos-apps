import { Poem } from '../model/Poem';

export class DailyPoemService {
  static getDailyPoem(poems: Poem[]): Poem | null {
    if (!poems || poems.length === 0) {
      return null;
    }
    const now = new Date();
    const dayOfYear = Math.floor((now.getTime() - new Date(now.getFullYear(), 0, 0).getTime()) / 86400000);
    return poems[dayOfYear % poems.length];
  }
}
