import picker from '@ohos.file.picker';
import { EditorRouteParam } from '../model/AnnotationTool';
import { AnnotateEditor } from './AnnotateEditor';
import { HistoryPage } from './HistoryPage';

@Component
struct EntryCard {
  @Prop title: string = '';
  @Prop desc: string = '';
  @Prop onTap: () => void = () => {};

  build() {
    Column({ space: 10 }) {
      Text(this.title)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0F172A')
      Text(this.desc)
        .fontSize(14)
        .fontColor('#475569')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .onClick(() => this.onTap())
  }
}

@Builder
function navDestinationBuilder(name: string, param: Object) {
  if (name === 'AnnotateEditor') {
    AnnotateEditor({ routeParam: param as EditorRouteParam })
  } else if (name === 'HistoryPage') {
    HistoryPage()
  }
}

@Entry
@Component
export struct Index {
  @State navStack: NavPathStack = AppStorage.get('navStack') as NavPathStack;

  private async pickImage(): Promise<void> {
    const photoPicker = new picker.PhotoViewPicker();
    const result = await photoPicker.select({
      MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: 1
    });
    if (!result.photoUris || result.photoUris.length === 0) {
      return;
    }
    const imageUri = result.photoUris[0];
    const routeParam: EditorRouteParam = {
      imageUri,
      imagePath: imageUri
    };
    this.navStack.pushPathByName('AnnotateEditor', routeParam);
  }

  build() {
    Navigation(this.navStack) {
      Column({ space: 20 }) {
        Column({ space: 8 }) {
          Text($r('app.string.index_title'))
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#0F172A')
          Text($r('app.string.index_subtitle'))
            .fontSize(15)
            .fontColor('#64748B')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        EntryCard({
          title: $r('app.string.pick_image'),
          desc: '使用系统 PhotoViewPicker 选择一张待标注图片',
          onTap: async () => {
            await this.pickImage();
          }
        })

        EntryCard({
          title: $r('app.string.view_history'),
          desc: '查看导出图片和最近保存记录',
          onTap: () => {
            this.navStack.pushPathByName('HistoryPage');
          }
        })

        Blank()
      }
      .width('100%')
      .height('100%')
      .padding(20)
      .backgroundColor('#F1F5F9')
    }
    .hideTitleBar(true)
    .navDestination(navDestinationBuilder)
  }
}
