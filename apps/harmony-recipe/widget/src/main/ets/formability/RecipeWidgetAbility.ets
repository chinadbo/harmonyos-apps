import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formBindingData from '@ohos.app.form.formBindingData';
import formProvider from '@ohos.app.form.formProvider';

const DAILY_RECIPES: Array<Record<string, string>> = [
  { name: '番茄炒蛋', category: '早餐', description: '酸甜开胃，十分钟即可上桌', emoji: '🍅' },
  { name: '宫保鸡丁', category: '午餐', description: '咸鲜微辣，米饭绝佳搭档', emoji: '🥜' },
  { name: '红烧排骨', category: '晚餐', description: '酱香浓郁，口感软糯入味', emoji: '🍖' },
  { name: '红豆双皮奶', category: '甜品', description: '奶香顺滑，饭后治愈甜点', emoji: '🥛' }
];

export default class RecipeWidgetAbility extends FormExtensionAbility {
  onAddForm(): formBindingData.FormBindingData {
    return this.createBindingData(new Date().getDate());
  }

  onUpdateForm(formId: number): void {
    const bindingData = this.createBindingData(formId);
    formProvider.updateForm(formId, bindingData);
  }

  private createBindingData(seed: number): formBindingData.FormBindingData {
    const recipe = DAILY_RECIPES[Math.abs(seed) % DAILY_RECIPES.length];
    return formBindingData.createFormBindingData({
      widgetRecipeName: recipe.name,
      widgetRecipeCategory: recipe.category,
      widgetRecipeDescription: recipe.description,
      widgetRecipeEmoji: recipe.emoji
    });
  }
}
