import { AppConstants, LapRecord, SessionDetail, SessionRecord, TimerStatus } from '../common/constants'
import { createSessionName } from '../common/utils'
import { dataStore } from './DataStore'

export class SessionModel {
  private static instance: SessionModel = new SessionModel()

  static getInstance(): SessionModel {
    return SessionModel.instance
  }

  private constructor() {
    AppStorage.SetOrCreate(AppConstants.STORAGE_SESSION_ID, 0)
    AppStorage.SetOrCreate(AppConstants.STORAGE_SESSION_NAME, '')
    AppStorage.SetOrCreate(AppConstants.STORAGE_LAPS, [])
    AppStorage.SetOrCreate(AppConstants.STORAGE_ELAPSED_MS, 0)
    AppStorage.SetOrCreate(AppConstants.STORAGE_TIMER_STATUS, TimerStatus.IDLE)
    AppStorage.SetOrCreate(AppConstants.STORAGE_HISTORY_REFRESH_TOKEN, Date.now())
  }

  async ensureSession(): Promise<number> {
    const currentId = Number(AppStorage.Get(AppConstants.STORAGE_SESSION_ID) ?? 0)
    if (currentId > 0) {
      return currentId
    }
    const now = Date.now()
    const name = createSessionName(now)
    const sessionId = await dataStore.createSession(name, now, now)
    AppStorage.SetOrCreate(AppConstants.STORAGE_SESSION_ID, sessionId)
    AppStorage.SetOrCreate(AppConstants.STORAGE_SESSION_NAME, name)
    return sessionId
  }

  async recordLap(totalTime: number): Promise<void> {
    const sessionId = await this.ensureSession()
    const existing = this.getCurrentLaps()
    const previousTotal = existing.length > 0 ? existing[existing.length - 1].totalTime : 0
    const lapNumber = existing.length + 1
    const lapTime = Math.max(0, totalTime - previousTotal)
    const createdAt = Date.now()
    const lapId = await dataStore.addLap(sessionId, lapNumber, lapTime, totalTime, createdAt)
    const nextLap: LapRecord = {
      id: lapId,
      sessionId,
      lapNumber,
      lapTime,
      totalTime,
      createdAt
    }
    const nextLaps = [...existing, nextLap]
    AppStorage.SetOrCreate(AppConstants.STORAGE_LAPS, nextLaps)
  }

  async finalizeSession(duration: number): Promise<void> {
    const sessionId = Number(AppStorage.Get(AppConstants.STORAGE_SESSION_ID) ?? 0)
    if (sessionId > 0) {
      await dataStore.updateSession(sessionId, Date.now(), duration)
      AppStorage.SetOrCreate(AppConstants.STORAGE_HISTORY_REFRESH_TOKEN, Date.now())
    }
  }

  async syncActiveSession(duration: number): Promise<void> {
    const sessionId = Number(AppStorage.Get(AppConstants.STORAGE_SESSION_ID) ?? 0)
    if (sessionId > 0) {
      await dataStore.updateSession(sessionId, 0, duration)
    }
  }

  async resetSession(deleteIfEmpty: boolean = false): Promise<void> {
    const sessionId = Number(AppStorage.Get(AppConstants.STORAGE_SESSION_ID) ?? 0)
    const elapsed = Number(AppStorage.Get(AppConstants.STORAGE_ELAPSED_MS) ?? 0)
    const laps = this.getCurrentLaps()
    if (sessionId > 0 && deleteIfEmpty && elapsed <= 0 && laps.length === 0) {
      await dataStore.deleteSession(sessionId)
    }
    AppStorage.SetOrCreate(AppConstants.STORAGE_SESSION_ID, 0)
    AppStorage.SetOrCreate(AppConstants.STORAGE_SESSION_NAME, '')
    AppStorage.SetOrCreate(AppConstants.STORAGE_LAPS, [])
    AppStorage.SetOrCreate(AppConstants.STORAGE_HISTORY_REFRESH_TOKEN, Date.now())
  }

  async restoreSession(): Promise<{ session: SessionRecord | null; laps: LapRecord[] }> {
    const unfinishedSession = await dataStore.getUnfinishedSession()
    if (unfinishedSession === null) {
      AppStorage.SetOrCreate(AppConstants.STORAGE_SESSION_ID, 0)
      AppStorage.SetOrCreate(AppConstants.STORAGE_SESSION_NAME, '')
      AppStorage.SetOrCreate(AppConstants.STORAGE_LAPS, [])
      return {
        session: null,
        laps: []
      }
    }
    const laps = await dataStore.getLapsBySessionId(unfinishedSession.id)
    AppStorage.SetOrCreate(AppConstants.STORAGE_SESSION_ID, unfinishedSession.id)
    AppStorage.SetOrCreate(AppConstants.STORAGE_SESSION_NAME, unfinishedSession.name)
    AppStorage.SetOrCreate(AppConstants.STORAGE_LAPS, laps)
    return {
      session: unfinishedSession,
      laps
    }
  }

  async getSessions(): Promise<SessionRecord[]> {
    return await dataStore.getSessionsDesc()
  }

  async getSessionDetail(sessionId: number): Promise<SessionDetail | null> {
    return await dataStore.getSessionDetail(sessionId)
  }

  async deleteSession(sessionId: number): Promise<void> {
    await dataStore.deleteSession(sessionId)
    AppStorage.SetOrCreate(AppConstants.STORAGE_HISTORY_REFRESH_TOKEN, Date.now())
  }

  getCurrentLaps(): LapRecord[] {
    return AppStorage.Get(AppConstants.STORAGE_LAPS) as LapRecord[] || []
  }
}

export const sessionModel: SessionModel = SessionModel.getInstance()
