import common from '@ohos.app.ability.common'
import formBindingData from '@ohos.app.form.formBindingData'
import formProvider from '@ohos.app.form.formProvider'
import TripDao from '../database/TripDao'
import { getTripTypeLabel } from '../model/Constants'

export interface WidgetSnapshot {
  title: string
  destination: string
  dateText: string
  progressText: string
  progressValue: string
  tripTypeText: string
  tripId: string
  emptyText: string
}

export default class WidgetService {
  static async buildSnapshot(context: common.Context): Promise<WidgetSnapshot> {
    const trips = await TripDao.listRecentSummaries(context, 1)
    if (trips.length === 0) {
      return {
        title: '最近行程',
        destination: '暂无行程',
        dateText: '点击创建新的旅行计划',
        progressText: '打包进度 0%',
        progressValue: '0',
        tripTypeText: '尚未设置',
        tripId: '0',
        emptyText: '立即开始添加行程'
      }
    }
    const summary = trips[0]
    return {
      title: summary.trip.title,
      destination: summary.trip.destination,
      dateText: WidgetService.formatDate(summary.trip.startDate, summary.trip.endDate),
      progressText: `打包进度 ${summary.progress}%`,
      progressValue: `${summary.progress}`,
      tripTypeText: getTripTypeLabel(summary.trip.tripType),
      tripId: `${summary.trip.id}`,
      emptyText: `${summary.packedItems}/${summary.totalItems} 已完成`
    }
  }

  static async createBindingData(context: common.Context): Promise<formBindingData.FormBindingData> {
    const snapshot = await WidgetService.buildSnapshot(context)
    return formBindingData.createFormBindingData(snapshot as Record<string, string>)
  }

  static async refreshForms(context: common.Context, formIds: number[]): Promise<void> {
    if (formIds.length === 0) {
      return
    }
    const bindingData = await WidgetService.createBindingData(context)
    for (const formId of formIds) {
      await formProvider.updateForm(formId, bindingData)
    }
  }

  private static formatDate(startDate: number, endDate: number): string {
    const start = new Date(startDate)
    const end = new Date(endDate)
    const startText = `${start.getMonth() + 1}/${start.getDate()}`
    const endText = `${end.getMonth() + 1}/${end.getDate()}`
    return `${startText} - ${endText}`
  }
}
