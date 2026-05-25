import { speedDb } from '../database/SpeedDatabase'

@Component
export struct SettingsView {
  @State showClearConfirm: boolean = false
  @State clearDone: boolean = false

  build() {
    Scroll() {
      Column({ space: 12 }) {
        // Header
        Text('设置')
          .fontSize(20)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({ top: 16, left: 16, right: 16, bottom: 12 })

        // App info card
        Column({ space: 8 }) {
          Row() {
            Text('应用版本')
              .fontSize(15)
              .fontColor('#FFFFFF')
              .layoutWeight(1)
            Text('1.0.0')
              .fontSize(15)
              .fontColor('#9E9E9E')
          }
          .width('100%')

          Divider().color('#333344')

          Row() {
            Text('测速服务器')
              .fontSize(15)
              .fontColor('#FFFFFF')
              .layoutWeight(1)
            Text('Cloudflare')
              .fontSize(15)
              .fontColor('#9E9E9E')
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#1E1E2E')
        .borderRadius(8)
        .margin({ left: 16, right: 16 })

        // Clear history
        Column({ space: 8 }) {
          Text('数据管理')
            .fontSize(13)
            .fontColor('#9E9E9E')
            .width('100%')
            .padding({ left: 16, right: 16, top: 8 })

          Row() {
            Text('清除历史记录')
              .fontSize(15)
              .fontColor('#F44336')
              .layoutWeight(1)
            if (this.clearDone) {
              Text('已清除')
                .fontSize(13)
                .fontColor('#4CAF50')
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#1E1E2E')
          .borderRadius(8)
          .margin({ left: 16, right: 16 })
          .onClick(async () => {
            await speedDb.deleteAll()
            this.clearDone = true
            setTimeout(() => {
              this.clearDone = false
            }, 2000)
          })
        }

        // Usage tips
        Column({ space: 8 }) {
          Text('使用说明')
            .fontSize(13)
            .fontColor('#9E9E9E')
            .width('100%')
            .padding({ left: 16, right: 16, top: 8 })

          Text('· 测速需要稳定的网络连接\n· 下载测速使用 5MB 文件\n· 上传测速使用 2MB 随机数据\n· 延迟测试发送 5 次请求取平均值\n· 历史记录最多保存 100 条')
            .fontSize(14)
            .fontColor('#9E9E9E')
            .lineHeight(24)
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 16 })
            .backgroundColor('#1E1E2E')
            .borderRadius(8)
            .margin({ left: 16, right: 16 })
        }
      }
      .width('100%')
      .padding({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#12121E')
  }
}
