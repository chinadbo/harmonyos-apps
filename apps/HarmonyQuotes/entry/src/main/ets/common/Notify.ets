/**
 * 本地通知 + 震动反馈封装。所有系统调用均有 try/catch 兜底。
 */

import notificationManager from '@ohos.notificationManager'
import vibrator from '@ohos.vibrator'
import common from '@ohos.app.ability.common'
import { AppContext } from './AppContext'

export class Notify {
  private static notifiedKeys: Set<string> = new Set<string>()
  private static permissionGranted: boolean = false
  private static nextNotifyId: number = 1

  static async ensurePermission(): Promise<boolean> {
    if (Notify.permissionGranted) {
      return true
    }
    try {
      const ctx: common.Context | null = AppContext.get()
      if (ctx) {
        // 1600004 为用户拒绝授权，静默降级，不重试
        await notificationManager.requestEnableNotification(ctx as common.UIAbilityContext)
      }
      Notify.permissionGranted = ctx !== null
    } catch (e) {
      Notify.permissionGranted = false
    }
    return Notify.permissionGranted
  }

  static isAlerted(key: string): boolean {
    return Notify.notifiedKeys.has(key)
  }

  static async sendQuoteAlert(name: string, price: number, up: boolean, threshold: number): Promise<void> {
    Notify.vibrate()
    try {
      const id: number = Notify.nextNotifyId
      Notify.nextNotifyId++
      if (Notify.nextNotifyId > 2100000000) {
        Notify.nextNotifyId = 1
      }
      await notificationManager.publish({
        id: id,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: `${name} ${up ? '高位提醒' : '低位提醒'}`,
            text: `当前价 ${price.toFixed(2)}，已${up ? '上穿' : '跌破'}阈值 ${threshold.toFixed(2)}`,
            additionalText: 'HarmonyQuotes 行情助手'
          }
        }
      })
    } catch (e) {
    }
  }

  static vibrate(): void {
    try {
      vibrator.startVibration({
        type: 'preset',
        count: 1,
        duration: 40
      })
    } catch (e) {
    }
  }
}
