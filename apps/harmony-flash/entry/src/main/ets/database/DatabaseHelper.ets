import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';

const DB_NAME = 'harmonyflash.db';
const DB_VERSION = 1;

const CREATE_DECKS = `
  CREATE TABLE IF NOT EXISTS decks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    card_count INTEGER DEFAULT 0,
    mastered_count INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    is_built_in INTEGER DEFAULT 0
  )
`;

const CREATE_CARDS = `
  CREATE TABLE IF NOT EXISTS cards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    deck_id INTEGER NOT NULL,
    front TEXT NOT NULL,
    back TEXT NOT NULL,
    phonetic TEXT DEFAULT '',
    example TEXT DEFAULT '',
    ease_factor REAL DEFAULT 2.5,
    interval INTEGER DEFAULT 1,
    repetitions INTEGER DEFAULT 0,
    next_review_date INTEGER NOT NULL,
    mastery_level INTEGER DEFAULT 0
  )
`;

const CREATE_CARDS_IDX_DECK = `CREATE INDEX IF NOT EXISTS idx_cards_deck_id ON cards(deck_id)`;
const CREATE_CARDS_IDX_REVIEW = `CREATE INDEX IF NOT EXISTS idx_cards_next_review ON cards(next_review_date)`;

const CREATE_STUDY_RECORDS = `
  CREATE TABLE IF NOT EXISTS study_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    card_id INTEGER NOT NULL,
    deck_id INTEGER NOT NULL,
    quality INTEGER NOT NULL,
    review_date INTEGER NOT NULL
  )
`;

const CREATE_RECORDS_IDX = `CREATE INDEX IF NOT EXISTS idx_records_date ON study_records(review_date)`;

let rdbStore: relationalStore.RdbStore | null = null;

export async function getDB(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
  if (rdbStore) {
    return rdbStore;
  }
  const config: relationalStore.StoreConfig = {
    name: DB_NAME,
    securityLevel: relationalStore.SecurityLevel.S1
  };
  const store = await relationalStore.getRdbStore(context, config);
  await store.executeSql(CREATE_DECKS);
  await store.executeSql(CREATE_CARDS);
  await store.executeSql(CREATE_CARDS_IDX_DECK);
  await store.executeSql(CREATE_CARDS_IDX_REVIEW);
  await store.executeSql(CREATE_STUDY_RECORDS);
  await store.executeSql(CREATE_RECORDS_IDX);
  rdbStore = store;
  return rdbStore;
}
