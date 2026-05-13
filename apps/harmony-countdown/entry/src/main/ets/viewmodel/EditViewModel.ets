import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import DatabaseService from '../service/DatabaseService';
import ReminderService from '../service/ReminderService';
import WidgetUpdateService from '../service/WidgetUpdateService';
import { CountdownEvent, createDefaultEvent } from '../model/CountdownEvent';

export class EditViewModel {
  async load(context: common.UIAbilityContext, id: number): Promise<CountdownEvent> {
    await DatabaseService.init(context);
    await WidgetUpdateService.init(context);
    if (id <= 0) {
      return createDefaultEvent();
    }
    let event = await DatabaseService.getEventById(id);
    return event ? event : createDefaultEvent();
  }

  async save(context: common.UIAbilityContext, event: CountdownEvent): Promise<number> {
    await DatabaseService.init(context);
    await WidgetUpdateService.init(context);
    let now: number = Date.now();
    event.updatedAt = now;
    if (event.id <= 0) {
      event.createdAt = now;
    }
    let id = await DatabaseService.saveEvent(event);
    if (event.isReminderEnabled) {
      try {
        await ReminderService.requestNotification(context);
        await ReminderService.syncReminder({ ...event, id: id });
      } catch (error) {
        promptAction.showToast({ message: '提醒创建失败，请检查系统提醒容量' });
      }
    }
    let events = await DatabaseService.listEvents();
    await WidgetUpdateService.updateAllForms(events);
    return id;
  }
}
