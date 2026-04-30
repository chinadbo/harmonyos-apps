import notificationManager from '@ohos.notificationManager'
import wantAgent from '@ohos.wantAgent'
import common from '@ohos.app.ability.common'
import { AppDefaults } from '../common/Constants'

export class NotifyService {
  private static instance: NotifyService = new NotifyService()
  private context?: common.UIAbilityContext

  static getInstance(): NotifyService {
    return NotifyService.instance
  }

  setContext(context: common.UIAbilityContext): void {
    this.context = context
  }

  async publishTimerFinished(title: string, text: string): Promise<void> {
    const enabled: boolean = Boolean(AppStorage.Get(AppDefaults.STORAGE_NOTIFICATION_ENABLED) ?? true)
    if (!enabled || !this.context) {
      return
    }
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: this.context.abilityInfo.bundleName,
          moduleName: this.context.abilityInfo.moduleName,
          abilityName: 'EntryAbility'
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    }
    const agent = await wantAgent.getWantAgent(wantAgentInfo)
    const request: notificationManager.NotificationRequest = {
      id: AppDefaults.NOTIFICATION_ID,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title,
          text,
          additionalText: 'HarmonyFocus'
        }
      },
      actionButtons: [
        {
          title: '打开应用',
          wantAgent: agent
        }
      ],
      tapDismissed: true,
      slotType: notificationManager.SlotType.SERVICE_INFORMATION
    }
    await notificationManager.publish(request)
  }
}

export const notifyService: NotifyService = NotifyService.getInstance()
