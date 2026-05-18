import type resourceManager from '@ohos.resourceManager';
import promptAction from '@ohos.promptAction';
import { PackageStatus, type PackageRecord } from '../model/PackageModel';
import type { TrackingEvent } from '../model/TrackingEventModel';
import { DatabaseService } from '../service/DatabaseService';
import { TrackingService } from '../service/TrackingService';
import { NotificationService } from '../service/NotificationService';
import { StatusBadge } from '../components/StatusBadge';
import { TimelineView } from '../components/TimelineView';

const EMPTY_PACKAGE: PackageRecord = {
  trackingNo: '',
  courierCode: '',
  courierName: '',
  remark: '',
  status: PackageStatus.PENDING,
  lastUpdate: '',
  latestDesc: '',
  isArchived: false,
  createdAt: ''
};

@NavDestination
@Component
export struct TrackingDetail {
  @Consume('navStack') navStack: NavPathStack;
  @StorageLink('selectedPackageId') selectedPackageId: number = 0;
  @State record: PackageRecord = EMPTY_PACKAGE;
  @State events: TrackingEvent[] = [];
  @State loading: boolean = false;
  @StorageLink('notificationsEnabled') notificationsEnabled: boolean = true;

  aboutToAppear(): void {
    void this.loadDetail();
  }

  private async loadDetail(): Promise<void> {
    const packageId: number = Number(this.selectedPackageId ?? 0);
    if (!packageId) {
      return;
    }
    this.loading = true;
    const db = DatabaseService.getInstance();
    const currentRecord = await db.getPackageById(packageId);
    const currentEvents = await db.getEventsByPackageId(packageId);
    if (currentRecord) {
      this.record = currentRecord;
      this.events = currentEvents;
    }
    this.loading = false;
  }

  private async refreshTracking(): Promise<void> {
    if (!this.record.id) {
      return;
    }
    this.loading = true;
    const previousStatus: PackageStatus = this.record.status;
    const resourceManagerInstance = this.getUIContext().getHostContext()?.resourceManager as resourceManager.ResourceManager;
    const queryResult = await TrackingService.queryTracking(resourceManagerInstance, this.record.trackingNo, this.record.remark);
    queryResult.packageRecord.id = this.record.id;
    queryResult.packageRecord.createdAt = this.record.createdAt;
    queryResult.packageRecord.isArchived = queryResult.packageRecord.status === PackageStatus.DELIVERED;
    await DatabaseService.getInstance().refreshPackage(this.record.id, queryResult.packageRecord, queryResult.events);
    if (queryResult.packageRecord.isArchived) {
      await DatabaseService.getInstance().archivePackage(this.record.id);
    }
    this.record = {
      ...queryResult.packageRecord,
      id: this.record.id
    };
    this.events = queryResult.events;
    this.loading = false;
    if (previousStatus !== this.record.status && this.notificationsEnabled) {
      await NotificationService.publishStatusNotification(this.record, true);
    }
    promptAction.showToast({ message: '物流状态已刷新' });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Column({ space: 6 }) {
            Text(this.record.courierName || '快递详情')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#101828')
              .width('100%')
              .textAlign(TextAlign.Start)
            Text(this.record.trackingNo)
              .fontSize(13)
              .fontColor('#475467')
              .width('100%')
              .textAlign(TextAlign.Start)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          StatusBadge({ status: this.record.status })
        }
        .width('100%')

        Column({ space: 8 }) {
          Text(this.record.latestDesc || '暂无状态')
            .fontSize(16)
            .fontColor('#101828')
            .width('100%')
            .textAlign(TextAlign.Start)
          Text(`备注：${this.record.remark || '无'} · 更新时间：${this.record.lastUpdate || '--'}`)
            .fontSize(13)
            .fontColor('#667085')
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(20)

        Button(this.loading ? '刷新中...' : '刷新物流')
          .enabled(!this.loading)
          .onClick(() => {
            void this.refreshTracking();
          })

        if (this.events.length > 0) {
          TimelineView({ events: this.events })
        } else {
          Text('暂无轨迹数据')
            .fontSize(14)
            .fontColor('#667085')
        }
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}
