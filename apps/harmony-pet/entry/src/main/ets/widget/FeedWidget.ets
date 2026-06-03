import { AppStorageKeys } from '../common/AppStorageKeys'

@Component
export struct FeedWidget {
  @StorageLink('activePetName') activePetName: string = '我的宠物'
  @StorageLink('todayFeedCount') todayFeedCount: number = 0
  @StorageLink('nextFeedTime') nextFeedTime: string = '--:--'

  build() {
    Column({ space: 10 }) {
      Text(this.activePetName)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#222222')
        .width('100%')
      Text(`今日喂食 ${this.todayFeedCount} 次`)
        .fontSize(16)
        .fontColor('#444444')
        .width('100%')
      Text(`下次喂食 ${this.nextFeedTime}`)
        .fontSize(13)
        .fontColor('#888888')
        .width('100%')
      Blank()
      Button('打开应用')
        .type(ButtonType.Capsule)
        .width('100%')
        .onClick(() => {
          postCardAction(this.getUIContext(), JSON.stringify({
            action: 'router',
            abilityName: 'EntryAbility',
            params: { from: 'feedWidget', key: AppStorageKeys.ACTIVE_PET_ID }
          }))
        })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFBEF')
    .borderRadius(24)
  }
}
