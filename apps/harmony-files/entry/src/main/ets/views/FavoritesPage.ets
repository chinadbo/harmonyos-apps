import { FavoriteItem } from '../model/FileItem';
import { FavoritesService } from '../service/FavoritesService';
import { EmptyView } from './components/EmptyView';

@Component
export struct FavoritesPage {
  @Prop navStack: NavPathStack;
  @State favorites: FavoriteItem[] = [];
  @State isLoading: boolean = true;

  async aboutToAppear(): Promise<void> {
    try {
      this.favorites = await FavoritesService.getInstance().getFavorites();
    } catch (e) {
      this.favorites = [];
    }
    this.isLoading = false;
  }

  private async loadFavorites(): Promise<void> {
    try {
      this.favorites = await FavoritesService.getInstance().getFavorites();
    } catch (e) {
      this.favorites = [];
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        LoadingProgress()
          .width(48)
          .height(48)
          .layoutWeight(1)
      } else if (this.favorites.length === 0) {
        EmptyView({ message: 'No favorites yet' })
      } else {
        List() {
          ForEach(this.favorites, (fav: FavoriteItem) => {
            ListItem() {
              Row() {
                Text('📁')
                  .fontSize(28)
                  .margin({ right: 12 })

                Column() {
                  Text(fav.name)
                    .fontSize(15)
                    .fontColor('#1a1a1a')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')

                  Text(fav.path)
                    .fontSize(12)
                    .fontColor('#999')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                    .margin({ top: 2 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .height(60)
              .padding({ left: 12, right: 12 })
              .backgroundColor(Color.White)
              .border({ width: { bottom: 0.5 }, color: '#e8e8e8', style: BorderStyle.Solid })
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                const params: Record<string, string> = { path: fav.path };
                this.navStack.pushPathByName('FileBrowserPage', params);
              })
            }
            .swipeAction({
              end: {
                builder: () => {
                  this.DeleteButton(fav);
                }
              }
            })
          }, (fav: FavoriteItem) => fav.id)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder
  DeleteButton(fav: FavoriteItem) {
    Button('Delete')
      .backgroundColor('#FF3B30')
      .fontColor(Color.White)
      .fontSize(14)
      .height(60)
      .padding({ left: 16, right: 16 })
      .onClick(async () => {
        await FavoritesService.getInstance().removeFavorite(fav.id);
        await this.loadFavorites();
      })
  }
}
