import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formBindingData from '@ohos.app.form.formBindingData';
import formProvider from '@ohos.app.form.formProvider';
import Want from '@ohos.app.ability.Want';
import { ContactDao } from '../database/ContactDao';
import { DateUtils } from '../utils/DateUtils';

export default class HarmonyBirthFormAbility extends FormExtensionAbility {
  async onAddForm(want: Want): Promise<formBindingData.FormBindingData> {
    return this.buildFormData();
  }

  async onUpdateForm(formId: string): Promise<void> {
    let data = await this.buildFormData();
    await formProvider.updateForm(formId, data);
  }

  async onFormEvent(formId: string, message: string): Promise<void> {
    if (message === 'refresh') {
      let data = await this.buildFormData();
      await formProvider.updateForm(formId, data);
    }
  }

  async onRemoveForm(_formId: string): Promise<void> {
  }

  private async buildFormData(): Promise<formBindingData.FormBindingData> {
    let contacts = await ContactDao.getAll(this.context);
    let upcoming = DateUtils.sortContactsByUpcoming(contacts).slice(0, 3);
    let payload = {
      title: '最近生日',
      items: upcoming.map(item => {
        return {
          name: item.contact.name,
          birthday: DateUtils.formatMonthDay(item.contact.birthday),
          countdown: item.daysUntil === 0 ? '今天' : `${item.daysUntil}天`
        };
      })
    };
    return formBindingData.createFormBindingData(payload);
  }
}
