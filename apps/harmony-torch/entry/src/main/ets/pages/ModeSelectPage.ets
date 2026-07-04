import router from '@ohos.router';
import { TorchMode, MODE_LABELS, MODE_ICONS } from '../models/TorchMode';
import TorchService from '../services/TorchService';
import { ModeCard } from '../components/ModeCard';

@Entry
@Component
struct ModeSelectPage {
  @State selectedMode: TorchMode = TorchMode.STEADY;
  @State currentMode: TorchMode = TorchMode.STEADY;
  private service: TorchService = TorchService.getInstance();

  aboutToAppear() {
    this.currentMode = this.service.getCurrentMode();
    this.selectedMode = this.currentMode;
  }

  aboutToDisappear() {
    // 清理
  }

  onModeSelect(mode: TorchMode) {
    this.selectedMode = mode;
  }

  confirmSelection() {
    if (this.selectedMode !== this.currentMode) {
      this.service.turnOn(this.selectedMode);
    }
    router.back();
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button() {
          Text('←')
            .fontSize(24)
            .fontColor('#FFFFFF')
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text('选择模式')
          .fontSize(20)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // Grid 布局
      Grid() {
        GridItem() {
          ModeCard({
            mode: TorchMode.STEADY,
            isSelected: this.selectedMode === TorchMode.STEADY,
            onSelect: (mode: TorchMode) => {
              this.onModeSelect(mode);
            }
          })
        }

        GridItem() {
          ModeCard({
            mode: TorchMode.SOS,
            isSelected: this.selectedMode === TorchMode.SOS,
            onSelect: (mode: TorchMode) => {
              this.onModeSelect(mode);
            }
          })
        }

        GridItem() {
          ModeCard({
            mode: TorchMode.STROBE,
            isSelected: this.selectedMode === TorchMode.STROBE,
            onSelect: (mode: TorchMode) => {
              this.onModeSelect(mode);
            }
          })
        }

        GridItem() {
          ModeCard({
            mode: TorchMode.SCREEN,
            isSelected: this.selectedMode === TorchMode.SCREEN,
            onSelect: (mode: TorchMode) => {
              this.onModeSelect(mode);
            }
          })
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .padding(16)
      .layoutWeight(1)

      // 确认按钮
      Button('确认')
        .width('90%')
        .height(50)
        .backgroundColor('#FFD700')
        .fontColor('#121212')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .borderRadius(25)
        .margin({ bottom: 30 })
        .onClick(() => {
          this.confirmSelection();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#121212')
  }
}
