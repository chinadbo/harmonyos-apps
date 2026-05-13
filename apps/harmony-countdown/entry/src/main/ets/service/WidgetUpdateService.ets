import common from '@ohos.app.ability.common';
import formProvider from '@ohos.app.form.formProvider';
import formBindingData from '@ohos.app.form.formBindingData';
import dataPreferences from '@ohos.data.preferences';
import { CountdownEvent } from '../model/CountdownEvent';
import { DateUtils } from '../utils/DateUtils';

class WidgetUpdateService {
  private preferences?: dataPreferences.Preferences;

  async init(context: common.UIAbilityContext): Promise<void> {
    if (!this.preferences) {
      this.preferences = await dataPreferences.getPreferences(context, 'widget_forms');
    }
  }

  async saveFormId(formId: string): Promise<void> {
    if (!this.preferences) {
      return;
    }
    let formIds: string[] = this.preferences.getSync('formIds', []) as string[];
    if (formIds.indexOf(formId) < 0) {
      formIds.push(formId);
      await this.preferences.put('formIds', formIds);
      await this.preferences.flush();
    }
  }

  async removeFormId(formId: string): Promise<void> {
    if (!this.preferences) {
      return;
    }
    let formIds: string[] = this.preferences.getSync('formIds', []) as string[];
    let filtered: string[] = formIds.filter((item: string) => item !== formId);
    await this.preferences.put('formIds', filtered);
    await this.preferences.flush();
  }

  async updateAllForms(events: CountdownEvent[]): Promise<void> {
    if (!this.preferences) {
      return;
    }
    let topEvent: CountdownEvent | undefined = DateUtils.sortEvents(events)[0];
    let formIds: string[] = this.preferences.getSync('formIds', []) as string[];
    for (let index = 0; index < formIds.length; index++) {
      let formId: string = formIds[index];
      let bindingData = formBindingData.createFormBindingData({
        title: topEvent ? topEvent.title : '暂无事件',
        dateText: topEvent ? DateUtils.formatDisplayDate(topEvent.targetDate) : '去添加第一个纪念日吧',
        countdownText: topEvent ? DateUtils.calculateDayInfo(topEvent).displayText : '开始记录重要日子',
        noteText: topEvent ? topEvent.note : 'HarmonyCountdown',
        eventCount: `${events.length}`
      });
      await formProvider.updateForm(Number(formId), bindingData);
    }
  }
}

export default new WidgetUpdateService();
