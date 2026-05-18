import type { PackageRecord } from '../model/PackageModel';
import { DatabaseService } from '../service/DatabaseService';
import { PackageCard } from '../components/PackageCard';
import { EmptyState } from '../components/EmptyState';
import { ROUTES } from '../utils/Constants';

@NavDestination
@Component
export struct HistoryList {
  @Consume('navStack') navStack: NavPathStack;
  @State packages: PackageRecord[] = [];

  aboutToAppear(): void {
    void this.loadArchived();
  }

  private async loadArchived(): Promise<void> {
    this.packages = await DatabaseService.getInstance().getArchivedPackages();
  }

  build() {
    Column({ space: 16 }) {
      Text('历史归档')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      if (this.packages.length === 0) {
        EmptyState({
          title: '暂无归档包裹',
          description: '已签收的快递会自动归档到这里。'
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
