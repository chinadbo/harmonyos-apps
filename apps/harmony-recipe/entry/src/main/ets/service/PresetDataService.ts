import common from '@ohos.app.ability.common';
import DatabaseService from './DatabaseService';
import presetData from '../data/recipes.json';
import { Recipe, RecipeSeedFile } from '../model/RecipeModel';

export default class PresetDataService {
  private static instance: PresetDataService = new PresetDataService();

  static getInstance(): PresetDataService {
    return PresetDataService.instance;
  }

  async importIfNeeded(context: common.UIAbilityContext): Promise<void> {
    const database = DatabaseService.getInstance();
    await database.init(context);
    const count = await database.getRecipeCount();
    if (count > 0) {
      return;
    }
    const source = presetData as RecipeSeedFile;
    const recipes: Recipe[] = source.recipes.map((item, index) => ({
      id: item.id,
      name: item.name,
      category: item.category,
      description: item.description,
      coverImage: item.coverImage ?? '🍽️',
      cookTime: item.cookTime,
      servings: item.servings,
      difficulty: item.difficulty,
      ingredients: item.ingredients,
      steps: item.steps,
      isFavorite: false,
      createdAt: new Date(2026, 0, index + 1).toISOString()
    }));
    await database.seedRecipes(recipes);
  }
}
