import { PackageStatus } from '../model/PackageModel';
import { STATUS_COLORS, STATUS_LABELS } from '../utils/Constants';

@Component
export struct StatusBadge {
  @Prop status: PackageStatus = PackageStatus.PENDING;

  build() {
    Text(STATUS_LABELS[this.status] ?? '未知状态')
      .fontColor(Color.White)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .backgroundColor(STATUS_COLORS[this.status] ?? '#98A2B3')
      .borderRadius(999)
  }
}
