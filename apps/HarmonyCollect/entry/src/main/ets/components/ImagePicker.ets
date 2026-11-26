/**
 * ImagePicker.ets — 图片选择（PhotoViewPicker + 沙箱拷贝）
 */
import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { ImageStore } from '../common/ImageStore';
import { C_LINE, C_SUB, C_BRAND, C_CARD } from '../common/Constants';

@Component
export struct ImagePicker {
  @Prop path: string = '';
  onChange: (path: string) => void = (path: string) => {};

  private async pick(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const uris: string[] = await ImageStore.pickAndCopy(context, 1);
      if (uris.length > 0) {
        this.onChange(uris[0]);
      }
    } catch (err) {
      promptAction.showToast({ message: '选择图片失败' });
    }
  }

  build() {
    Column() {
      if (this.path.length > 0) {
        Stack({ alignContent: Alignment.TopEnd }) {
          Image(ImageStore.toDisplaySrc(this.path))
            .width('100%')
            .height(180)
            .borderRadius(14)
            .objectFit(ImageFit.Cover)
            .backgroundColor(C_LINE)
          Text('×')
            .fontSize(16)
            .fontColor(0xFFFFFF)
            .width(28)
            .height(28)
            .textAlign(TextAlign.Center)
            .borderRadius(14)
            .backgroundColor('#99000000')
            .margin(8)
            .onClick(() => this.onChange(''))
        }
        .width('100%')

        Row() {
          Button('更换图片')
            .fontSize(13)
            .fontColor(C_BRAND)
            .backgroundColor(C_CARD)
            .height(34)
            .borderRadius(17)
            .border({ width: 1, color: C_BRAND })
            .padding({ left: 18, right: 18 })
            .onClick(() => { this.pick(); })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 10 })
      } else {
        Column() {
          Text('＋')
            .fontSize(34)
            .fontColor(C_BRAND)
          Text('选择藏品图片')
            .fontSize(13)
            .fontColor(C_SUB)
            .margin({ top: 6 })
        }
        .width('100%')
        .height(140)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(C_CARD)
        .borderRadius(14)
        .border({ width: 1.5, color: C_LINE, style: BorderStyle.Dashed })
        .onClick(() => { this.pick(); })
      }
    }
    .width('100%')
  }
}
