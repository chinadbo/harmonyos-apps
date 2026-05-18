import { ROUTES } from '../utils/Constants';
import { DatabaseService } from '../service/DatabaseService';
import type { PackageRecord } from '../model/PackageModel';
import { PackageCard } from '../components/PackageCard';
import { EmptyState } from '../components/EmptyState';

@NavDestination
@Component
export struct HomeIndex {
  @Consume('navStack') navStack: NavPathStack;
  @State packages: PackageRecord[] = [];
  @State loading: boolean = false;

  aboutToAppear(): void {
    void this.loadPackages();
  }

  private async loadPackages(): Promise<void> {
    this.loading = true;
    this.packages = await DatabaseService.getInstance().getActivePackages();
    this.loading = false;
  }

  build() {
    Column({ space: 16 }) {
      Row({ space: 8 }) {
        Button('新增快递')
          .layoutWeight(1)
          .onClick(() => this.navStack.pushPath({ name: ROUTES.ADD_PACKAGE }))
        Button('历史归档')
          .layoutWeight(1)
          .onClick(() => this.navStack.pushPath({ name: ROUTES.HISTORY_LIST }))
      }

      Row({ space: 8 }) {
        Button('设置')
          .layoutWeight(1)
          .onClick(() => this.navStack.pushPath({ name: ROUTES.SETTINGS }))
        Button('刷新列表')
          .layoutWeight(1)
          .onClick(() => {
            void this.loadPackages();
          })
      }

      Text('在途列表')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      Text('管理进行中的包裹，点击卡片可查看详情时间线。')
        .fontSize(14)
        .fontColor('#667085')
        .width('100%')
        .textAlign(TextAlign.Start)

      Row({ space: 8 }) {
        Button('模拟打开新增页')
          .layoutWeight(1)
          .onClick(() => this.navStack.pushPath({ name: ROUTES.ADD_PACKAGE }))
        Button('模拟打开设置页')
          .layoutWeight(1)
          .onClick(() => this.navStack.pushPath({ name: ROUTES.SETTINGS }))
      }
      .visibility(Visibility.None)

      if (this.loading) {
        LoadingProgress()
          .width(36)
          .height(36)
      } else if (this.packages.length === 0) {
        EmptyState({
          title: '还没有在途快递',
          description: '点击“新增快递”录入单号，应用会从本地 Mock 数据或随机轨迹生成最新状态。'
        })
      } else {
        List({ space: 12 }) {
          ForEach(this.packages, (item: PackageRecord) => {
            ListItem() {
              PackageCard({
                record: item
              })
              .onClick(() => {
                AppStorage.SetOrCreate('selectedPackageId', item.id ?? 0);
                this.navStack.pushPath({ name: ROUTES.TRACKING_DETAIL });
              })
            }
          }, (item: PackageRecord) => item.trackingNo)
        }
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}
