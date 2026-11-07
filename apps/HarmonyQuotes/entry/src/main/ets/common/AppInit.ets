/**
 * 应用初始化编排：行情引擎 → Preferences → RDB → 首次启动演示数据
 * 页面通过 AppInit.ready() 等待就绪，避免 DB 未初始化时读到空数据
 */

import common from '@ohos.app.ability.common'
import { MarketEngine } from '../market/MarketEngine'
import { QuoteDB } from '../db/QuoteDB'
import { Prefs } from './Prefs'
import { seedDemoData } from '../db/DemoData'

export class AppInit {
  private static readyPromise: Promise<void> = new Promise<void>((resolve) => {
    resolve()
  })

  static init(context: common.Context): void {
    MarketEngine.getInstance().init()
    AppInit.readyPromise = AppInit.doInit(context)
  }

  static ready(): Promise<void> {
    return AppInit.readyPromise
  }

  private static async doInit(context: common.Context): Promise<void> {
    try {
      await Prefs.load(context)
      await QuoteDB.getInstance().init(context)
      if (!Prefs.getBool('seeded', false)) {
        await seedDemoData()
        Prefs.setBool('seeded', true)
      }
    } catch (e) {
    }
  }
}
