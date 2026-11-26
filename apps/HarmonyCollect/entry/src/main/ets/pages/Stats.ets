/**
 * Stats.ets — 独立统计页（复用 StatsView，附带返回导航）
 */
import router from '@ohos.router';
import { StatsView } from '../views/StatsView';
import { PageHeader } from '../components/PageHeader';
import { C_BG } from '../common/Constants';

@Entry
@Component
struct Stats {
  build() {
    Column() {
      PageHeader({
        title: '统计分析',
        subtitle: '收藏资产一览',
        showBack: true,
        onBack: () => router.back()
      })
      Column() {
        StatsView({ showTopBar: false })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(C_BG)
  }
}
