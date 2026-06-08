import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formBindingData from '@ohos.app.form.formBindingData';
import formInfo from '@ohos.app.form.formInfo';
import preferences from '@ohos.data.preferences';
import hilog from '@ohos.hilog';
import Want from '@ohos.app.ability.Want';

const TAG: string = 'TaskFormExtension';
const DOMAIN: number = 0xFF00;
const WIDGET_PREFS: string = 'widget_data';

interface WidgetTask {
  title: string;
  priority: number;
  status: number;
}

interface WidgetData {
  pendingCount: number;
  todayCount: number;
  tasks: WidgetTask[];
  formId: string;
}

export default class TaskFormExtensionAbility extends FormExtensionAbility {

  onCreate(want: Want): formBindingData.FormBindingData {
    hilog.info(DOMAIN, TAG, 'onCreate');
    const formId = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string || '';
    const data = this.getWidgetData(formId);
    return formBindingData.createFormBindingData(JSON.stringify(data));
  }

  onCastToNormal(formId: string): void {
    hilog.info(DOMAIN, TAG, 'onCastToNormal formId: %{public}s', formId);
  }

  onUpdate(formId: string): void {
    hilog.info(DOMAIN, TAG, 'onUpdate formId: %{public}s', formId);
    const data = this.getWidgetData(formId);
    const bindingData = formBindingData.createFormBindingData(JSON.stringify(data));
    this.context.updateForm(formId, bindingData).catch((err: Error) => {
      hilog.error(DOMAIN, TAG, 'updateForm error: %{public}s', JSON.stringify(err));
    });
  }

  onChangeFormVisibility(newStatus: Record<string, number>): void {
    hilog.info(DOMAIN, TAG, 'onChangeFormVisibility');
  }

  onFormEvent(formId: string, message: string): void {
    hilog.info(DOMAIN, TAG, 'onFormEvent formId: %{public}s, message: %{public}s', formId, message);
  }

  onRemoveForm(formId: string): void {
    hilog.info(DOMAIN, TAG, 'onRemoveForm formId: %{public}s', formId);
  }

  onNewWant(want: Want): void {
    hilog.info(DOMAIN, TAG, 'onNewWant');
    const formId = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string || '';
    const data = this.getWidgetData(formId);
    const bindingData = formBindingData.createFormBindingData(JSON.stringify(data));
    this.context.updateForm(formId, bindingData).catch((err: Error) => {
      hilog.error(DOMAIN, TAG, 'onNewWant updateForm error: %{public}s', JSON.stringify(err));
    });
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY;
  }

  private getWidgetData(formId: string): WidgetData {
    try {
      const prefs = preferences.getPreferencesSync(this.context, { name: WIDGET_PREFS });
      const pendingCount = prefs.getSync('pending_count', 0) as number;
      const todayCount = prefs.getSync('today_count', 0) as number;
      const tasksStr = prefs.getSync('top_tasks', '[]') as string;
      const tasks: WidgetTask[] = JSON.parse(tasksStr);
      return { pendingCount, todayCount, tasks, formId };
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'getWidgetData error: %{public}s', JSON.stringify(err));
      return { pendingCount: 0, todayCount: 0, tasks: [], formId };
    }
  }
}
