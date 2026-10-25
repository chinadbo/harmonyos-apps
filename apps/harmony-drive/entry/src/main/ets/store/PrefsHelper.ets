/**
 * Preferences 封装：练习进度 / 科目切换 / Widget 数据
 */
import dataPreferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'

const PREF_NAME = 'drive_prefs'

export class PrefsHelper {
  private static prefs: dataPreferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    if (PrefsHelper.prefs) {
      return
    }
    PrefsHelper.prefs = await dataPreferences.getPreferences(context, PREF_NAME)
  }

  private static async ensure(): Promise<dataPreferences.Preferences> {
    if (PrefsHelper.prefs) {
      return PrefsHelper.prefs
    }
    throw new Error('PrefsHelper 未初始化')
  }

  /** 顺序练习进度（各科已刷到题库索引） */
  static async getPracticeIndex(subject: number): Promise<number> {
    const p = await PrefsHelper.ensure()
    return await p.get(`practice_index_${subject}`, 0) as number
  }

  static async setPracticeIndex(subject: number, index: number): Promise<void> {
    const p = await PrefsHelper.ensure()
    await p.put(`practice_index_${subject}`, index)
    await p.flush()
  }

  /** 当前科目：1 / 4 */
  static async getSubject(): Promise<number> {
    const p = await PrefsHelper.ensure()
    return await p.get('current_subject', 1) as number
  }

  static async setSubject(subject: number): Promise<void> {
    const p = await PrefsHelper.ensure()
    await p.put('current_subject', subject)
    await p.flush()
  }

  /** 累计刷题天数（简单打卡计数） */
  static async getStudyDays(): Promise<number> {
    const p = await PrefsHelper.ensure()
    return await p.get('study_days', 0) as number
  }

  static async incStudyDays(): Promise<void> {
    const p = await PrefsHelper.ensure()
    const last = await p.get('last_study_date', '') as string
    const today = PrefsHelper.today()
    if (last === today) {
      return
    }
    await p.put('last_study_date', today)
    await p.put('study_days', (await p.get('study_days', 0) as number) + 1)
    await p.flush()
  }

  static today(): string {
    const d = new Date()
    const m = (d.getMonth() + 1).toString().padStart(2, '0')
    const day = d.getDate().toString().padStart(2, '0')
    return `${d.getFullYear()}-${m}-${day}`
  }
}
