import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { DocumentDB } from '../database/DocumentDB';
import { DocumentModel, PageModel } from '../model/DocumentModel';
import { PdfGenerator } from '../utils/PdfGenerator';

@Component
struct DocumentDetail {
  @State docId: number = 0;
  @State document: DocumentModel = {
    id: 0,
    name: '',
    createdAt: '',
    pageCount: 0,
    thumbnailPath: '',
    pdfPath: '',
    pages: []
  };
  @State exporting: boolean = false;

  async aboutToAppear(): Promise<void> {
    const params = router.getParams() as Record<string, number>;
    this.docId = Number(params?.docId ?? 0);
    await this.loadDocument();
  }

  private async loadDocument(): Promise<void> {
    const next = await DocumentDB.getDocument(this.docId);
    if (next !== null) {
      this.document = next;
    }
  }

  private async exportPdf(): Promise<void> {
    if (this.exporting || this.document.pages.length === 0) {
      return;
    }
    this.exporting = true;
    try {
      const context = getContext(this) as Record<string, string>;
      const outputPath = `${context.filesDir}/pdfs/document_${this.document.id}.pdf`;
      await PdfGenerator.generate(this.document.pages, outputPath);
      await DocumentDB.updatePdfPath(this.document.id, outputPath);
      await this.loadDocument();
      promptAction.showToast({ message: 'PDF 导出完成' });
    } catch (error) {
      promptAction.showToast({ message: '导出 PDF 失败' });
    }
    this.exporting = false;
  }

  private sharePdf(): void {
    if (this.document.pdfPath.length === 0) {
      promptAction.showToast({ message: '请先导出 PDF' });
      return;
    }
    promptAction.showToast({ message: `请接入系统分享面板：${this.document.pdfPath}` });
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 6 }) {
          Text(this.document.name)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .width('100%')
          Text(`${this.document.pageCount} 页`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button('继续扫描')
          .height(40)
          .fontSize(14)
          .backgroundColor('#E0E7FF')
          .fontColor('#4338CA')
          .borderRadius(16)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ScanPage',
              params: {
                docId: this.document.id,
                fromDetail: true
              }
            });
          })
      }
      .width('100%')

      Scroll() {
        Grid() {
          ForEach(this.document.pages, (page: PageModel) => {
            GridItem() {
              Column({ space: 8 }) {
                Image(page.imagePath)
                  .width('100%')
                  .height(180)
                  .borderRadius(18)
                  .objectFit(ImageFit.Cover)
                  .backgroundColor('#F1F5F9')
                Text(`第 ${page.index + 1} 页`)
                  .fontSize(14)
                  .fontColor('#334155')
              }
              .padding(8)
              .backgroundColor('#FFFFFF')
              .borderRadius(20)
            }
          }, (page: PageModel) => `${page.id}`)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .width('100%')
      }
      .layoutWeight(1)

      Row({ space: 12 }) {
        Button(this.exporting ? '导出中...' : '导出 PDF')
          .layoutWeight(1)
          .height(50)
          .fontColor('#FFFFFF')
          .backgroundColor('#4F46E5')
          .borderRadius(18)
          .onClick(async () => {
            await this.exportPdf();
          })

        Button('分享')
          .layoutWeight(1)
          .height(50)
          .fontColor('#1E293B')
          .backgroundColor('#E2E8F0')
          .borderRadius(18)
          .onClick(() => {
            this.sharePdf();
          })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F8FAFC')
  }
}

export default DocumentDetail;
