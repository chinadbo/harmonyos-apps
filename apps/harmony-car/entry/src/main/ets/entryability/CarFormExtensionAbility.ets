import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formBindingData from '@ohos.app.form.formBindingData';
import Want from '@ohos.app.ability.Want';
import formInfo from '@ohos.app.form.formInfo';
import { databaseService } from '../services/DatabaseService';
import { buildWidgetOverview } from '../widget/WidgetDataHelper';
import { FORM_SMALL_NAME } from '../utils/Constants';

export default class CarFormExtensionAbility extends FormExtensionAbility {
  async onCreate(want: Want): Promise<formBindingData.FormBindingData> {
    await databaseService.init(this.context);
    const overview = await buildWidgetOverview();
    return formBindingData.createFormBindingData({
      plateNumber: overview.plateNumber,
      modelName: overview.modelName,
      mileageText: overview.mileageText,
      nextReminderText: overview.nextReminderText,
      totalCostText: overview.totalCostText,
      lastRecordText: overview.lastRecordText,
      reminderCountText: overview.reminderCountText,
      formName: want.parameters?.['ohos.extra.param.key.form_name'] ?? FORM_SMALL_NAME
    });
  }

  async onNewWant(want: Want): Promise<formBindingData.FormBindingData> {
    return await this.onCreate(want);
  }

  onCastToNormalForm(_formId: string): void {
  }

  onUpdate(_formId: string): void {
  }

  onVisibilityChange(_newStatus: Record<string, number>): void {
  }

  onFormEvent(_formId: string, _message: string): void {
  }

  onAcquireFormState(_want: Want): formInfo.FormState {
    return formInfo.FormState.READY;
  }
}
