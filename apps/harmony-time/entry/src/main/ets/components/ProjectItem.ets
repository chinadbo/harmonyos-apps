import { Project } from '../model/Project'

@Component
export struct ProjectItem {
  @Prop project: Project = {
    id: 0,
    name: '',
    color: '#4FC3F7',
    icon: '📁',
    totalTime: 0,
    createdAt: 0
  }
  onTap: (project: Project) => void = () => {}

  private formatTotalTime(seconds: number): string {
    if (seconds < 60) {
      return `${seconds}秒`
    }
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    if (h > 0) {
      return `${h}小时${m}分`
    }
    return `${m}分钟`
  }

  build() {
    Row() {
      // Color dot
      Circle()
        .width(12)
        .height(12)
        .fill(this.project.color)
        .margin({ right: 12 })

      // Icon
      Text(this.project.icon)
        .fontSize(24)
        .margin({ right: 8 })

      // Name
      Text(this.project.name)
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)

      // Total time
      Text(this.formatTotalTime(this.project.totalTime))
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .onClick(() => {
      this.onTap(this.project)
    })
  }
}
