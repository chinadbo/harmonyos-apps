import dataPreferences from '@ohos.data.preferences';
import { FavoriteItem } from '../model/FileItem';

const STORE_NAME = 'file_manager_favorites';
const FAVORITES_KEY = 'favorites_json';

export class FavoritesService {
  private static instance: FavoritesService;
  private preferences: dataPreferences.Preferences | null = null;

  private constructor() {}

  static getInstance(): FavoritesService {
    if (!FavoritesService.instance) {
      FavoritesService.instance = new FavoritesService();
    }
    return FavoritesService.instance;
  }

  async init(context: Context): Promise<void> {
    this.preferences = await dataPreferences.getPreferences(context, STORE_NAME);
  }

  async getFavorites(): Promise<FavoriteItem[]> {
    if (!this.preferences) {
      return [];
    }
    const raw = await this.preferences.get(FAVORITES_KEY, '[]') as string;
    try {
      return JSON.parse(raw) as FavoriteItem[];
    } catch (e) {
      return [];
    }
  }

  async addFavorite(path: string, name: string): Promise<void> {
    const favorites = await this.getFavorites();
    const alreadyExists = favorites.some(f => f.path === path);
    if (alreadyExists) {
      return;
    }
    const item: FavoriteItem = {
      id: `${Date.now()}_${Math.random().toString(36).substring(2, 9)}`,
      name,
      path,
      addedAt: Date.now()
    };
    favorites.push(item);
    await this.preferences!.put(FAVORITES_KEY, JSON.stringify(favorites));
    await this.preferences!.flush();
  }

  async removeFavorite(id: string): Promise<void> {
    const favorites = await this.getFavorites();
    const updated = favorites.filter(f => f.id !== id);
    await this.preferences!.put(FAVORITES_KEY, JSON.stringify(updated));
    await this.preferences!.flush();
  }

  async isFavorite(path: string): Promise<boolean> {
    const favorites = await this.getFavorites();
    return favorites.some(f => f.path === path);
  }
}
