import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { Ingredient, Recipe, Step } from '../model/RecipeModel';

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'harmony_recipe.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

export default class DatabaseService {
  private static instance: DatabaseService = new DatabaseService();
  private store?: relationalStore.RdbStore;
  private initialized: boolean = false;

  static getInstance(): DatabaseService {
    return DatabaseService.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.initialized && this.store) {
      return;
    }
    this.store = await relationalStore.getRdbStore(context, STORE_CONFIG);
    await this.store.executeSql(
      'CREATE TABLE IF NOT EXISTS recipes (' +
        'id INTEGER PRIMARY KEY, ' +
        'name TEXT NOT NULL, ' +
        'category TEXT NOT NULL, ' +
        'description TEXT NOT NULL, ' +
        'cover_image TEXT NOT NULL, ' +
        'cook_time INTEGER NOT NULL, ' +
        'servings INTEGER NOT NULL, ' +
        'difficulty TEXT NOT NULL, ' +
        'ingredients TEXT NOT NULL, ' +
        'steps TEXT NOT NULL, ' +
        'is_favorite INTEGER NOT NULL DEFAULT 0, ' +
        'created_at TEXT NOT NULL' +
      ')'
    );
    await this.store.executeSql(
      'CREATE VIRTUAL TABLE IF NOT EXISTS recipes_fts USING fts5(name, description, ingredients_text)'
    );
    this.initialized = true;
  }

  async getAllRecipes(): Promise<Recipe[]> {
    const resultSet = await this.getStore().querySql('SELECT * FROM recipes ORDER BY id ASC');
    return this.readRecipeList(resultSet);
  }

  async getRecipeById(id: number): Promise<Recipe | null> {
    const resultSet = await this.getStore().querySql('SELECT * FROM recipes WHERE id = ?', [id]);
    const recipes = await this.readRecipeList(resultSet);
    return recipes.length > 0 ? recipes[0] : null;
  }

  async searchRecipes(keyword: string): Promise<Recipe[]> {
    const trimmed = keyword.trim();
    if (!trimmed.length) {
      return this.getAllRecipes();
    }
    const resultSet = await this.getStore().querySql(
      'SELECT r.* FROM recipes r ' +
        'INNER JOIN recipes_fts f ON r.id = f.rowid ' +
        'WHERE recipes_fts MATCH ? ORDER BY r.id ASC',
      [`${trimmed}*`]
    );
    return this.readRecipeList(resultSet);
  }

  async toggleFavorite(id: number): Promise<boolean> {
    const recipe = await this.getRecipeById(id);
    if (!recipe) {
      return false;
    }
    const favoriteValue = recipe.isFavorite ? 0 : 1;
    await this.getStore().executeSql('UPDATE recipes SET is_favorite = ? WHERE id = ?', [favoriteValue, id]);
    return favoriteValue === 1;
  }

  async getFavorites(): Promise<Recipe[]> {
    const resultSet = await this.getStore().querySql('SELECT * FROM recipes WHERE is_favorite = 1 ORDER BY id ASC');
    return this.readRecipeList(resultSet);
  }

  async getRecipeCount(): Promise<number> {
    const resultSet = await this.getStore().querySql('SELECT COUNT(1) AS count FROM recipes');
    let total = 0;
    if (resultSet.goToFirstRow()) {
      total = resultSet.getLong(resultSet.getColumnIndex('count'));
    }
    resultSet.close();
    return total;
  }

  async seedRecipes(recipes: Recipe[]): Promise<void> {
    if (!recipes.length) {
      return;
    }
    const store = this.getStore();
    for (const recipe of recipes) {
      await store.executeSql(
        'INSERT OR REPLACE INTO recipes ' +
          '(id, name, category, description, cover_image, cook_time, servings, difficulty, ingredients, steps, is_favorite, created_at) ' +
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          recipe.id,
          recipe.name,
          recipe.category,
          recipe.description,
          recipe.coverImage,
          recipe.cookTime,
          recipe.servings,
          recipe.difficulty,
          JSON.stringify(recipe.ingredients),
          JSON.stringify(recipe.steps),
          recipe.isFavorite ? 1 : 0,
          recipe.createdAt
        ]
      );
      await store.executeSql(
        'INSERT OR REPLACE INTO recipes_fts(rowid, name, description, ingredients_text) VALUES (?, ?, ?, ?)',
        [recipe.id, recipe.name, recipe.description, this.flattenIngredients(recipe.ingredients)]
      );
    }
  }

  private getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('DatabaseService has not been initialized');
    }
    return this.store;
  }

  private flattenIngredients(ingredients: Ingredient[]): string {
    return ingredients.map((item: Ingredient) => `${item.name} ${item.amount}`).join(' ');
  }

  private async readRecipeList(resultSet: relationalStore.ResultSet): Promise<Recipe[]> {
    const recipes: Recipe[] = [];
    if (resultSet.goToFirstRow()) {
      do {
        recipes.push(this.mapRecipe(resultSet));
      } while (resultSet.goToNextRow());
    }
    resultSet.close();
    return recipes;
  }

  private mapRecipe(resultSet: relationalStore.ResultSet): Recipe {
    return {
      id: Number(resultSet.getLong(resultSet.getColumnIndex('id'))),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      category: resultSet.getString(resultSet.getColumnIndex('category')),
      description: resultSet.getString(resultSet.getColumnIndex('description')),
      coverImage: resultSet.getString(resultSet.getColumnIndex('cover_image')),
      cookTime: Number(resultSet.getLong(resultSet.getColumnIndex('cook_time'))),
      servings: Number(resultSet.getLong(resultSet.getColumnIndex('servings'))),
      difficulty: resultSet.getString(resultSet.getColumnIndex('difficulty')),
      ingredients: JSON.parse(resultSet.getString(resultSet.getColumnIndex('ingredients'))) as Ingredient[],
      steps: JSON.parse(resultSet.getString(resultSet.getColumnIndex('steps'))) as Step[],
      isFavorite: Number(resultSet.getLong(resultSet.getColumnIndex('is_favorite'))) === 1,
      createdAt: resultSet.getString(resultSet.getColumnIndex('created_at'))
    };
  }
}
