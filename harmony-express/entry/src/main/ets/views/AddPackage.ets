import type resourceManager from '@ohos.resourceManager';
import promptAction from '@ohos.promptAction';
import { ROUTES } from '../utils/Constants';
import { CourierDetector } from '../service/CourierDetector';
import { TrackingService } from '../service/TrackingService';
import { DatabaseService } from '../service/DatabaseService';

@NavDestination
@Component
export struct AddPackage {
  @Consume('navStack') navStack: NavPathStack;
  @State trackingNo: string = '';
  @State remark: string = '';
  @State detectedName: string = '未识别';
  @State saving: boolean = false;

  private handleTrackingNoChange(value: string): void {
    this.trackingNo = value;
    this.detectedName = CourierDetector.detect(value).courierName;
  }

  private async handleSave(): Promise<void> {
    if (!this.trackingNo.trim()) {
      promptAction.showToast({ message: '请输入快递单号' });
      return;
    }
    this.saving = true;
    const resourceManagerInstance = this.getUIContext().getHostContext()?.resourceManager as resourceManager.ResourceManager;
    const queryResult = await TrackingService.queryTracking(resourceManagerInstance, this.trackingNo, this.remark);
    const packageId = await DatabaseService.getInstance().saveOrUpdatePackage(queryResult.packageRecord, queryResult.events);
    this.saving = false;
    promptAction.showToast({ message: '快递已添加' });
    AppStorage.SetOrCreate('selectedPackageId', packageId);
    this.navStack.replacePath({
      name: ROUTES.TRACKING_DETAIL
    });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('新增快递')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)

        TextInput({ placeholder: '请输入快递单号', text: this.trackingNo })
          .onChange((value: string) => this.handleTrackingNoChange(value))

        Text(`识别快递公司：${this.detectedName}`)
          .fontSize(14)
          .fontColor('#475467')
          .width('100%')
          .textAlign(TextAlign.Start)

        TextArea({ placeholder: '备注（可选）', text: this.remark })
          .height(120)
          .onChange((value: string) => {
            this.remark = value;
          })

        Button(this.saving ? '保存中...' : '保存并查询')
          .enabled(!this.saving)
          .onClick(() => {
            void this.handleSave();
          })
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
