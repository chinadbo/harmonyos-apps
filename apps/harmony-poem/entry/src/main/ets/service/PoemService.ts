import common from '@ohos.app.ability.common';
import { Poem } from '../model/Poem';

export class PoemService {
  static async loadPoems(context: common.UIAbilityContext): Promise<Poem[]> {
    const raw = await context.resourceManager.getRawFileContent('poems.json');
    const text = String.fromCharCode(...new Uint8Array(raw));
    return JSON.parse(text) as Poem[];
  }

  static searchPoems(poems: Poem[], keyword: string): Poem[] {
    const normalized = keyword.trim();
    if (!normalized) {
      return poems;
    }
    return poems.filter((poem: Poem) => {
      const fullText = [
        poem.title,
        poem.author,
        poem.dynasty,
        poem.genre,
        poem.appreciation,
        poem.content.join(''),
        poem.annotation.join(''),
        poem.tags.join(' ')
      ].join(' ');
      return fullText.indexOf(normalized) >= 0;
    });
  }

  static filterByDynasty(poems: Poem[], dynasty: string): Poem[] {
    if (dynasty === '全部') {
      return poems;
    }
    return poems.filter((poem: Poem) => poem.dynasty === dynasty);
  }

  static filterByAuthor(poems: Poem[], author: string): Poem[] {
    if (author === '全部') {
      return poems;
    }
    return poems.filter((poem: Poem) => poem.author === author);
  }

  static filterByGenre(poems: Poem[], genre: string): Poem[] {
    if (genre === '全部') {
      return poems;
    }
    return poems.filter((poem: Poem) => poem.genre === genre);
  }

  static getById(poems: Poem[], id: number): Poem | null {
    const result = poems.find((poem: Poem) => poem.id === id);
    return result ? result : null;
  }
}
