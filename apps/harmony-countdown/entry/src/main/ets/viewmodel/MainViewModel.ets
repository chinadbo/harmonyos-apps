import common from '@ohos.app.ability.common';
import DatabaseService from '../service/DatabaseService';
import ReminderService from '../service/ReminderService';
import WidgetUpdateService from '../service/WidgetUpdateService';
import { CountdownEvent } from '../model/CountdownEvent';
import { DateUtils } from '../utils/DateUtils';

export class MainViewModel {
  private context?: common.UIAbilityContext;
  events: CountdownEvent[] = [];

  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    await DatabaseService.init(context);
    await WidgetUpdateService.init(context);
    await this.refresh();
  }

  async refresh(): Promise<CountdownEvent[]> {
    this.events = DateUtils.sortEvents(await DatabaseService.listEvents());
    await WidgetUpdateService.updateAllForms(this.events);
    return this.events;
  }

  async deleteEvent(id: number): Promise<void> {
    await DatabaseService.deleteEvent(id);
    await this.refresh();
  }

  async enableReminder(event: CountdownEvent): Promise<void> {
    if (!this.context) {
      return;
    }
    await ReminderService.requestNotification(this.context);
    await ReminderService.syncReminder(event);
  }
}
