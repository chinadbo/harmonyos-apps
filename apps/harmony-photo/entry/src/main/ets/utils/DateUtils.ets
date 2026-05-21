import { PhotoItem } from '../model/PhotoItem'

export class DateUtils {
  static formatMonth(timestamp: number): string {
    let date = new Date(timestamp)
    return `${date.getFullYear()}年${date.getMonth() + 1}月`
  }

  static groupByMonth(photos: PhotoItem[]): Array<{ month: string; photos: PhotoItem[] }> {
    let grouped: Record<string, PhotoItem[]> = {}
    photos.forEach((photo: PhotoItem) => {
      let month = DateUtils.formatMonth(photo.dateAdded)
      if (!grouped[month]) {
        grouped[month] = []
      }
      grouped[month].push(photo)
    })

    let result: Array<{ month: string; photos: PhotoItem[] }> = []
    Object.keys(grouped).forEach((month: string) => {
      result.push({ month: month, photos: grouped[month] })
    })
    // 按时间降序
    result.sort((a, b) => {
      let aTime = a.photos.length > 0 ? a.photos[0].dateAdded : 0
      let bTime = b.photos.length > 0 ? b.photos[0].dateAdded : 0
      return bTime - aTime
    })
    return result
  }
}
