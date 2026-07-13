import { router } from '@ohos.router';
import { ArtworkService } from '../service/ArtworkService';
import { ArtworkMeta } from '../models/Types';
import { promptAction } from '@ohos.arkui';
import { wantAgent } from '@ohos.wantAgent';

@Component
export struct GalleryPage {
  @State artworks: ArtworkMeta[] = [];
  @State artworkService: ArtworkService | null = null;
  @State selectedArtwork: ArtworkMeta | null = null;
  @State showPreview: boolean = false;

  aboutToAppear() {
    this.artworkService = new ArtworkService(getContext(this) as Context);
    this.loadArtworks();
  }

  private loadArtworks() {
    this.artworks = this.artworkService?.getArtworksSync() ?? [];
  }

  private handleDelete(artwork: ArtworkMeta) {
    this.artworkService?.deleteArtwork(artwork.id).then(() => {
      this.loadArtworks();
      promptAction.showToast({ message: 'Deleted', duration: 2000 });
    });
  }

  private handlePreview(artwork: ArtworkMeta) {
    this.selectedArtwork = artwork;
    this.showPreview = true;
  }

  private handleShare(artwork: ArtworkMeta) {
    promptAction.showToast({ message: 'Share: ' + artwork.name, duration: 2000 });
  }

  build() {
    Column() {
      Row() {
        Button('←')
          .width(40)
          .height(40)
          .fontSize(20)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            router.back();
          })

        Text('Gallery')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('🗑')
          .width(40)
          .height(40)
          .fontSize(18)
          .backgroundColor('#FFF3E0')
          .fontColor('#FF9800')
          .borderRadius(8)
          .onClick(() => {
            this.artworkService?.clearAll().then(() => {
              this.loadArtworks();
              promptAction.showToast({ message: 'All cleared', duration: 2000 });
            });
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })

      if (this.artworks.length === 0) {
        Column() {
          Text('🎨')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('No artworks yet')
            .fontSize(18)
            .fontColor('#999999')
          Text('Create your first doodle in the editor!')
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.artworks, (artwork: ArtworkMeta) => {
            ListItem() {
              Row() {
                Column() {
                  Text(artwork.name)
                    .fontSize(16)
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Medium)

                  Text(new Date(artwork.createdAt).toLocaleDateString())
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 4 })

                  Text(artwork.width + ' x ' + artwork.height)
                    .fontSize(11)
                    .fontColor('#CCCCCC')
                    .margin({ top: 2 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Button('👁')
                  .width(36)
                  .height(36)
                  .fontSize(16)
                  .backgroundColor('#E6F0FF')
                  .fontColor('#007DFF')
                  .borderRadius(8)
                  .margin({ right: 8 })
                  .onClick(() => this.handlePreview(artwork))

                Button('📤')
                  .width(36)
                  .height(36)
                  .fontSize(16)
                  .backgroundColor('#E8F5E9')
                  .fontColor('#4CAF50')
                  .borderRadius(8)
                  .margin({ right: 8 })
                  .onClick(() => this.handleShare(artwork))

                Button('🗑')
                  .width(36)
                  .height(36)
                  .fontSize(16)
                  .backgroundColor('#FFEBEE')
                  .fontColor('#F44336')
                  .borderRadius(8)
                  .onClick(() => this.handleDelete(artwork))
              }
              .width('100%')
              .height(80)
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ bottom: 8 })
              .border({ width: 1, color: '#E0E0E0' })
            }
          }, (artwork: ArtworkMeta) => artwork.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding(16)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
}
