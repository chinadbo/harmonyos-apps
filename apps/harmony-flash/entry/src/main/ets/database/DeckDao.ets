import relationalStore from '@ohos.data.relationalStore';
import { Deck } from '../model/Deck';

export class DeckDao {
  private store: relationalStore.RdbStore;

  constructor(store: relationalStore.RdbStore) {
    this.store = store;
  }

  async getAll(): Promise<Deck[]> {
    const predicates = new relationalStore.RdbPredicates('decks');
    predicates.orderByAsc('created_at');
    const cursor = await this.store.query(predicates,
      ['id', 'name', 'description', 'card_count', 'mastered_count', 'created_at', 'is_built_in']);
    const decks: Deck[] = [];
    while (cursor.goToNextRow()) {
      decks.push(this.rowToDeck(cursor));
    }
    cursor.close();
    return decks;
  }

  async getById(id: number): Promise<Deck | null> {
    const predicates = new relationalStore.RdbPredicates('decks');
    predicates.equalTo('id', id);
    const cursor = await this.store.query(predicates,
      ['id', 'name', 'description', 'card_count', 'mastered_count', 'created_at', 'is_built_in']);
    let deck: Deck | null = null;
    if (cursor.goToNextRow()) {
      deck = this.rowToDeck(cursor);
    }
    cursor.close();
    return deck;
  }

  async insert(deck: Deck): Promise<number> {
    const values: relationalStore.ValuesBucket = {
      name: deck.name,
      description: deck.description,
      card_count: deck.cardCount,
      mastered_count: deck.masteredCount,
      created_at: deck.createdAt,
      is_built_in: deck.isBuiltIn
    };
    const rowId = await this.store.insert('decks', values);
    return rowId;
  }

  async updateCounts(deckId: number, cardCount: number, masteredCount: number): Promise<void> {
    const values: relationalStore.ValuesBucket = {
      card_count: cardCount,
      mastered_count: masteredCount
    };
    const predicates = new relationalStore.RdbPredicates('decks');
    predicates.equalTo('id', deckId);
    await this.store.update(values, predicates);
  }

  async delete(deckId: number): Promise<void> {
    const predicates = new relationalStore.RdbPredicates('decks');
    predicates.equalTo('id', deckId);
    await this.store.delete(predicates);
  }

  private rowToDeck(cursor: relationalStore.ResultSet): Deck {
    return {
      id: cursor.getLong(cursor.getColumnIndex('id')),
      name: cursor.getString(cursor.getColumnIndex('name')),
      description: cursor.getString(cursor.getColumnIndex('description')),
      cardCount: cursor.getLong(cursor.getColumnIndex('card_count')),
      masteredCount: cursor.getLong(cursor.getColumnIndex('mastered_count')),
      createdAt: cursor.getLong(cursor.getColumnIndex('created_at')),
      isBuiltIn: cursor.getLong(cursor.getColumnIndex('is_built_in'))
    };
  }
}
