import relationalStore from '@ohos.data.relationalStore';
import { Card } from '../model/Card';

const CARD_COLS = ['id', 'deck_id', 'front', 'back', 'phonetic', 'example',
  'ease_factor', 'interval', 'repetitions', 'next_review_date', 'mastery_level'];

export class CardDao {
  private store: relationalStore.RdbStore;

  constructor(store: relationalStore.RdbStore) {
    this.store = store;
  }

  async getByDeck(deckId: number): Promise<Card[]> {
    const predicates = new relationalStore.RdbPredicates('cards');
    predicates.equalTo('deck_id', deckId).orderByAsc('front');
    const cursor = await this.store.query(predicates, CARD_COLS);
    const cards: Card[] = [];
    while (cursor.goToNextRow()) {
      cards.push(this.rowToCard(cursor));
    }
    cursor.close();
    return cards;
  }

  async getTodayDue(): Promise<Card[]> {
    const todayEnd = new Date();
    todayEnd.setHours(23, 59, 59, 999);
    const predicates = new relationalStore.RdbPredicates('cards');
    predicates.lessThanOrEqualTo('next_review_date', todayEnd.getTime());
    predicates.orderByAsc('next_review_date');
    const cursor = await this.store.query(predicates, CARD_COLS);
    const cards: Card[] = [];
    while (cursor.goToNextRow()) {
      cards.push(this.rowToCard(cursor));
    }
    cursor.close();
    return cards;
  }

  async getTodayDueCount(): Promise<number> {
    const cards = await this.getTodayDue();
    return cards.length;
  }

  async getFirstCard(): Promise<Card | null> {
    const predicates = new relationalStore.RdbPredicates('cards');
    predicates.orderByAsc('id').limitAs(1);
    const cursor = await this.store.query(predicates, CARD_COLS);
    let card: Card | null = null;
    if (cursor.goToNextRow()) {
      card = this.rowToCard(cursor);
    }
    cursor.close();
    return card;
  }

  async insert(card: Card): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      deck_id: card.deckId,
      front: card.front,
      back: card.back,
      phonetic: card.phonetic,
      example: card.example,
      ease_factor: card.easeFactor,
      interval: card.interval,
      repetitions: card.repetitions,
      next_review_date: card.nextReviewDate,
      mastery_level: card.masteryLevel
    };
    return await this.store.insert('cards', values);
  }

  async updateSM2(card: Card): Promise<void> {
    const values: relationalStore.ValuesBucket = {
      ease_factor: card.easeFactor,
      interval: card.interval,
      repetitions: card.repetitions,
      next_review_date: card.nextReviewDate,
      mastery_level: card.masteryLevel
    };
    const predicates = new relationalStore.RdbPredicates('cards');
    predicates.equalTo('id', card.id);
    await this.store.update(values, predicates);
  }

  async update(card: Card): Promise<void> {
    const values: relationalStore.ValuesBucket = {
      front: card.front,
      back: card.back,
      phonetic: card.phonetic,
      example: card.example,
      ease_factor: card.easeFactor,
      interval: card.interval,
      repetitions: card.repetitions,
      next_review_date: card.nextReviewDate,
      mastery_level: card.masteryLevel
    };
    const predicates = new relationalStore.RdbPredicates('cards');
    predicates.equalTo('id', card.id);
    await this.store.update(values, predicates);
  }

  async delete(cardId: number): Promise<void> {
    const predicates = new relationalStore.RdbPredicates('cards');
    predicates.equalTo('id', cardId);
    await this.store.delete(predicates);
  }

  async deleteByDeck(deckId: number): Promise<void> {
    const predicates = new relationalStore.RdbPredicates('cards');
    predicates.equalTo('deck_id', deckId);
    await this.store.delete(predicates);
  }

  async countByDeck(deckId: number): Promise<number> {
    const cards = await this.getByDeck(deckId);
    return cards.length;
  }

  async countMasteredByDeck(deckId: number): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('cards');
    predicates.equalTo('deck_id', deckId).greaterThanOrEqualTo('mastery_level', 3);
    const cursor = await this.store.query(predicates, ['id']);
    let count = 0;
    while (cursor.goToNextRow()) {
      count++;
    }
    cursor.close();
    return count;
  }

  private rowToCard(cursor: relationalStore.ResultSet): Card {
    return {
      id: cursor.getLong(cursor.getColumnIndex('id')),
      deckId: cursor.getLong(cursor.getColumnIndex('deck_id')),
      front: cursor.getString(cursor.getColumnIndex('front')),
      back: cursor.getString(cursor.getColumnIndex('back')),
      phonetic: cursor.getString(cursor.getColumnIndex('phonetic')),
      example: cursor.getString(cursor.getColumnIndex('example')),
      easeFactor: cursor.getDouble(cursor.getColumnIndex('ease_factor')),
      interval: cursor.getLong(cursor.getColumnIndex('interval')),
      repetitions: cursor.getLong(cursor.getColumnIndex('repetitions')),
      nextReviewDate: cursor.getLong(cursor.getColumnIndex('next_review_date')),
      masteryLevel: cursor.getLong(cursor.getColumnIndex('mastery_level'))
    };
  }
}
