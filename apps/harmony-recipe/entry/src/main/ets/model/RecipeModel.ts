export interface Ingredient {
  name: string;
  amount: string;
}

export interface Step {
  index: number;
  description: string;
  duration: number;
}

export interface Recipe {
  id: number;
  name: string;
  category: string;
  description: string;
  coverImage: string;
  cookTime: number;
  servings: number;
  difficulty: string;
  ingredients: Ingredient[];
  steps: Step[];
  isFavorite: boolean;
  createdAt: string;
}

export interface RecipeSeedFile {
  recipes: Array<{
    id: number;
    name: string;
    category: string;
    description: string;
    coverImage?: string;
    cookTime: number;
    servings: number;
    difficulty: string;
    ingredients: Ingredient[];
    steps: Step[];
  }>;
}

export const EMPTY_RECIPE: Recipe = {
  id: 0,
  name: '',
  category: '',
  description: '',
  coverImage: '🍽️',
  cookTime: 0,
  servings: 0,
  difficulty: '',
  ingredients: [],
  steps: [],
  isFavorite: false,
  createdAt: ''
};
