import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formBindingData from '@ohos.app.form.formBindingData';
import Want from '@ohos.app.ability.Want';
import formInfo from '@ohos.app.form.formInfo';
import { moonWidgetCalc } from './widgetCalc';

export default class MoonWidget extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    // 卡片唯一标识，由框架自动生成
    const formId = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string;
    const calc = moonWidgetCalc(new Date());
    const data: Record<string, Object> = {
      'formId': formId === undefined ? '' : formId,
      'title': '今日月相',
      'dateLabel': calc.dateLabel,
      'phase': calc.phase,
      'phaseName': calc.phaseName,
      'illumination': `${calc.illuminationPercent}%`,
      'ageDays': `月龄 ${calc.ageDays.toFixed(1)} 天`
    };
    return formBindingData.createFormBindingData(data);
  }

  onCastToNormalForm(formId: string): void {
  }

  onUpdateForm(formId: string): void {
    // 定时刷新时框架会调用，静态卡片按 onAddForm 数据展示即可
  }

  onFormEvent(formId: string, message: Record<string, Object>): void {
  }

  onRemoveForm(formId: string): void {
  }
}
