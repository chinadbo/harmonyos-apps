import { Recipe } from './RecipeModel';

export default class RecipeDataSource implements IDataSource {
  private recipes: Recipe[] = [];
  private listeners: DataChangeListener[] = [];

  totalCount(): number {
    return this.recipes.length;
  }

  getData(index: number): Recipe {
    return this.recipes[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) === -1) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    this.listeners = this.listeners.filter((item: DataChangeListener) => item !== listener);
  }

  setData(recipes: Recipe[]): void {
    this.recipes = [...recipes];
    this.notifyReload();
  }

  getAllData(): Recipe[] {
    return [...this.recipes];
  }

  private notifyReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      const target = listener as Record<string, () => void>;
      if (target && typeof target.onDataReloaded === 'function') {
        target.onDataReloaded();
      }
    });
  }
}
