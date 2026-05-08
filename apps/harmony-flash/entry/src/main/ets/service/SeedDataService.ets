import relationalStore from '@ohos.data.relationalStore';
import { DeckDao } from '../database/DeckDao';
import { CardDao } from '../database/CardDao';
import { createDeck } from '../model/Deck';
import { createCard } from '../model/Card';

interface SeedWord {
  front: string;
  back: string;
  phonetic: string;
  example: string;
}

const CET4_WORDS: SeedWord[] = [
  { front: 'abandon', back: '放弃；遗弃', phonetic: '/əˈbændən/', example: 'He had to abandon his plan.' },
  { front: 'ability', back: '能力；才能', phonetic: '/əˈbɪlɪti/', example: 'She has the ability to learn quickly.' },
  { front: 'abroad', back: '在国外；到国外', phonetic: '/əˈbrɔːd/', example: 'He studied abroad for two years.' },
  { front: 'absence', back: '缺席；不在', phonetic: '/ˈæbsəns/', example: 'His absence was noticed by everyone.' },
  { front: 'absolute', back: '绝对的；完全的', phonetic: '/ˈæbsəluːt/', example: 'She has absolute confidence in him.' },
  { front: 'absorb', back: '吸收；吸引', phonetic: '/əbˈzɔːrb/', example: 'Plants absorb sunlight to make food.' },
  { front: 'abstract', back: '抽象的；摘要', phonetic: '/ˈæbstrækt/', example: 'Art can be abstract or realistic.' },
  { front: 'academic', back: '学术的；学业的', phonetic: '/ˌækəˈdemɪk/', example: 'Her academic performance was excellent.' },
  { front: 'access', back: '进入；获取；通道', phonetic: '/ˈækses/', example: 'Everyone should have access to education.' },
  { front: 'accident', back: '事故；意外', phonetic: '/ˈæksɪdənt/', example: 'He was injured in a car accident.' },
  { front: 'achieve', back: '达到；实现', phonetic: '/əˈtʃiːv/', example: 'Hard work helps you achieve your goals.' },
  { front: 'acquire', back: '获得；习得', phonetic: '/əˈkwaɪər/', example: 'He acquired new skills at work.' },
  { front: 'adapt', back: '适应；改编', phonetic: '/əˈdæpt/', example: 'Animals can adapt to new environments.' },
  { front: 'adequate', back: '充足的；适当的', phonetic: '/ˈædɪkwət/', example: 'Make sure you get adequate sleep.' },
  { front: 'adjust', back: '调整；适应', phonetic: '/əˈdʒʌst/', example: 'You need to adjust to the new schedule.' },
  { front: 'admire', back: '钦佩；欣赏', phonetic: '/ədˈmaɪər/', example: 'I admire her courage and determination.' },
  { front: 'advance', back: '前进；进展；提前', phonetic: '/ədˈvæns/', example: 'Technology continues to advance rapidly.' },
  { front: 'advantage', back: '优势；好处', phonetic: '/ədˈvɑːntɪdʒ/', example: 'Being bilingual is a great advantage.' },
  { front: 'affect', back: '影响；感动', phonetic: '/əˈfekt/', example: 'Weather can affect your mood.' },
  { front: 'afford', back: '负担得起；提供', phonetic: '/əˈfɔːrd/', example: 'I cannot afford a new car right now.' }
];

export class SeedDataService {
  private deckDao: DeckDao;
  private cardDao: CardDao;

  constructor(store: relationalStore.RdbStore) {
    this.deckDao = new DeckDao(store);
    this.cardDao = new CardDao(store);
  }

  async seedIfEmpty(): Promise<void> {
    const decks = await this.deckDao.getAll();
    if (decks.length > 0) {
      // 已有数据，不重复初始化
      return;
    }
    await this.seedCET4();
  }

  private async seedCET4(): Promise<void> {
    const deck = createDeck('CET-4 核心词汇', '大学英语四级高频词汇，共 20 词', 1);
    const deckId = await this.deckDao.insert(deck);

    const now = Date.now();
    for (const word of CET4_WORDS) {
      const card = createCard(deckId, word.front, word.back, word.phonetic, word.example);
      // 初始时均设为今日待复习
      card.nextReviewDate = now;
      await this.cardDao.insert(card);
    }

    // 更新 deck 计数
    await this.deckDao.updateCounts(deckId, CET4_WORDS.length, 0);
  }
}
