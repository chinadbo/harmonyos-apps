import router from '@ohos.router';
import { DocumentDB } from '../database/DocumentDB';
import { DocumentGroup, DocumentModel } from '../model/DocumentModel';
import { DocumentCard } from '../components/DocumentCard';
import { EmptyView } from '../components/EmptyView';

@Component
struct Index {
  @State documents: DocumentModel[] = [];
  @State groups: DocumentGroup[] = [];
  @State loading: boolean = true;

  async aboutToAppear(): Promise<void> {
    await this.loadDocuments();
  }

  private async loadDocuments(): Promise<void> {
    this.loading = true;
    this.documents = await DocumentDB.listDocuments();
    this.groups = this.buildGroups(this.documents);
    this.loading = false;
  }

  private buildGroups(documents: DocumentModel[]): DocumentGroup[] {
    const map: Record<string, DocumentModel[]> = {};
    documents.forEach((item: DocumentModel) => {
      const date = new Date(item.createdAt);
      const key = `${date.getFullYear()}-${`${date.getMonth() + 1}`.padStart(2, '0')}-${`${date.getDate()}`.padStart(2, '0')}`;
      if (!map[key]) {
        map[key] = [];
      }
      map[key].push(item);
    });
    return Object.keys(map).sort((left: string, right: string) => right.localeCompare(left)).map((key: string) => ({
      title: key,
      items: map[key]
    }));
  }

  private async createDocumentAndScan(): Promise<void> {
    const now = new Date();
    const name = `扫描_${now.getFullYear()}-${`${now.getMonth() + 1}`.padStart(2, '0')}-${`${now.getDate()}`.padStart(2, '0')}_${`${now.getHours()}`.padStart(2, '0')}:${`${now.getMinutes()}`.padStart(2, '0')}`;
    const docId = await DocumentDB.createDocument(name);
    router.pushUrl({
      url: 'pages/ScanPage',
      params: {
        docId: docId,
        fromDetail: false
      }
    });
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column({ space: 16 }) {
        Column({ space: 8 }) {
          Text('HarmonyScan')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
          Text('文档按日期分组展示，拍照后即可裁剪与导出 PDF')
            .fontSize(14)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')

        if (this.loading) {
          Column() {
            LoadingProgress()
              .width(36)
              .height(36)
            Text('正在加载文档...')
              .margin({ top: 12 })
              .fontColor('#666666')
          }
          .width('100%')
          .height('70%')
          .justifyContent(FlexAlign.Center)
        } else if (this.groups.length === 0) {
          EmptyView({})
        } else {
          List({ space: 16 }) {
            ForEach(this.groups, (group: DocumentGroup) => {
              ListItem() {
                Column({ space: 12 }) {
                  Text(group.title)
                    .fontSize(20)
                    .fontWeight(FontWeight.Medium)
                    .width('100%')
                  ForEach(group.items, (document: DocumentModel) => {
                    DocumentCard({
                      document: document,
                      onClick: () => {
                        router.pushUrl({
                          url: 'pages/DocumentDetail',
                          params: { docId: document.id }
                        });
                      }
                    })
                  }, (document: DocumentModel) => `${document.id}`)
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }
            }, (group: DocumentGroup) => group.title)
          }
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
          .divider({ strokeWidth: 0 })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, top: 24, bottom: 90 })
      .backgroundColor('#F8FAFC')

      Button('+')
        .width(58)
        .height(58)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#4F46E5')
        .borderRadius(29)
        .margin({ right: 20, bottom: 20 })
        .onClick(async () => {
          await this.createDocumentAndScan();
        })
    }
  }
}

export default Index;
