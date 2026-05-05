import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import { MOTIVATION_QUOTES, WIDGET_PREFERENCES } from '../common/Constants';

export interface WidgetSummary {
  todayTotal: number;
  todayDone: number;
  todayQuote: string;
}

export class WidgetBridgeService {
  static async getPreferences(context: common.Context): Promise<preferences.Preferences> {
    return preferences.getPreferences(context, WIDGET_PREFERENCES);
  }

  static async writeSummary(context: common.Context, total: number, done: number): Promise<void> {
    const store = await this.getPreferences(context);
    const quote = MOTIVATION_QUOTES[(total + done) % MOTIVATION_QUOTES.length];
    await store.put('today_total', total);
    await store.put('today_done', done);
    await store.put('today_quote', quote);
    await store.flush();
  }

  static async readSummary(context: common.Context): Promise<WidgetSummary> {
    const store = await this.getPreferences(context);
    const todayTotal = Number(await store.get('today_total', 0));
    const todayDone = Number(await store.get('today_done', 0));
    const todayQuote = String(await store.get('today_quote', MOTIVATION_QUOTES[0]));
    return { todayTotal, todayDone, todayQuote };
  }
}
