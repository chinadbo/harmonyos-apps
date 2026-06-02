import { Constants } from '../common/Constants';
import { DateUtils } from '../common/DateUtils';

// P0修复：Widget 运行在独立进程，移除 aboutToAppear 中的 Preferences 读取逻辑
// 数据完全依赖 @LocalStorageProp 从 FridgeFormExtensionAbility 的 formBindingData 注入
@Entry
@Component
export struct FridgeWidgetCard {
  @LocalStorageProp('expiringSoonCount') expiringSoonCount: number = 0;
  @LocalStorageProp('expiredCount') expiredCount: number = 0;
  @LocalStorageProp('updatedAt') updatedAt: number = 0;

  build() {
    Column({ space: 8 }) {
      Text('HarmonyFridge')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#20331E')
      Text(`${this.expiringSoonCount} 项即将到期`)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#5E8E5A')
      Text(`已过期 ${this.expiredCount} 项`)
        .fontSize(13)
        .fontColor('#B34E60')
      Text(`更新于 ${DateUtils.formatTimestamp(this.updatedAt)}`)
        .fontSize(12)
        .fontColor('#6D816B')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(12)
    .backgroundColor('#F4F8F4')
  }
}
