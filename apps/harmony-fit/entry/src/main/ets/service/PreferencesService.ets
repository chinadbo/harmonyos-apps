import preferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'

export class PreferencesService {
  private static instance: PreferencesService = new PreferencesService()
  private pref: preferences.Preferences | null = null

  private constructor() {
  }

  static getInstance(): PreferencesService {
    return PreferencesService.instance
  }

  async init(context: common.Context): Promise<void> {
    if (this.pref !== null) {
      return
    }
    this.pref = await preferences.getPreferences(context, 'harmonyfit_preferences')
  }

  async getStepGoal(): Promise<number> {
    if (this.pref === null) {
      return 8000
    }
    const value = await this.pref.get('stepGoal', 8000)
    return Number(value)
  }

  async setStepGoal(goal: number): Promise<void> {
    if (this.pref === null) {
      return
    }
    await this.pref.put('stepGoal', goal)
    await this.pref.flush()
  }

  async getCalorieGoal(): Promise<number> {
    if (this.pref === null) {
      return 500
    }
    const value = await this.pref.get('calorieGoal', 500)
    return Number(value)
  }

  async setCalorieGoal(goal: number): Promise<void> {
    if (this.pref === null) {
      return
    }
    await this.pref.put('calorieGoal', goal)
    await this.pref.flush()
  }
}
